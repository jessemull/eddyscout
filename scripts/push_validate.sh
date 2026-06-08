#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$REPO_ROOT"
# Git worktrees inject GIT_DIR into hooks; melos/dart resolve Flutter SDK incorrectly.
unset GIT_DIR GIT_WORK_TREE

echo "=== Push Validation ==="

# Full preflight without coverage (coverage enforced in CI).
"$SCRIPT_DIR/preflight.sh" --no-coverage

"$SCRIPT_DIR/check_imports.sh"
"$SCRIPT_DIR/check_architecture.sh"

echo ""
echo "=== Push Validation PASSED ==="
