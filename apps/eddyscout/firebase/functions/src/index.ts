import Anthropic, { APIError, RateLimitError } from "@anthropic-ai/sdk";
import { createHash } from "node:crypto";
import * as admin from "firebase-admin";
import { setGlobalOptions } from "firebase-functions/v2";
import { HttpsError, onCall } from "firebase-functions/v2/https";
import { onSchedule } from "firebase-functions/v2/scheduler";
import { defineSecret } from "firebase-functions/params";
import * as logger from "firebase-functions/logger";
import { z } from "zod";
import {
  BATCH_MODERATE_MAX,
  MODERATION_STATUS_APPROVED,
  MODERATION_STATUS_HELD,
  MODERATION_STATUS_REJECTED,
  STALE_HOLD_RELEASE_BATCH_SIZE,
  assertModerator,
  buildHistoryReportsQuery,
  buildPendingReportsQuery,
  computeExpiresAt,
  evaluateKeywordHold,
  firestoreSafeLaunchKey,
  invalidateLaunchDigest,
  isModerator,
  isPubliclyVisibleStatus,
  loadModerationConfig,
  mapHistoryReportDoc,
  mapPendingReportDoc,
  moderateHeldReport,
  moderateHeldReportsBatch,
  parseIsoDate,
  reopenModeratedReport,
  resolveModerationStatus,
  staleHoldCutoff,
} from "./moderation.js";

admin.initializeApp();

const anthropicApiKey = defineSecret("ANTHROPIC_API_KEY");

setGlobalOptions({ region: "us-west2", maxInstances: 10 });

const MAX_PAYLOAD_BYTES = 48 * 1024;
const MAX_REPORT_MESSAGE = 800;

const DIGEST_CACHE_TTL_MS = 8 * 60 * 60 * 1000;
const DIGEST_RATE_LIMIT_SEC = 90;
const DIGEST_FORCE_REFRESH_MIN_SEC = 180;

const DIGEST_MODEL = "claude-haiku-4-5-20251001";
const PURGE_BATCH_SIZE = 500;

function reportSignatureFromDocs(
  docs: admin.firestore.QueryDocumentSnapshot[],
): string {
  const parts = docs
    .map((doc) => {
      const d = doc.data();
      const ts = d.createdAt;
      const sec =
        ts instanceof admin.firestore.Timestamp ? ts.seconds : 0;
      return `${doc.id}:${sec}`;
    })
    .sort();
  return createHash("sha256").update(parts.join("|")).digest("hex");
}

const flowBandsSchema = z
  .object({
    cfsMarginalBelow: z.number().nullable().optional(),
    cfsComfortMax: z.number().nullable().optional(),
    cfsNoGoAbove: z.number().nullable().optional(),
  })
  .nullable()
  .optional();

const launchSchema = z.object({
  id: z.string(),
  name: z.string(),
  latitude: z.number(),
  longitude: z.number(),
  shortNote: z.string(),
  riverSystem: z.string(),
  windExposure: z.string(),
  tideRelevance: z.string(),
  noaaTideStationId: z.string().nullable().optional(),
  marineZoneId: z.string().nullable().optional(),
  usgsSiteId: z.string().nullable().optional(),
  flowBands: flowBandsSchema,
  skillProfile: z.string(),
});

const weatherSchema = z
  .object({
    temperatureF: z.number().nullable().optional(),
    windSpeedMph: z.number().nullable().optional(),
    windGustMph: z.number().nullable().optional(),
    windDirection: z.string().nullable().optional(),
    shortForecast: z.string().nullable().optional(),
    periodStart: z.string().nullable().optional(),
    source: z.string(),
  })
  .nullable()
  .optional();

const snapshotSchema = z.object({
  fetchedAt: z.string(),
  weather: weatherSchema,
  weatherError: z.string().nullable().optional(),
  tides: z.unknown().nullable().optional(),
  tideError: z.string().nullable().optional(),
  marine: z.unknown().nullable().optional(),
  marineError: z.string().nullable().optional(),
  riverFlow: z.unknown().nullable().optional(),
  riverError: z.string().nullable().optional(),
});

const goNoGoSchema = z.object({
  verdict: z.string(),
  computedAt: z.string(),
  reasons: z.array(
    z.object({
      code: z.string(),
      message: z.string(),
      severity: z.string(),
    }),
  ),
});

