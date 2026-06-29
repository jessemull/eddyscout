#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$REPO_ROOT"
# Git worktrees inject GIT_DIR into hooks; melos/dart resolve Flutter SDK incorrectly.
unset GIT_DIR GIT_WORK_TREE

echo "=== Push Validation ==="

# Affected tests vs origin/main when safe; full suite on global config changes.
# Optional: PUSH_VALIDATE_AFFECTED=1 always uses affected tests (if origin/main exists).
# Optional: PUSH_VALIDATE_JOBS=N caps parallel melos package jobs (default: min(ncpu, 8)).
export PUSH_VALIDATE_AUTO_AFFECTED=1
"$SCRIPT_DIR/preflight.sh" --no-coverage

echo ""
echo "=== Push Validation PASSED ==="
