import * as admin from "firebase-admin";
import { CallableRequest, HttpsError } from "firebase-functions/v2/https";

export type ModerationStatus = "approved" | "held" | "rejected";

export interface ModerationConfig {
  retentionDays: number;
  adminUids: string[];
  keywords: string[];
}

export const DEFAULT_RETENTION_DAYS = 90;

export const DEFAULT_KEYWORDS: string[] = [];

export const MODERATION_CONFIG_PATH = "config/moderation";

export const MODERATION_STATUS_APPROVED: ModerationStatus = "approved";
export const MODERATION_STATUS_HELD: ModerationStatus = "held";
export const MODERATION_STATUS_REJECTED: ModerationStatus = "rejected";

export function defaultModerationConfig(): ModerationConfig {
  return {
    retentionDays: DEFAULT_RETENTION_DAYS,
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

  const adminUids = Array.isArray(data.adminUids)
    ? data.adminUids.filter((uid): uid is string => typeof uid === "string")
    : defaults.adminUids;

  const keywords = Array.isArray(data.keywords)
    ? data.keywords.filter((word): word is string => typeof word === "string")
    : defaults.keywords;

  return { retentionDays, adminUids, keywords };
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
