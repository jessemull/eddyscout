import * as admin from "firebase-admin";
import { CallableRequest, HttpsError } from "firebase-functions/v2/https";

export type ModerationStatus = "approved" | "held" | "rejected";

export type ModerateAction = "approve" | "reject";

export type PendingSort = "createdAt_asc" | "createdAt_desc";

export type HistorySort = "reviewedAt_desc" | "reviewedAt_asc";

export type HistoryStatusFilter = "approved" | "rejected" | "all";

export interface ModerationConfig {
  retentionDays: number;
  holdMaxDays: number;
  adminUids: string[];
  keywords: string[];
}

export const DEFAULT_RETENTION_DAYS = 90;

export const DEFAULT_HOLD_MAX_DAYS = 30;

export const DEFAULT_KEYWORDS: string[] = [];

export const MODERATION_CONFIG_PATH = "config/moderation";

export const MODERATION_STATUS_APPROVED: ModerationStatus = "approved";
export const MODERATION_STATUS_HELD: ModerationStatus = "held";
export const MODERATION_STATUS_REJECTED: ModerationStatus = "rejected";

export const MODERATION_REASON_ADMIN_APPROVE = "admin_approve";
export const MODERATION_REASON_ADMIN_REJECT = "admin_reject";
export const MODERATION_REASON_ADMIN_REOPEN = "admin_reopen";
export const MODERATION_REASON_HOLD_TIMEOUT = "hold_timeout_release";

export const STALE_HOLD_RELEASE_BATCH_SIZE = 500;

export const BATCH_MODERATE_MAX = 25;

export interface PendingReportRow {
  id: string;
  launchId: string;
  message: string;
  createdAt: string;
  moderationReason: string | null;
  submitterUid: string;
  holdAgeDays: number;
}

export interface HistoryReportRow {
  id: string;
  launchId: string;
  message: string;
  createdAt: string;
  submitterUid: string;
  moderationStatus: ModerationStatus;
  moderationReason: string | null;
  reviewedAt: string;
  reviewedBy: string | null;
}

export interface ModerateReportResult {
  moderationStatus: ModerationStatus;
  launchId: string;
}

export interface BatchModerateFailure {
  reportId: string;
  code: string;
}

export function defaultModerationConfig(): ModerationConfig {
  return {
    retentionDays: DEFAULT_RETENTION_DAYS,
    holdMaxDays: DEFAULT_HOLD_MAX_DAYS,
    adminUids: [],
    keywords: DEFAULT_KEYWORDS,
  };
}

export function parseModerationConfig(
  data: FirebaseFirestore.DocumentData | undefined,
): ModerationConfig {
  const defaults = defaultModerationConfig();
  if (!data) {
    return defaults;
  }

  const retentionDays =
    typeof data.retentionDays === "number" && data.retentionDays > 0
      ? Math.floor(data.retentionDays)
      : defaults.retentionDays;

  const holdMaxDays =
    typeof data.holdMaxDays === "number" && data.holdMaxDays > 0
      ? Math.floor(data.holdMaxDays)
      : defaults.holdMaxDays;

  const adminUids = Array.isArray(data.adminUids)
    ? data.adminUids.filter((uid): uid is string => typeof uid === "string")
    : defaults.adminUids;

  const keywords = Array.isArray(data.keywords)
    ? data.keywords.filter((word): word is string => typeof word === "string")
    : defaults.keywords;

  return { retentionDays, holdMaxDays, adminUids, keywords };
}

export async function loadModerationConfig(
  db: FirebaseFirestore.Firestore,
): Promise<ModerationConfig> {
  const snap = await db.doc(MODERATION_CONFIG_PATH).get();
  return parseModerationConfig(snap.data());
}

export function isModerator(uid: string, config: ModerationConfig): boolean {
  return config.adminUids.includes(uid);
}

