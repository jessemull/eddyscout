#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$REPO_ROOT"

echo "--- Verifying generated code is up to date ---"

# Run code generation
"$SCRIPT_DIR/codegen.sh" 2>/dev/null || true

# Check for uncommitted changes in generated files
DIRTY=$(git status --porcelain -- '*.g.dart' '*.freezed.dart' '*.gr.dart' 2>/dev/null || true)

if [ -n "$DIRTY" ]; then
  echo "ERROR: Generated files are out of date:"
  echo "$DIRTY"
  echo ""
  echo "Run 'make gen' and commit the changes."
  exit 1
fi

echo "Generated code is up to date."
