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
echo "--- Analyze (staged packages) ---"
# Package-scoped analysis respects analysis_options excludes (*.g.dart, etc.).
# Direct file analysis bypasses those excludes and fails on generated code.
PACKAGE_DIRS=$(
  echo "$STAGED_FILES" | while IFS= read -r file; do
    dir="$(dirname "$file")"
    while [ "$dir" != "." ]; do
      if [ -f "$dir/pubspec.yaml" ]; then
        echo "$dir"
        break
      fi
      dir="$(dirname "$dir")"
    done
  done | sort -u
)

if [ -z "$PACKAGE_DIRS" ]; then
  echo "$STAGED_FILES" | xargs dart analyze --fatal-infos
else
  echo "$PACKAGE_DIRS" | while IFS= read -r pkg; do
    echo "Analyzing $pkg..."
    dart analyze --fatal-infos "$pkg"
  done
fi

echo ""
echo "=== Pre-commit PASSED ==="