const summarizeBodySchema = z.object({
  launch: launchSchema,
  snapshot: snapshotSchema,
  goNoGo: goNoGoSchema,
});

// Cloud Run must allow the HTTP request through; Firebase Auth is still verified
// inside the Callable protocol (request.auth). Without this, clients often see
// firebase_functions/unauthenticated even with a valid user + SHA fingerprints.
export const summarizeConditions = onCall(
  { secrets: [anthropicApiKey], cors: true, invoker: "public" },
  async (request) => {
    if (!request.auth?.uid) {
      throw new HttpsError("unauthenticated", "Sign in required.");
    }
    const raw = request.data;
    const json = JSON.stringify(raw ?? {});
    const bytes = Buffer.byteLength(json, "utf8");
    if (bytes > MAX_PAYLOAD_BYTES) {
      throw new HttpsError("invalid-argument", "Payload too large.");
    }
    const parsed = summarizeBodySchema.safeParse(raw);
    if (!parsed.success) {
      throw new HttpsError("invalid-argument", "Invalid payload.");
    }

    const key = anthropicApiKey.value();
    if (!key) {
      throw new HttpsError("failed-precondition", "Anthropic API key not configured.");
    }

    const client = new Anthropic({ apiKey: key });
    const userContent = JSON.stringify(parsed.data, null, 0);

    let msg;
    try {
      msg = await client.messages.create({
        model: "claude-haiku-4-5-20251001",
        max_tokens: 512,
        system:
          "You summarize paddling conditions for experienced planners. Use ONLY facts present in the JSON. " +
          "Do not invent hazards, gauges, or forecasts. If data is missing, say so briefly. " +
          "Keep under 180 words. Plain text, no markdown headings.",
        messages: [{ role: "user", content: userContent }],
      });
    } catch (e: unknown) {
      if (e instanceof RateLimitError) {
        throw new HttpsError(
          "resource-exhausted",
          "AI is rate-limited; try again in a moment.",
        );
      }
      if (e instanceof APIError) {
        logger.warn("summarizeConditions Anthropic APIError", {
          status: e.status,
          message: e.message,
        });
        throw new HttpsError(
          "failed-precondition",
          e.message || "AI provider rejected the request.",
        );
      }
      logger.error("summarizeConditions unexpected error", { err: String(e) });
      throw new HttpsError("internal", "Unexpected error generating summary.");
    }

    const textBlock = msg.content.find((b) => b.type === "text");
    const summaryText =
      textBlock && textBlock.type === "text" ? textBlock.text.trim() : "";

    return { summaryText };
  },
);

const reportSchema = z.object({
  launchId: z.string().min(1).max(120),
  message: z.string().min(1).max(MAX_REPORT_MESSAGE),
  clientConditionsFetchedAt: z.string().nullable().optional(),
});

export const submitConditionReport = onCall(
  { cors: true, invoker: "public" },
  async (request) => {
    if (!request.auth?.uid) {
      throw new HttpsError("unauthenticated", "Sign in required.");
    }
    const parsed = reportSchema.safeParse(request.data);
    if (!parsed.success) {
      throw new HttpsError("invalid-argument", "Invalid report.");
    }
    const { launchId, message, clientConditionsFetchedAt } = parsed.data;
    const db = admin.firestore();
    const config = await loadModerationConfig(db);
    const hold = evaluateKeywordHold(message, config.keywords);
    const moderationStatus = hold.held
      ? MODERATION_STATUS_HELD
      : MODERATION_STATUS_APPROVED;
    const moderationReason = hold.held ? "keyword_hold" : null;
    const createdAt = admin.firestore.Timestamp.now();
    const expiresAt = computeExpiresAt(createdAt, config.retentionDays);

    await db.collection("conditionReports").add({
      uid: request.auth.uid,
      launchId,
      message,
      clientConditionsFetchedAt: clientConditionsFetchedAt ?? null,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      expiresAt,
      moderationStatus,
      moderationReason,
      platform: "flutter",
    });

    if (moderationStatus === MODERATION_STATUS_APPROVED) {
      await invalidateLaunchDigest(db, launchId);
    }

    logger.info("submitConditionReport", {
      launchId,
      moderationStatus,
    });

    return { ok: true, moderationStatus };
  },
);

