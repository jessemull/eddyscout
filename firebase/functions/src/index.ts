import Anthropic, { APIError, RateLimitError } from "@anthropic-ai/sdk";
import * as admin from "firebase-admin";
import { setGlobalOptions } from "firebase-functions/v2";
import { HttpsError, onCall } from "firebase-functions/v2/https";
import { defineSecret } from "firebase-functions/params";
import * as logger from "firebase-functions/logger";
import { z } from "zod";

admin.initializeApp();

const anthropicApiKey = defineSecret("ANTHROPIC_API_KEY");

setGlobalOptions({ region: "us-west2", maxInstances: 10 });

const MAX_PAYLOAD_BYTES = 48 * 1024;
const MAX_REPORT_MESSAGE = 800;

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
    await admin.firestore().collection("conditionReports").add({
      uid: request.auth.uid,
      launchId,
      message,
      clientConditionsFetchedAt: clientConditionsFetchedAt ?? null,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      platform: "flutter",
    });
    return { ok: true };
  },
);
