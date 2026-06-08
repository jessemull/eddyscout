#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$REPO_ROOT"

echo "=== Push Validation ==="

# Optional: PUSH_VALIDATE_AUTO_AFFECTED=1 runs --since=origin/main tests when safe.
# Optional: PUSH_VALIDATE_AFFECTED=1 always uses affected tests (if origin/main exists).
# Optional: PUSH_VALIDATE_JOBS=N caps parallel melos package jobs (default: min(ncpu, 8)).
"$SCRIPT_DIR/preflight.sh" --no-coverage

echo ""
echo "=== Push Validation PASSED ==="
