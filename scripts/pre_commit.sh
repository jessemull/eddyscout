#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
# shellcheck source=_env.sh
source "$SCRIPT_DIR/_env.sh"
cd "$REPO_ROOT"

echo "=== Pre-commit (fast) ==="

STAGED_FILES=$(git diff --cached --name-only --diff-filter=ACMR -- '*.dart' || true)

if [ -z "$STAGED_FILES" ]; then
  echo "No staged Dart files — skipping format and analyze."
  echo "=== Pre-commit PASSED ==="
  exit 0
fi

echo ""
echo "--- Format (staged) ---"
echo "$STAGED_FILES" | xargs dart format --set-exit-if-changed

echo ""
echo "--- Analyze (staged) ---"
echo "$STAGED_FILES" | xargs dart analyze --fatal-infos

echo ""
echo "=== Pre-commit PASSED ==="
