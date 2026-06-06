#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$REPO_ROOT"

echo "=== Import Boundary Check ==="

ERRORS=0

# Check: packages/ must not import from apps/
if grep -r "import 'package:eddyscout/" packages/ --include="*.dart" 2>/dev/null; then
  echo "ERROR: packages/ must not import from apps/eddyscout"
  ERRORS=$((ERRORS + 1))
fi

# Check: features must not import from other features
for feature_dir in packages/features/*/; do
  if [ ! -d "$feature_dir" ]; then continue; fi
  feature_name=$(basename "$feature_dir")
  if [ "$feature_name" = "_TEMPLATE" ]; then continue; fi

  for other_dir in packages/features/*/; do
    other_name=$(basename "$other_dir")
    if [ "$other_name" = "$feature_name" ] || [ "$other_name" = "_TEMPLATE" ]; then continue; fi
    # Map route-planning presentation delegates to hydro_routing (wave 3).
    if [ "$feature_name" = "map" ] && [ "$other_name" = "hydro_routing" ]; then continue; fi
    if grep -r "import 'package:eddyscout_$other_name/" "$feature_dir" --include="*.dart" 2>/dev/null; then
      echo "ERROR: Feature '$feature_name' imports from feature '$other_name'"
      ERRORS=$((ERRORS + 1))
    fi
  done
done

if [ $ERRORS -gt 0 ]; then
  echo ""
  echo "FAILED: $ERRORS import boundary violation(s) found."
  exit 1
fi

echo "Import boundaries OK."
