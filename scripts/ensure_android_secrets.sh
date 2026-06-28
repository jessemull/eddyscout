#!/usr/bin/env bash
# Symlink gitignored android/app/google-services.json from sibling worktrees
# or a canonical secrets dir (see fetch_google_services.sh).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
# shellcheck source=_worktree_helpers.sh
source "$SCRIPT_DIR/_worktree_helpers.sh"
APP_ROOT="$REPO_ROOT/apps/eddyscout"
GOOGLE_SERVICES="$APP_ROOT/android/app/google-services.json"
FIREBASERC="$APP_ROOT/.firebaserc"
SECRETS_DIR="${EDDYSCOUT_SECRETS_DIR:-$HOME/.config/eddyscout}"

uses_firebase() {
  local env_file="$APP_ROOT/.local.env"
  [[ -f "$env_file" ]] || return 1
  # shellcheck disable=SC1090,SC1091
  set -a
  source "$env_file"
  set +a
  [[ "${USE_FIREBASE:-}" == "true" ]]
}

link_google_services() {
  local source="$1"
  echo "google-services.json: linking $GOOGLE_SERVICES -> $source"
  ln -sf "$source" "$GOOGLE_SERVICES"
}

resolve_canonical_google_services() {
  if [[ -n "${EDDYSCOUT_GOOGLE_SERVICES:-}" && -f "$EDDYSCOUT_GOOGLE_SERVICES" ]]; then
    echo "$EDDYSCOUT_GOOGLE_SERVICES"
    return 0
  fi

  if [[ ! -d "$SECRETS_DIR" ]]; then
    return 1
  fi

  local project_id alias
  if [[ -n "${EDDYSCOUT_FIREBASE_PROJECT:-}" ]]; then
    project_id="$EDDYSCOUT_FIREBASE_PROJECT"
  elif [[ -f "$FIREBASERC" ]]; then
    alias="${EDDYSCOUT_FIREBASE_ALIAS:-mvp}"
    project_id="$(
      node -e "
        const fs = require('fs');
        const rc = JSON.parse(fs.readFileSync(process.argv[1], 'utf8'));
        const id = rc.projects?.[process.argv[2]];
        if (id) process.stdout.write(id);
      " "$FIREBASERC" "$alias" 2>/dev/null || true
    )"
  fi

  if [[ -n "$project_id" && -f "$SECRETS_DIR/google-services-${project_id}.json" ]]; then
    echo "$SECRETS_DIR/google-services-${project_id}.json"
    return 0
  fi

  # Any cached project file (single-machine dev with one Firebase project).
  local cached
  cached="$(find "$SECRETS_DIR" -maxdepth 1 -name 'google-services-*.json' -print 2>/dev/null | head -1)"
  if [[ -n "$cached" && -f "$cached" ]]; then
    echo "$cached"
    return 0
  fi

  return 1
}

try_fetch_google_services() {
  if [[ "${EDDYSCOUT_FETCH_GOOGLE_SERVICES:-}" == "0" ]]; then
    return 1
  fi
  if ! command -v firebase >/dev/null 2>&1; then
    return 1
  fi
  if ! fetched="$("$SCRIPT_DIR/fetch_google_services.sh")"; then
    return 1
  fi
  if [[ -f "$fetched" ]]; then
    echo "$fetched"
    return 0
  fi
  return 1
}

cd "$REPO_ROOT"

if [[ -f "$GOOGLE_SERVICES" ]]; then
  echo "google-services.json: OK ($GOOGLE_SERVICES)"
  exit 0
fi

if canonical="$(resolve_canonical_google_services)"; then
  link_google_services "$canonical"
  exit 0
fi

if sibling="$(find_sibling_worktree_file "$REPO_ROOT" "apps/eddyscout/android/app/google-services.json")"; then
  link_google_services "$sibling"
  exit 0
fi

if uses_firebase && fetched="$(try_fetch_google_services)"; then
  link_google_services "$fetched"
  exit 0
fi

if uses_firebase; then
  cat <<EOF
WARNING: USE_FIREBASE=true but google-services.json is missing.

One-time setup (recommended — shared across all git worktrees):

  firebase login
  make fetch-google-services

That downloads to ~/.config/eddyscout/google-services-<project>.json and symlinks here.
Re-run make dev / make run to link automatically in new worktrees.

Manual alternatives:
  export EDDYSCOUT_GOOGLE_SERVICES=/path/to/google-services.json
  Firebase Console → Project settings → Your apps → Download google-services.json
    → apps/eddyscout/android/app/google-services.json

Then stop the app fully and run make dev again (full rebuild, not hot reload).
EOF
fi