const listReportsSchema = z.object({
  launchId: z.string().min(1).max(120),
  limit: z.number().int().min(1).max(50).optional(),
});

export const listConditionReports = onCall(
  { cors: true, invoker: "public" },
  async (request) => {
    if (!request.auth?.uid) {
      throw new HttpsError("unauthenticated", "Sign in required.");
    }
    const parsed = listReportsSchema.safeParse(request.data);
    if (!parsed.success) {
      throw new HttpsError("invalid-argument", "Invalid request.");
    }
    const { launchId } = parsed.data;
    const limit = Math.min(50, Math.max(1, parsed.data.limit ?? 20));

    const db = admin.firestore();
    const callerUid = request.auth.uid;

    let approvedSnap;
    try {
      approvedSnap = await db
        .collection("conditionReports")
        .where("launchId", "==", launchId)
        .where("moderationStatus", "==", MODERATION_STATUS_APPROVED)
        .orderBy("createdAt", "desc")
        .limit(limit)
        .get();
    } catch (e: unknown) {
      logger.error("listConditionReports query failed", { err: String(e) });
      throw new HttpsError("internal", "Could not load reports.");
    }

    const reports: Array<{ message: string; createdAt: string; isMine: boolean }> =
      [];

    for (const doc of approvedSnap.docs) {
      const d = doc.data();
      const ts = d.createdAt;
      if (!(ts instanceof admin.firestore.Timestamp)) {
        continue;
      }
      if (typeof d.message !== "string") {
        continue;
      }
      reports.push({
        message: d.message,
        createdAt: ts.toDate().toISOString(),
        isMine: d.uid === callerUid,
      });
    }

    let viewerHasPendingReport = false;
    try {
      const pendingSnap = await db
        .collection("conditionReports")
        .where("launchId", "==", launchId)
        .where("uid", "==", callerUid)
        .where("moderationStatus", "==", MODERATION_STATUS_HELD)
        .limit(1)
        .get();
      viewerHasPendingReport = !pendingSnap.empty;
    } catch (e: unknown) {
      logger.error("listConditionReports pending check failed", {
        err: String(e),
      });
    }

    return { reports, viewerHasPendingReport };
  },
);

const summarizeLaunchReportsSchema = z.object({
  launchId: z.string().min(1).max(120),
  forceRefresh: z.boolean().optional(),
  reportLimit: z.number().int().min(5).max(30).optional(),
});

