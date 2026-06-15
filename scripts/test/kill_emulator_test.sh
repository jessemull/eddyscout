#!/usr/bin/env bash
# Smoke tests for scripts/kill_emulator.sh (run from repo root).
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
KILL_SCRIPT="$ROOT/scripts/kill_emulator.sh"

assert_exit_zero() {
  local label="$1"
  shift
  if ! "$@" >/dev/null 2>&1; then
    echo "FAIL: $label — expected exit 0"
    exit 1
  fi
}

cd "$ROOT"

assert_exit_zero "no emulators running" "$KILL_SCRIPT"

assert_exit_zero "unknown EMULATOR_SERIAL" env EMULATOR_SERIAL=emulator-5554 "$KILL_SCRIPT"

echo "kill_emulator_test: OK"
