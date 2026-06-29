#!/usr/bin/env bash
# Download android/app/google-services.json via Firebase CLI (firebase login).
#
# Writes a canonical copy outside the repo so every git worktree can symlink it.
# Not for CI — use checked-in paths or CI secrets for release builds.
#
# Usage:
#   make fetch-google-services
#   EDDYSCOUT_FIREBASE_ALIAS=mvp make fetch-google-services
#   EDDYSCOUT_FIREBASE_PROJECT=eddyscout-c29b9 ./scripts/fetch_google_services.sh
#
# Requires: firebase-tools (`npm i -g firebase-tools` or npx), `firebase login`
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
APP_ROOT="$REPO_ROOT/apps/eddyscout"
FIREBASERC="$APP_ROOT/.firebaserc"
ANDROID_PACKAGE="${EDDYSCOUT_ANDROID_PACKAGE:-com.eddyscout.eddyscout}"
SECRETS_DIR="${EDDYSCOUT_SECRETS_DIR:-$HOME/.config/eddyscout}"

resolve_firebase_project() {
  if [[ -n "${EDDYSCOUT_FIREBASE_PROJECT:-}" ]]; then
    echo "$EDDYSCOUT_FIREBASE_PROJECT"
    return 0
  fi

  local alias="${EDDYSCOUT_FIREBASE_ALIAS:-mvp}"
  if [[ ! -f "$FIREBASERC" ]]; then
    echo "ERROR: missing $FIREBASERC" >&2
    return 1
  fi

  local project_id
  project_id="$(
    node -e "
      const fs = require('fs');
      const rc = JSON.parse(fs.readFileSync(process.argv[1], 'utf8'));
      const alias = process.argv[2];
      const id = rc.projects?.[alias];
      if (!id) {
        process.stderr.write('Unknown alias \"' + alias + '\" in .firebaserc\\n');
        process.exit(1);
      }
      process.stdout.write(id);
    " "$FIREBASERC" "$alias"
  )"
  echo "$project_id"
}

resolve_android_app_id() {
  local project_id="$1"
  local json
  if ! json="$(firebase apps:list ANDROID --project "$project_id" --json 2>/dev/null)"; then
    echo "ERROR: firebase apps:list failed for project $project_id" >&2
    echo "Run: firebase login" >&2
    return 1
  fi

  node -e "
    const payload = JSON.parse(process.argv[1]);
    const pkg = process.argv[2];
    const apps = payload.result ?? [];
    const androidApps = apps.filter((a) => String(a.platform).toUpperCase() === 'ANDROID');
    if (androidApps.length === 0) {
      process.stderr.write(
        'No Android app in Firebase project. Register \"' + pkg +
        '\" in Firebase Console → Project settings → Your apps, then re-run.\\n',
      );
      process.exit(1);
    }
    const match =
      androidApps.find((a) => a.namespace === pkg) ??
      androidApps.find((a) => a.bundleId === pkg) ??
      (androidApps.length === 1 ? androidApps[0] : null);
    if (!match) {
      process.stderr.write(
        'Multiple Android apps; set EDDYSCOUT_FIREBASE_ANDROID_APP_ID explicitly.\\n',
      );
      process.exit(1);
    }
    process.stdout.write(match.appId);
  " "$json" "$ANDROID_PACKAGE"
}

main() {
  if ! command -v firebase >/dev/null 2>&1; then
    echo "ERROR: firebase CLI not found. Install: npm i -g firebase-tools" >&2
    exit 1
  fi

  local project_id app_id out_file tmp_file
  project_id="$(resolve_firebase_project)"
  app_id="$(resolve_android_app_id "$project_id")"

  mkdir -p "$SECRETS_DIR"
  out_file="$(cd "$SECRETS_DIR" && pwd)/google-services-${project_id}.json"
  # mktemp creates an empty file; firebase apps:sdkconfig refuses -o if it exists.
  # Template must end in XXXXXX only (no .json suffix — BSD mktemp breaks otherwise).
  tmp_file="$(mktemp "${TMPDIR:-/tmp}/google-services-XXXXXX")"
  rm -f "$tmp_file"
  trap 'rm -f "$tmp_file"' EXIT

  echo "fetch-google-services: project=$project_id app=$app_id" >&2
  if ! firebase apps:sdkconfig ANDROID "$app_id" --project "$project_id" -o "$tmp_file"; then
    echo "ERROR: firebase apps:sdkconfig failed" >&2
    exit 1
  fi

  if [[ ! -s "$tmp_file" ]]; then
    echo "ERROR: firebase apps:sdkconfig produced an empty file" >&2
    exit 1
  fi

  if ! mv "$tmp_file" "$out_file"; then
    echo "ERROR: could not write $out_file (check permissions on $SECRETS_DIR)" >&2
    exit 1
  fi
  trap - EXIT
  chmod 600 "$out_file" 2>/dev/null || true

  echo "fetch-google-services: wrote $out_file" >&2
  echo "$out_file"
}

main "$@"