export function assertModerator(
  request: CallableRequest,
  config: ModerationConfig,
): string {
  const uid = request.auth?.uid;
  if (!uid) {
    throw new HttpsError("unauthenticated", "Sign in required.");
  }
  if (!isModerator(uid, config)) {
    throw new HttpsError("permission-denied", "Moderator access required.");
  }
  return uid;
}

export function resolveModerationStatus(
  raw: unknown,
): ModerationStatus | null {
  if (raw === MODERATION_STATUS_APPROVED) {
    return MODERATION_STATUS_APPROVED;
  }
  if (raw === MODERATION_STATUS_HELD) {
    return MODERATION_STATUS_HELD;
  }
  if (raw === MODERATION_STATUS_REJECTED) {
    return MODERATION_STATUS_REJECTED;
  }
  return null;
}

export function isPubliclyVisibleStatus(status: ModerationStatus | null): boolean {
  if (status === null) {
    return true;
  }
  return status === MODERATION_STATUS_APPROVED;
}

export interface KeywordHoldResult {
  held: boolean;
  matchedKeyword?: string;
}

function escapeRegExp(value: string): string {
  return value.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
}

export function evaluateKeywordHold(
  message: string,
  keywords: string[],
): KeywordHoldResult {
  const trimmed = message.trim();
  if (trimmed.length === 0 || keywords.length === 0) {
    return { held: false };
  }

  const normalized = trimmed.toLowerCase();
  for (const keyword of keywords) {
    const word = keyword.trim().toLowerCase();
    if (word.length === 0) {
      continue;
    }
    const pattern = new RegExp(`\\b${escapeRegExp(word)}\\b`, "i");
    if (pattern.test(normalized)) {
      return { held: true, matchedKeyword: word };
    }
  }

  return { held: false };
}

export function computeExpiresAt(
  createdAt: admin.firestore.Timestamp,
  retentionDays: number,
): admin.firestore.Timestamp {
  const millis = createdAt.toMillis() + retentionDays * 24 * 60 * 60 * 1000;
  return admin.firestore.Timestamp.fromMillis(millis);
}

export function computeHoldAgeDays(
  createdAt: admin.firestore.Timestamp,
  now: admin.firestore.Timestamp,
): number {
  const diffMs = now.toMillis() - createdAt.toMillis();
  return Math.max(0, Math.floor(diffMs / (24 * 60 * 60 * 1000)));
}

export function isStaleHold(
  createdAt: admin.firestore.Timestamp,
  holdMaxDays: number,
  now: admin.firestore.Timestamp,
): boolean {
  return computeHoldAgeDays(createdAt, now) >= holdMaxDays;
}

export function staleHoldCutoff(
  holdMaxDays: number,
  now: admin.firestore.Timestamp,
): admin.firestore.Timestamp {
  return admin.firestore.Timestamp.fromMillis(
    now.toMillis() - holdMaxDays * 24 * 60 * 60 * 1000,
  );
}

export function parseIsoDate(value: string): Date {
  const parsed = new Date(value);
  if (Number.isNaN(parsed.getTime())) {
    throw new HttpsError("invalid-argument", "Invalid date.");
  }
  return parsed;
}