export const summarizeLaunchReports = onCall(
  { secrets: [anthropicApiKey], cors: true, invoker: "public" },
  async (request) => {
    if (!request.auth?.uid) {
      throw new HttpsError("unauthenticated", "Sign in required.");
    }
    const parsed = summarizeLaunchReportsSchema.safeParse(request.data);
    if (!parsed.success) {
      throw new HttpsError("invalid-argument", "Invalid request.");
    }
    const { launchId, forceRefresh } = parsed.data;
    const reportLimit = Math.min(
      30,
      Math.max(5, parsed.data.reportLimit ?? 20),
    );
    const uid = request.auth.uid;
    const db = admin.firestore();
    const launchKey = firestoreSafeLaunchKey(launchId);

    let snap;
    try {
      snap = await db
        .collection("conditionReports")
        .where("launchId", "==", launchId)
        .where("moderationStatus", "==", MODERATION_STATUS_APPROVED)
        .orderBy("createdAt", "desc")
        .limit(reportLimit)
        .get();
    } catch (e: unknown) {
      logger.error("summarizeLaunchReports query failed", { err: String(e) });
      throw new HttpsError("internal", "Could not load reports.");
    }

    const usableDocs = snap.docs.filter((doc) => {
      const d = doc.data();
      const status = resolveModerationStatus(d.moderationStatus);
      return (
        isPubliclyVisibleStatus(status) &&
        d.createdAt instanceof admin.firestore.Timestamp &&
        typeof d.message === "string"
      );
    });

    if (usableDocs.length === 0) {
      return {
        digestText: "",
        noReports: true,
        cached: false,
      };
    }

    const signature = reportSignatureFromDocs(usableDocs);
    const digestRef = db.collection("launchReportDigests").doc(launchKey);
    const digestSnap = await digestRef.get();
    const now = Date.now();

    if (!forceRefresh && digestSnap.exists) {
      const c = digestSnap.data()!;
      const updatedAt = c.updatedAt;
      if (
        typeof c.reportSignature === "string" &&
        typeof c.digestText === "string" &&
        c.reportSignature === signature &&
        updatedAt instanceof admin.firestore.Timestamp
      ) {
        const ageMs = now - updatedAt.toMillis();
        if (ageMs >= 0 && ageMs <= DIGEST_CACHE_TTL_MS) {
          return {
            digestText: c.digestText,
            cached: true,
            noReports: false,
          };
        }
      }
    }

    const rateRef = db.collection("reportDigestRate").doc(`${uid}_${launchKey}`);
    const rateSnap = await rateRef.get();
    const lastAt = rateSnap.data()?.lastAnthropicAt;
    if (lastAt instanceof admin.firestore.Timestamp) {
      const elapsedSec = (now - lastAt.toMillis()) / 1000;
      const minSec = forceRefresh
        ? DIGEST_FORCE_REFRESH_MIN_SEC
        : DIGEST_RATE_LIMIT_SEC;
      if (elapsedSec < minSec) {
        throw new HttpsError(
          "resource-exhausted",
          `Please wait before refreshing the digest (${Math.ceil(minSec - elapsedSec)}s).`,
        );
      }
    }

    const key = anthropicApiKey.value();
    if (!key) {
      throw new HttpsError("failed-precondition", "Anthropic API key not configured.");
    }

    const forModel = [...usableDocs]
      .reverse()
      .map((doc) => {
        const d = doc.data();
        const ts = d.createdAt as admin.firestore.Timestamp;
        return {
          message: d.message as string,
          createdAt: ts.toDate().toISOString(),
        };
      });

    const userContent = JSON.stringify({ launchId, reports: forModel });

    const client = new Anthropic({ apiKey: key });
    let msg;
    try {
      msg = await client.messages.create({
        model: DIGEST_MODEL,
        max_tokens: 400,
        system:
          "You summarize recent paddler-submitted condition notes for trip planners. " +
          "These are subjective community messages, not official forecasts or safety notices. " +
          "Use ONLY what appears in the JSON; do not invent hazards, closures, or gauge readings. " +
          "If reports conflict, say so briefly. Keep under 160 words. Plain text, no markdown headings.",
        messages: [{ role: "user", content: userContent }],
      });
    } catch (e: unknown) {
      if (e instanceof RateLimitError) {
        throw new HttpsError(
          "resource-exhausted",
          "AI is rate-limited; try again in a moment.",
        );
      }
      if (e instanceof APIError) {
        logger.warn("summarizeLaunchReports Anthropic APIError", {
          status: e.status,
          message: e.message,
        });
        throw new HttpsError(
          "failed-precondition",
          e.message || "AI provider rejected the request.",
        );
      }
      logger.error("summarizeLaunchReports unexpected error", { err: String(e) });
      throw new HttpsError("internal", "Unexpected error generating digest.");
    }

    const textBlock = msg.content.find((b) => b.type === "text");
    const digestText =
      textBlock && textBlock.type === "text" ? textBlock.text.trim() : "";

    const batch = db.batch();
    batch.set(digestRef, {
      reportSignature: signature,
      digestText,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      model: DIGEST_MODEL,
    });
    batch.set(
      rateRef,
      {
        lastAnthropicAt: admin.firestore.FieldValue.serverTimestamp(),
      },
      { merge: true },
    );
    await batch.commit();

    return {
      digestText,
      cached: false,
      noReports: false,
    };
  },
);

export const checkModeratorAccess = onCall(
  { cors: true, invoker: "public" },
  async (request) => {
    if (!request.auth?.uid) {
      throw new HttpsError("unauthenticated", "Sign in required.");
    }
    const config = await loadModerationConfig(admin.firestore());
    return { isModerator: isModerator(request.auth.uid, config) };
  },
);

const listPendingReportsSchema = z.object({
  limit: z.number().int().min(1).max(100).optional(),
  launchId: z.string().min(1).max(120).optional(),
  createdAfter: z.string().optional(),
  createdBefore: z.string().optional(),
  sort: z.enum(["createdAt_asc", "createdAt_desc"]).optional(),
});

