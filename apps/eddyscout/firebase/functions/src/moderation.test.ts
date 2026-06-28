import assert from "node:assert/strict";
import { describe, test } from "node:test";
import * as admin from "firebase-admin";
import {
  computeExpiresAt,
  computeHoldAgeDays,
  defaultModerationConfig,
  evaluateKeywordHold,
  isModerator,
  isPubliclyVisibleStatus,
  isReopenEligibleStatus,
  isStaleHold,
  parseModerationConfig,
  resolveModerationStatus,
  staleHoldCutoff,
} from "./moderation.js";

describe("evaluateKeywordHold", () => {
  test("returns held false for empty keywords", () => {
    assert.deepEqual(evaluateKeywordHold("hello world", []), { held: false });
  });

  test("matches whole words case-insensitively", () => {
    const result = evaluateKeywordHold("There is SPAM in the water", ["spam"]);
    assert.equal(result.held, true);
    assert.equal(result.matchedKeyword, "spam");
  });

  test("does not match substrings inside words", () => {
    const result = evaluateKeywordHold("classical music", ["ass"]);
    assert.equal(result.held, false);
  });

  test("matches one of several keywords", () => {
    const result = evaluateKeywordHold("report abuse here", ["spam", "abuse"]);
    assert.equal(result.held, true);
    assert.equal(result.matchedKeyword, "abuse");
  });
});

describe("parseModerationConfig", () => {
  test("uses defaults when doc missing", () => {
    const config = parseModerationConfig(undefined);
    assert.equal(config.retentionDays, 90);
    assert.equal(config.holdMaxDays, 30);
    assert.deepEqual(config.adminUids, []);
    assert.deepEqual(config.keywords, []);
  });

  test("parses valid fields", () => {
    const config = parseModerationConfig({
      retentionDays: 30,
      holdMaxDays: 14,
      adminUids: ["uid-a", 1],
      keywords: ["spam", null],
    });
    assert.equal(config.retentionDays, 30);
    assert.equal(config.holdMaxDays, 14);
    assert.deepEqual(config.adminUids, ["uid-a"]);
    assert.deepEqual(config.keywords, ["spam"]);
  });
});

describe("isModerator", () => {
  test("checks admin uid membership", () => {
    const config = defaultModerationConfig();
    config.adminUids = ["mod-1"];
    assert.equal(isModerator("mod-1", config), true);
    assert.equal(isModerator("other", config), false);
  });
});

describe("resolveModerationStatus", () => {
  test("maps known statuses", () => {
    assert.equal(resolveModerationStatus("approved"), "approved");
    assert.equal(resolveModerationStatus("held"), "held");
    assert.equal(resolveModerationStatus("rejected"), "rejected");
    assert.equal(resolveModerationStatus(undefined), null);
  });
});

describe("isPubliclyVisibleStatus", () => {
  test("treats missing status as visible for legacy docs", () => {
    assert.equal(isPubliclyVisibleStatus(null), true);
  });

  test("only approved is visible", () => {
    assert.equal(isPubliclyVisibleStatus("approved"), true);
    assert.equal(isPubliclyVisibleStatus("held"), false);
    assert.equal(isPubliclyVisibleStatus("rejected"), false);
  });
});

describe("isReopenEligibleStatus", () => {
  test("allows approved and rejected reports", () => {
    assert.equal(isReopenEligibleStatus("approved"), true);
    assert.equal(isReopenEligibleStatus("rejected"), true);
  });

  test("rejects held and unknown statuses", () => {
    assert.equal(isReopenEligibleStatus("held"), false);
    assert.equal(isReopenEligibleStatus(null), false);
  });
});

describe("computeExpiresAt", () => {
  test("adds retention days", () => {
    const createdAt = admin.firestore.Timestamp.fromMillis(0);
    const expiresAt = computeExpiresAt(createdAt, 90);
    assert.equal(expiresAt.toMillis(), 90 * 24 * 60 * 60 * 1000);
  });
});

describe("hold timeout helpers", () => {
  test("computeHoldAgeDays counts full days", () => {
    const createdAt = admin.firestore.Timestamp.fromMillis(0);
    const now = admin.firestore.Timestamp.fromMillis(3 * 24 * 60 * 60 * 1000);
    assert.equal(computeHoldAgeDays(createdAt, now), 3);
  });

  test("isStaleHold is true at holdMaxDays", () => {
    const createdAt = admin.firestore.Timestamp.fromMillis(0);
    const now = admin.firestore.Timestamp.fromMillis(30 * 24 * 60 * 60 * 1000);
    assert.equal(isStaleHold(createdAt, 30, now), true);
  });

  test("staleHoldCutoff subtracts holdMaxDays from now", () => {
    const now = admin.firestore.Timestamp.fromMillis(60 * 24 * 60 * 60 * 1000);
    const cutoff = staleHoldCutoff(30, now);
    assert.equal(cutoff.toMillis(), 30 * 24 * 60 * 60 * 1000);
  });
});
