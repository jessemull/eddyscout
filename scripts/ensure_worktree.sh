#!/usr/bin/env bash
# Idempotent worktree prep: melos bootstrap + husky hooks when packages are not resolved yet.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
# shellcheck source=_env.sh
source "$SCRIPT_DIR/_env.sh"
cd "$REPO_ROOT"

needs_bootstrap() {
  [[ ! -d "$REPO_ROOT/.dart_tool" ]] && return 0
  [[ ! -d "$REPO_ROOT/apps/eddyscout/.dart_tool" ]] && return 0
  return 1
}

if needs_bootstrap; then
  echo "worktree: packages not bootstrapped — running ./scripts/bootstrap.sh"
  "$SCRIPT_DIR/bootstrap.sh"
else
  echo "worktree: packages OK"
  "$SCRIPT_DIR/ensure_husky.sh"
fi
