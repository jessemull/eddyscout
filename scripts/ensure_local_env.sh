#!/usr/bin/env bash
# Ensure apps/eddyscout/.local.env exists (symlink or copy). Never overwrites a populated file.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
# shellcheck source=_worktree_helpers.sh
source "$SCRIPT_DIR/_worktree_helpers.sh"
APP_ROOT="$REPO_ROOT/apps/eddyscout"
LOCAL_ENV="$APP_ROOT/.local.env"
EXAMPLE_ENV="$APP_ROOT/env.example"

has_mapbox_token() {
  local file="$1"
  [[ -f "$file" ]] || return 1
  # shellcheck disable=SC1090
  set -a
  # shellcheck disable=SC1091
  source "$file"
  set +a
  [[ -n "${MAPBOX_ACCESS_TOKEN:-}" ]]
}

link_local_env() {
  local source="$1"
  echo "local.env: linking $LOCAL_ENV -> $source"
  ln -sf "$source" "$LOCAL_ENV"
}

cd "$REPO_ROOT"

if [[ -f "$LOCAL_ENV" ]] && has_mapbox_token "$LOCAL_ENV"; then
  echo "local.env: OK ($LOCAL_ENV)"
  exit 0
fi

if [[ -n "${EDDYSCOUT_LOCAL_ENV:-}" && -f "$EDDYSCOUT_LOCAL_ENV" ]]; then
  link_local_env "$EDDYSCOUT_LOCAL_ENV"
  exit 0
fi

if sibling="$(find_sibling_worktree_file "$REPO_ROOT" "apps/eddyscout/.local.env")" \
  && has_mapbox_token "$sibling"; then
  link_local_env "$sibling"
  exit 0
fi

if [[ ! -f "$LOCAL_ENV" ]]; then
  cp "$EXAMPLE_ENV" "$LOCAL_ENV"
  echo "local.env: created $LOCAL_ENV from env.example"
fi

if has_mapbox_token "$LOCAL_ENV"; then
  echo "local.env: OK ($LOCAL_ENV)"
  exit 0
fi

cat <<EOF
ERROR: MAPBOX_ACCESS_TOKEN is missing in $LOCAL_ENV

Set it once in your main clone, then re-run make dev (sibling worktrees are linked automatically), or:

  export EDDYSCOUT_LOCAL_ENV=/path/to/your/.local.env
  make dev

Or edit $LOCAL_ENV and add MAPBOX_ACCESS_TOKEN=pk....
EOF
exit 1
