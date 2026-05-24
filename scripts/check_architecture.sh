#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$REPO_ROOT"

echo "=== Architecture Check ==="

ERRORS=0

# Check: presentation/ must not import from data/
for pkg in packages/features/*/; do
  if [ ! -d "$pkg/lib/src/presentation" ] || [ ! -d "$pkg/lib/src/data" ]; then continue; fi

  pkg_name=$(basename "$pkg")
  if grep -r "import.*data/" "$pkg/lib/src/presentation/" --include="*.dart" 2>/dev/null; then
    echo "ERROR: $pkg_name/presentation/ imports from data/ (must go through domain/)"
    ERRORS=$((ERRORS + 1))
  fi
done

# Check: domain/ must not import from presentation/ or data/
for pkg in packages/features/*/; do
  if [ ! -d "$pkg/lib/src/domain" ]; then continue; fi

  pkg_name=$(basename "$pkg")
  if grep -r "import.*presentation/" "$pkg/lib/src/domain/" --include="*.dart" 2>/dev/null; then
    echo "ERROR: $pkg_name/domain/ imports from presentation/"
    ERRORS=$((ERRORS + 1))
  fi
  if grep -r "import.*data/" "$pkg/lib/src/domain/" --include="*.dart" 2>/dev/null; then
    echo "ERROR: $pkg_name/domain/ imports from data/"
    ERRORS=$((ERRORS + 1))
  fi
done

if [ $ERRORS -gt 0 ]; then
  echo ""
  echo "FAILED: $ERRORS architecture violation(s) found."
  exit 1
fi

echo "Architecture check OK."
