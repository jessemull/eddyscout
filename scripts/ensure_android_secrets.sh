#!/usr/bin/env bash
# Symlink gitignored android/app/google-services.json from sibling worktrees.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
GOOGLE_SERVICES="$REPO_ROOT/apps/eddyscout/android/app/google-services.json"

find_sibling_google_services() {
  local wt_path candidate
  while IFS= read -r wt_path; do
    [[ "$wt_path" == "$REPO_ROOT" ]] && continue
    candidate="$wt_path/apps/eddyscout/android/app/google-services.json"
    if [[ -f "$candidate" ]]; then
      echo "$candidate"
      return 0
    fi
  done < <(git -C "$REPO_ROOT" worktree list --porcelain 2>/dev/null | awk '/^worktree /{print $2}')
  return 1
}

uses_firebase() {
  local env_file="$REPO_ROOT/apps/eddyscout/.local.env"
  [[ -f "$env_file" ]] || return 1
  # shellcheck disable=SC1090,SC1091
  set -a
  source "$env_file"
  set +a
  [[ "${USE_FIREBASE:-}" == "true" ]]
}

cd "$REPO_ROOT"

if [[ -f "$GOOGLE_SERVICES" ]]; then
  echo "google-services.json: OK ($GOOGLE_SERVICES)"
  exit 0
fi

if [[ -n "${EDDYSCOUT_GOOGLE_SERVICES:-}" && -f "$EDDYSCOUT_GOOGLE_SERVICES" ]]; then
  echo "google-services.json: linking $GOOGLE_SERVICES -> $EDDYSCOUT_GOOGLE_SERVICES"
  ln -sf "$EDDYSCOUT_GOOGLE_SERVICES" "$GOOGLE_SERVICES"
  exit 0
fi

if sibling="$(find_sibling_google_services)"; then
  echo "google-services.json: linking $GOOGLE_SERVICES -> $sibling"
  ln -sf "$sibling" "$GOOGLE_SERVICES"
  exit 0
fi

if uses_firebase; then
  cat <<EOF
WARNING: USE_FIREBASE=true but google-services.json is missing.

Firebase AI summaries and condition reports will not work until you add:
  apps/eddyscout/android/app/google-services.json

Download from Firebase Console, copy from your main clone, or:
  export EDDYSCOUT_GOOGLE_SERVICES=/path/to/google-services.json

Then stop the app fully and run make dev again (full rebuild, not hot reload).
EOF
fi
