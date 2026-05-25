#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
# shellcheck source=_env.sh
source "$SCRIPT_DIR/_env.sh"
cd "$REPO_ROOT"

STAGED_ONLY=false
CI_MODE=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --staged) STAGED_ONLY=true; shift ;;
    --ci) CI_MODE=true; shift ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

echo "=== EddyScout Preflight ==="

# Format check
echo ""
echo "--- Format Check ---"
if $STAGED_ONLY; then
  STAGED_FILES=$(git diff --cached --name-only --diff-filter=ACMR -- '*.dart' || true)
  if [ -n "$STAGED_FILES" ]; then
    echo "$STAGED_FILES" | xargs dart format --set-exit-if-changed
  else
    echo "No staged Dart files."
  fi
else
  melos exec -- "dart format --set-exit-if-changed ."
fi

# Static analysis
echo ""
echo "--- Static Analysis ---"
# Packages first (excludes app), then app separately (workspace layout).
melos exec --ignore=eddyscout -- "dart analyze --fatal-infos"
melos exec --scope=eddyscout -- "dart analyze --fatal-infos"

# Tests
echo ""
echo "--- Tests ---"
melos exec --fail-fast --concurrency=1 --dir-exists=test -- "flutter test"

# Codegen verification (skip for staged-only mode)
if ! $STAGED_ONLY; then
  echo ""
  echo "--- Codegen Verification ---"
  "$SCRIPT_DIR/codegen_verify.sh"
fi

echo ""
echo "=== Preflight PASSED ==="