export function firestoreSafeLaunchKey(launchId: string): string {
  return launchId.replace(/\//g, "_");
}

export async function invalidateLaunchDigest(
  db: FirebaseFirestore.Firestore,
  launchId: string,
): Promise<void> {
  const launchKey = firestoreSafeLaunchKey(launchId);
  await db.collection("launchReportDigests").doc(launchKey).delete();
}

export function mapPendingReportDoc(
  doc: FirebaseFirestore.QueryDocumentSnapshot,
  now: admin.firestore.Timestamp,
): PendingReportRow | null {
  const d = doc.data();
  const ts = d.createdAt;
  if (!(ts instanceof admin.firestore.Timestamp)) {
    return null;
  }
  if (typeof d.message !== "string" || typeof d.launchId !== "string") {
    return null;
  }
  const submitterUid = typeof d.uid === "string" ? d.uid : "";
  return {
    id: doc.id,
    launchId: d.launchId,
    message: d.message,
    createdAt: ts.toDate().toISOString(),
    moderationReason:
      typeof d.moderationReason === "string" ? d.moderationReason : null,
    submitterUid,
    holdAgeDays: computeHoldAgeDays(ts, now),
  };
}

export function mapHistoryReportDoc(
  doc: FirebaseFirestore.QueryDocumentSnapshot,
): HistoryReportRow | null {
  const d = doc.data();
  const createdTs = d.createdAt;
  const reviewedTs = d.reviewedAt;
  if (!(createdTs instanceof admin.firestore.Timestamp)) {
    return null;
  }
  if (!(reviewedTs instanceof admin.firestore.Timestamp)) {
    return null;
  }
  if (typeof d.message !== "string" || typeof d.launchId !== "string") {
    return null;
  }
  const status = resolveModerationStatus(d.moderationStatus);
  if (status === null || status === MODERATION_STATUS_HELD) {
    return null;
  }
  const submitterUid = typeof d.uid === "string" ? d.uid : "";
  const reviewedBy =
    typeof d.reviewedBy === "string" && d.reviewedBy.length > 0
      ? d.reviewedBy
      : null;
  return {
    id: doc.id,
    launchId: d.launchId,
    message: d.message,
    createdAt: createdTs.toDate().toISOString(),
    submitterUid,
    moderationStatus: status,
    moderationReason:
      typeof d.moderationReason === "string" ? d.moderationReason : null,
    reviewedAt: reviewedTs.toDate().toISOString(),
    reviewedBy,
  };
}

function moderationReasonForAction(
  action: ModerateAction,
  reviewedBy: string | null,
): string {
  if (reviewedBy === null && action === "approve") {
    return MODERATION_REASON_HOLD_TIMEOUT;
  }
  return action === "approve"
    ? MODERATION_REASON_ADMIN_APPROVE
    : MODERATION_REASON_ADMIN_REJECT;
}

export async function moderateHeldReport(
  db: FirebaseFirestore.Firestore,
  reportId: string,
  action: ModerateAction,
  reviewedBy: string | null,
): Promise<ModerateReportResult> {
  const reportRef = db.collection("conditionReports").doc(reportId);
  const reportSnap = await reportRef.get();
  if (!reportSnap.exists) {
    throw new HttpsError("not-found", "Report not found.");
  }

  const data = reportSnap.data()!;
  const currentStatus = resolveModerationStatus(data.moderationStatus);
  if (currentStatus !== MODERATION_STATUS_HELD) {
    throw new HttpsError(
      "failed-precondition",
      "Report is not pending moderation.",
    );
  }

  const launchId =
    typeof data.launchId === "string" ? data.launchId : undefined;
  if (!launchId) {
    throw new HttpsError("failed-precondition", "Report missing launchId.");
  }

  const moderationStatus =
    action === "approve"
      ? MODERATION_STATUS_APPROVED
      : MODERATION_STATUS_REJECTED;
  const moderationReason = moderationReasonForAction(action, reviewedBy);

  await reportRef.update({
    moderationStatus,
    moderationReason,
    moderationReviewed: true,
    reviewedAt: admin.firestore.FieldValue.serverTimestamp(),
    reviewedBy: reviewedBy,
  });

  await invalidateLaunchDigest(db, launchId);

  return { moderationStatus, launchId };
}

export function isReopenEligibleStatus(
  status: ModerationStatus | null,
): status is typeof MODERATION_STATUS_APPROVED | typeof MODERATION_STATUS_REJECTED {
  return (
    status === MODERATION_STATUS_APPROVED ||
    status === MODERATION_STATUS_REJECTED
  );
}

export async function reopenModeratedReport(
  db: FirebaseFirestore.Firestore,
  reportId: string,
  _reopenedBy: string,
): Promise<ModerateReportResult> {
  const reportRef = db.collection("conditionReports").doc(reportId);
  const reportSnap = await reportRef.get();
  if (!reportSnap.exists) {
    throw new HttpsError("not-found", "Report not found.");
  }

  const data = reportSnap.data()!;
  const currentStatus = resolveModerationStatus(data.moderationStatus);
  if (!isReopenEligibleStatus(currentStatus)) {
    throw new HttpsError(
      "failed-precondition",
      "Report is not eligible to return to pending.",
    );
  }

  const launchId =
    typeof data.launchId === "string" ? data.launchId : undefined;
  if (!launchId) {
    throw new HttpsError("failed-precondition", "Report missing launchId.");
  }

  await reportRef.update({
    moderationStatus: MODERATION_STATUS_HELD,
    moderationReason: MODERATION_REASON_ADMIN_REOPEN,
    moderationReviewed: false,
    reviewedAt: admin.firestore.FieldValue.delete(),
    reviewedBy: admin.firestore.FieldValue.delete(),
  });

  await invalidateLaunchDigest(db, launchId);

  return { moderationStatus: MODERATION_STATUS_HELD, launchId };
}

export function httpsErrorCode(error: unknown): string {
  if (error instanceof HttpsError) {
    return error.code;
  }
  return "internal";
}

export async function moderateHeldReportsBatch(
  db: FirebaseFirestore.Firestore,
  reportIds: string[],
  action: ModerateAction,
  reviewedBy: string,
): Promise<{
  succeeded: string[];
  failed: BatchModerateFailure[];
}> {
  const succeeded: string[] = [];
  const failed: BatchModerateFailure[] = [];

  for (const reportId of reportIds) {
    try {
      await moderateHeldReport(db, reportId, action, reviewedBy);
      succeeded.push(reportId);
    } catch (error: unknown) {
      failed.push({ reportId, code: httpsErrorCode(error) });
    }
  }

  return { succeeded, failed };
}

export function buildPendingReportsQuery(
  db: FirebaseFirestore.Firestore,
  options: {
    launchId?: string;
    createdAfter?: Date;
    createdBefore?: Date;
    sort: PendingSort;
    limit: number;
  },
): FirebaseFirestore.Query {
  let query: FirebaseFirestore.Query = db
    .collection("conditionReports")
    .where("moderationStatus", "==", MODERATION_STATUS_HELD);

  if (options.launchId) {
    query = query.where("launchId", "==", options.launchId);
  }
  if (options.createdAfter) {
    query = query.where(
      "createdAt",
      ">=",
      admin.firestore.Timestamp.fromDate(options.createdAfter),
    );
  }
  if (options.createdBefore) {
    query = query.where(
      "createdAt",
      "<=",
      admin.firestore.Timestamp.fromDate(options.createdBefore),
    );
  }

  const direction = options.sort === "createdAt_desc" ? "desc" : "asc";
  return query.orderBy("createdAt", direction).limit(options.limit);
}

export function buildHistoryReportsQuery(
  db: FirebaseFirestore.Firestore,
  options: {
    launchId?: string;
    status: HistoryStatusFilter;
    reviewedAfter?: Date;
    reviewedBefore?: Date;
    sort: HistorySort;
    limit: number;
  },
): FirebaseFirestore.Query {
  let query: FirebaseFirestore.Query = db
    .collection("conditionReports")
    .where("moderationReviewed", "==", true);

  if (options.status !== "all") {
    query = query.where("moderationStatus", "==", options.status);
  }
  if (options.launchId) {
    query = query.where("launchId", "==", options.launchId);
  }
  if (options.reviewedAfter) {
    query = query.where(
      "reviewedAt",
      ">=",
      admin.firestore.Timestamp.fromDate(options.reviewedAfter),
    );
  }
  if (options.reviewedBefore) {
    query = query.where(
      "reviewedAt",
      "<=",
      admin.firestore.Timestamp.fromDate(options.reviewedBefore),
    );
  }

  const direction = options.sort === "reviewedAt_asc" ? "asc" : "desc";
  return query.orderBy("reviewedAt", direction).limit(options.limit);
}
