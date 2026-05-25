#!/usr/bin/env bash
# Enforces per-package line coverage floors from tooling/coverage.yaml.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
# shellcheck source=_env.sh
source "$SCRIPT_DIR/_env.sh"
cd "$REPO_ROOT"

CONFIG="$REPO_ROOT/tooling/coverage.yaml"
if [[ ! -f "$CONFIG" ]]; then
  echo "ERROR: missing $CONFIG"
  exit 1
fi

echo "=== Coverage Threshold Check ==="

FAILURES=0

while IFS= read -r line; do
  [[ "$line" =~ ^[[:space:]]*([a-zA-Z0-9_]+):[[:space:]]*([0-9]+) ]] || continue
  pkg="${BASH_REMATCH[1]}"
  min="${BASH_REMATCH[2]}"

  if [[ "$min" -eq 0 ]]; then
    echo "SKIP: $pkg (threshold 0 — no coverage gate)"
    continue
  fi

  lcov=""
  for candidate in \
    "$REPO_ROOT/apps/eddyscout/coverage/lcov.info" \
    "$REPO_ROOT/packages/core/coverage/lcov.info" \
    "$REPO_ROOT/packages/design_system/coverage/lcov.info" \
    "$REPO_ROOT/packages/networking/coverage/lcov.info" \
    "$REPO_ROOT/packages/persistence/coverage/lcov.info" \
    "$REPO_ROOT/packages/analytics/coverage/lcov.info" \
    "$REPO_ROOT/packages/routing/coverage/lcov.info" \
    "$REPO_ROOT/packages/localization/coverage/lcov.info" \
    "$REPO_ROOT/packages/features/conditions/coverage/lcov.info" \
    "$REPO_ROOT/packages/features/map/coverage/lcov.info" \
    "$REPO_ROOT/packages/features/hydro_routing/coverage/lcov.info"; do
    :
  done

  # Resolve package directory from melos name.
  case "$pkg" in
    eddyscout) dir="$REPO_ROOT/apps/eddyscout" ;;
    eddyscout_core) dir="$REPO_ROOT/packages/core" ;;
    eddyscout_design_system) dir="$REPO_ROOT/packages/design_system" ;;
    eddyscout_networking) dir="$REPO_ROOT/packages/networking" ;;
    eddyscout_persistence) dir="$REPO_ROOT/packages/persistence" ;;
    eddyscout_analytics) dir="$REPO_ROOT/packages/analytics" ;;
    eddyscout_routing) dir="$REPO_ROOT/packages/routing" ;;
    eddyscout_localization) dir="$REPO_ROOT/packages/localization" ;;
    eddyscout_conditions) dir="$REPO_ROOT/packages/features/conditions" ;;
    eddyscout_map) dir="$REPO_ROOT/packages/features/map" ;;
    eddyscout_hydro_routing) dir="$REPO_ROOT/packages/features/hydro_routing" ;;
    *) continue ;;
  esac

  lcov="$dir/coverage/lcov.info"
  if [[ ! -f "$lcov" ]]; then
    echo "WARN: $pkg — no $lcov (run make coverage first); skipping"
    continue
  fi

  # Sum LH and LF from lcov records (line coverage).
  read -r hit total < <(
    awk '
      /^LF:/ { lf += int(substr($0, 4)) }
      /^LH:/ { lh += int(substr($0, 4)) }
      END { print lh + 0, lf + 0 }
    ' "$lcov"
  )

  if [[ "$total" -eq 0 ]]; then
    echo "WARN: $pkg — no line records in $lcov; skipping"
    continue
  fi

  pct=$((hit * 100 / total))

  if [[ "$pct" -lt "$min" ]]; then
    echo "FAIL: $pkg coverage ${pct}% < required ${min}% ($hit/$total lines)"
    FAILURES=$((FAILURES + 1))
  else
    echo "OK: $pkg coverage ${pct}% (min ${min}%)"
  fi
done < <(grep -E '^[[:space:]]+[a-zA-Z0-9_]+:[[:space:]]+[0-9]+' "$CONFIG" || true)

if [[ $FAILURES -gt 0 ]]; then
  echo ""
  echo "FAILED: $FAILURES package(s) below coverage threshold."
  exit 1
fi

echo "Coverage thresholds satisfied."
