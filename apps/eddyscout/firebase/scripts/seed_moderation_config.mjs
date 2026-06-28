#!/usr/bin/env node
/**
 * Seeds config/moderation and backfills legacy conditionReports.
 *
 * Requires: gcloud logged in (`gcloud auth login`) with access to the project.
 *
 * Usage:
 *   node firebase/scripts/seed_moderation_config.mjs
 *   node firebase/scripts/seed_moderation_config.mjs --project eddyscout-c29b9
 *   node firebase/scripts/seed_moderation_config.mjs --dry-run
 */

import { execSync } from 'node:child_process';

const args = process.argv.slice(2);
const dryRun = args.includes('--dry-run');
const projectFlagIndex = args.indexOf('--project');
const projectId =
  projectFlagIndex >= 0 ? args[projectFlagIndex + 1] : 'eddyscout-c29b9';

const moderationDoc = {
  fields: {
    retentionDays: { integerValue: '90' },
    holdMaxDays: { integerValue: '30' },
    adminUids: { arrayValue: { values: [] } },
    keywords: {
      arrayValue: { values: [{ stringValue: 'testhold' }] },
    },
  },
};

function accessToken() {
  return execSync('gcloud auth print-access-token', { encoding: 'utf8' }).trim();
}

async function firestoreRequest(path, { method = 'GET', body } = {}) {
  const url = `https://firestore.googleapis.com/v1/projects/${projectId}/databases/(default)/documents/${path}`;
  const response = await fetch(url, {
    method,
    headers: {
      Authorization: `Bearer ${accessToken()}`,
      'Content-Type': 'application/json',
    },
    body: body ? JSON.stringify(body) : undefined,
  });
  const text = await response.text();
  if (!response.ok) {
    throw new Error(`${method} ${path} failed (${response.status}): ${text}`);
  }
  return text ? JSON.parse(text) : null;
}

async function seedModerationConfig() {
  const mask =
    'updateMask.fieldPaths=retentionDays&updateMask.fieldPaths=holdMaxDays&updateMask.fieldPaths=adminUids&updateMask.fieldPaths=keywords';
  const url =
    `https://firestore.googleapis.com/v1/projects/${projectId}` +
    `/databases/(default)/documents/config/moderation?${mask}`;

  if (dryRun) {
    console.log('[dry-run] Would upsert config/moderation:', moderationDoc);
    return;
  }

  const response = await fetch(url, {
    method: 'PATCH',
    headers: {
      Authorization: `Bearer ${accessToken()}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(moderationDoc),
  });
  const text = await response.text();
  if (!response.ok) {
    throw new Error(`PATCH config/moderation failed (${response.status}): ${text}`);
  }
  console.log('Upserted config/moderation');
}

async function backfillLegacyReports() {
  const listed = await firestoreRequest('conditionReports?pageSize=500');
  const docs = listed.documents ?? [];
  let updated = 0;

  for (const doc of docs) {
    const name = doc.name;
    const fields = doc.fields ?? {};
    if (fields.moderationStatus) {
      continue;
    }

    const createdAt = fields.createdAt?.timestampValue
      ? new Date(fields.createdAt.timestampValue)
      : new Date();
    const expiresAt = new Date(
      createdAt.getTime() + 90 * 24 * 60 * 60 * 1000,
    );

    const patchBody = {
      fields: {
        moderationStatus: { stringValue: 'approved' },
        expiresAt: { timestampValue: expiresAt.toISOString() },
      },
    };

    const docId = name.split('/').pop();
    const mask =
      'updateMask.fieldPaths=moderationStatus&updateMask.fieldPaths=expiresAt';

    if (dryRun) {
      console.log(`[dry-run] Would backfill conditionReports/${docId}`);
      updated += 1;
      continue;
    }

    const url =
      `https://firestore.googleapis.com/v1/projects/${projectId}` +
      `/databases/(default)/documents/conditionReports/${docId}?${mask}`;

    const response = await fetch(url, {
      method: 'PATCH',
      headers: {
        Authorization: `Bearer ${accessToken()}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(patchBody),
    });
    if (!response.ok) {
      const text = await response.text();
      throw new Error(`Backfill ${docId} failed (${response.status}): ${text}`);
    }
    updated += 1;
  }

  console.log(
    dryRun
      ? `[dry-run] Would backfill ${updated} legacy reports`
      : `Backfilled ${updated} legacy reports`,
  );
}

async function main() {
  console.log(`Project: ${projectId}${dryRun ? ' (dry-run)' : ''}`);
  await seedModerationConfig();
  await backfillLegacyReports();
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
