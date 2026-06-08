#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$REPO_ROOT"

echo "=== Architecture Check ==="

ERRORS=0

# Feature packages: presentation must not import data/ (relative or package src URI).
for pkg in packages/features/*/; do
  if [ ! -d "$pkg/lib/src/presentation" ] || [ ! -d "$pkg/lib/src/data" ]; then continue; fi

  pkg_name=$(basename "$pkg")
  if grep -rE "import ['\"](\.\./)+data/|import 'package:[^']+/src/data/" \
    "$pkg/lib/src/presentation/" --include="*.dart" 2>/dev/null; then
    echo "ERROR: $pkg_name/presentation/ imports from data/ (use domain/ providers only)"
    ERRORS=$((ERRORS + 1))
  fi
done

# Feature packages: data → domain only (no presentation/).
for pkg in packages/features/*/; do
  if [ ! -d "$pkg/lib/src/data" ] || [ ! -d "$pkg/lib/src/presentation" ]; then continue; fi

  pkg_name=$(basename "$pkg")
  if grep -r "import.*presentation/" "$pkg/lib/src/data/" --include="*.dart" 2>/dev/null; then
    echo "ERROR: $pkg_name/data/ imports from presentation/"
    ERRORS=$((ERRORS + 1))
  fi
done

# Feature packages: domain has no presentation/ or data/ imports.
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

# App must not reach into feature implementation layers (barrel exports only).
if grep -rE "import 'package:eddyscout_(map|conditions|hydro_routing)/src/(data|presentation|domain)/" \
  apps/eddyscout/lib --include="*.dart" 2>/dev/null; then
  echo "ERROR: apps/eddyscout imports feature src/ layers (use package barrel exports)"
  ERRORS=$((ERRORS + 1))
fi

# Shared packages must not depend on feature packages.
for shared in packages/core packages/design_system packages/networking \
  packages/persistence packages/analytics packages/routing packages/localization; do
  if [ ! -d "$shared/lib" ]; then continue; fi
  shared_name=$(basename "$shared")
  if grep -rE "import 'package:eddyscout_(map|conditions|hydro_routing)/" \
    "$shared/lib" --include="*.dart" 2>/dev/null; then
    echo "ERROR: $shared_name imports a feature package"
    ERRORS=$((ERRORS + 1))
  fi
done

if [ $ERRORS -gt 0 ]; then
  echo ""
  echo "FAILED: $ERRORS architecture violation(s) found."
  exit 1
fi

echo "Architecture check OK."