export const listPendingConditionReports = onCall(
  { cors: true, invoker: "public" },
  async (request) => {
    const db = admin.firestore();
    const config = await loadModerationConfig(db);
    assertModerator(request, config);

    const parsed = listPendingReportsSchema.safeParse(request.data ?? {});
    if (!parsed.success) {
      throw new HttpsError("invalid-argument", "Invalid request.");
    }
    const limit = Math.min(100, Math.max(1, parsed.data.limit ?? 25));
    const sort = parsed.data.sort ?? "createdAt_asc";
    let createdAfter: Date | undefined;
    let createdBefore: Date | undefined;
    try {
      if (parsed.data.createdAfter) {
        createdAfter = parseIsoDate(parsed.data.createdAfter);
      }
      if (parsed.data.createdBefore) {
        createdBefore = parseIsoDate(parsed.data.createdBefore);
      }
    } catch (error: unknown) {
      if (error instanceof HttpsError) {
        throw error;
      }
      throw new HttpsError("invalid-argument", "Invalid date.");
    }

    let snap;
    try {
      snap = await buildPendingReportsQuery(db, {
        launchId: parsed.data.launchId,
        createdAfter,
        createdBefore,
        sort,
        limit,
      }).get();
    } catch (e: unknown) {
      logger.error("listPendingConditionReports query failed", {
        err: String(e),
      });
      throw new HttpsError("internal", "Could not load pending reports.");
    }

    const now = admin.firestore.Timestamp.now();
    const reports = snap.docs
      .map((doc) => mapPendingReportDoc(doc, now))
      .filter((row): row is NonNullable<typeof row> => row !== null);

    return { reports };
  },
);

const listModerationHistorySchema = z.object({
  limit: z.number().int().min(1).max(100).optional(),
  launchId: z.string().min(1).max(120).optional(),
  status: z.enum(["approved", "rejected", "all"]).optional(),
  reviewedAfter: z.string().optional(),
  reviewedBefore: z.string().optional(),
  sort: z.enum(["reviewedAt_desc", "reviewedAt_asc"]).optional(),
});

export const listModerationHistory = onCall(
  { cors: true, invoker: "public" },
  async (request) => {
    const db = admin.firestore();
    const config = await loadModerationConfig(db);
    assertModerator(request, config);

    const parsed = listModerationHistorySchema.safeParse(request.data ?? {});
    if (!parsed.success) {
      throw new HttpsError("invalid-argument", "Invalid request.");
    }
    const limit = Math.min(100, Math.max(1, parsed.data.limit ?? 25));
    const sort = parsed.data.sort ?? "reviewedAt_desc";
    const status = parsed.data.status ?? "all";
    let reviewedAfter: Date | undefined;
    let reviewedBefore: Date | undefined;
    try {
      if (parsed.data.reviewedAfter) {
        reviewedAfter = parseIsoDate(parsed.data.reviewedAfter);
      }
      if (parsed.data.reviewedBefore) {
        reviewedBefore = parseIsoDate(parsed.data.reviewedBefore);
      }
    } catch (error: unknown) {
      if (error instanceof HttpsError) {
        throw error;
      }
      throw new HttpsError("invalid-argument", "Invalid date.");
    }

    let snap;
    try {
      snap = await buildHistoryReportsQuery(db, {
        launchId: parsed.data.launchId,
        status,
        reviewedAfter,
        reviewedBefore,
        sort,
        limit,
      }).get();
    } catch (e: unknown) {
      logger.error("listModerationHistory query failed", {
        err: String(e),
      });
      throw new HttpsError("internal", "Could not load moderation history.");
    }

    const reports = snap.docs
      .map((doc) => mapHistoryReportDoc(doc))
      .filter((row): row is NonNullable<typeof row> => row !== null);

    return { reports };
  },
);

const moderateReportSchema = z.object({
  reportId: z.string().min(1).max(200),
  action: z.enum(["approve", "reject"]),
});

