#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$REPO_ROOT"

echo "=== Push Validation ==="

# Full preflight without coverage (coverage enforced in CI).
"$SCRIPT_DIR/preflight.sh" --no-coverage

echo ""
echo "=== Push Validation PASSED ==="