export const moderateConditionReport = onCall(
  { cors: true, invoker: "public" },
  async (request) => {
    const db = admin.firestore();
    const config = await loadModerationConfig(db);
    const moderatorUid = assertModerator(request, config);

    const parsed = moderateReportSchema.safeParse(request.data);
    if (!parsed.success) {
      throw new HttpsError("invalid-argument", "Invalid request.");
    }
    const { reportId, action } = parsed.data;

    const result = await moderateHeldReport(db, reportId, action, moderatorUid);

    logger.info("moderateConditionReport", {
      reportId,
      launchId: result.launchId,
      action,
      moderationStatus: result.moderationStatus,
    });

    return { ok: true, moderationStatus: result.moderationStatus };
  },
);

const moderateReportsBatchSchema = z.object({
  reportIds: z.array(z.string().min(1).max(200)).min(1).max(BATCH_MODERATE_MAX),
  action: z.enum(["approve", "reject"]),
});

export const moderateConditionReportsBatch = onCall(
  { cors: true, invoker: "public" },
  async (request) => {
    const db = admin.firestore();
    const config = await loadModerationConfig(db);
    const moderatorUid = assertModerator(request, config);

    const parsed = moderateReportsBatchSchema.safeParse(request.data);
    if (!parsed.success) {
      throw new HttpsError("invalid-argument", "Invalid request.");
    }

    const { succeeded, failed } = await moderateHeldReportsBatch(
      db,
      parsed.data.reportIds,
      parsed.data.action,
      moderatorUid,
    );

    logger.info("moderateConditionReportsBatch", {
      action: parsed.data.action,
      succeeded: succeeded.length,
      failed: failed.length,
    });

    return { succeeded, failed };
  },
);

const reopenReportSchema = z.object({
  reportId: z.string().min(1),
});

export const reopenConditionReport = onCall(
  { cors: true, invoker: "public" },
  async (request) => {
    const db = admin.firestore();
    const config = await loadModerationConfig(db);
    const moderatorUid = assertModerator(request, config);

    const parsed = reopenReportSchema.safeParse(request.data ?? {});
    if (!parsed.success) {
      throw new HttpsError("invalid-argument", "Invalid request.");
    }

    const result = await reopenModeratedReport(
      db,
      parsed.data.reportId,
      moderatorUid,
    );

    logger.info("reopenConditionReport", {
      reportId: parsed.data.reportId,
      launchId: result.launchId,
      reopenedBy: moderatorUid,
    });

    return { ok: true, moderationStatus: result.moderationStatus };
  },
);

export const releaseStaleHeldConditionReports = onSchedule(
  "every 24 hours",
  async () => {
    const db = admin.firestore();
    const config = await loadModerationConfig(db);
    const now = admin.firestore.Timestamp.now();
    const cutoff = staleHoldCutoff(config.holdMaxDays, now);

    let snap;
    try {
      snap = await db
        .collection("conditionReports")
        .where("moderationStatus", "==", MODERATION_STATUS_HELD)
        .where("createdAt", "<=", cutoff)
        .orderBy("createdAt", "asc")
        .limit(STALE_HOLD_RELEASE_BATCH_SIZE)
        .get();
    } catch (e: unknown) {
      logger.error("releaseStaleHeldConditionReports query failed", {
        err: String(e),
      });
      return;
    }

    if (snap.empty) {
      logger.info("releaseStaleHeldConditionReports", { released: 0 });
      return;
    }

    let released = 0;
    for (const doc of snap.docs) {
      try {
        await moderateHeldReport(db, doc.id, "approve", null);
        released += 1;
      } catch (e: unknown) {
        logger.error("releaseStaleHeldConditionReports item failed", {
          reportId: doc.id,
          err: String(e),
        });
      }
    }

    logger.info("releaseStaleHeldConditionReports", { released });
  },
);

export const purgeExpiredConditionReports = onSchedule(
  "every 24 hours",
  async () => {
    const db = admin.firestore();
    const now = admin.firestore.Timestamp.now();
    let deleted = 0;

    const snap = await db
      .collection("conditionReports")
      .where("expiresAt", "<=", now)
      .orderBy("expiresAt", "asc")
      .limit(PURGE_BATCH_SIZE)
      .get();

    if (snap.empty) {
      logger.info("purgeExpiredConditionReports", { deleted: 0 });
      return;
    }

    const batch = db.batch();
    for (const doc of snap.docs) {
      batch.delete(doc.ref);
      deleted++;
    }
    await batch.commit();

    logger.info("purgeExpiredConditionReports", { deleted });
  },
);
