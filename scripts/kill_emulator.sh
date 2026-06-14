#!/usr/bin/env bash
# make kill-emulator — stop running Android emulators (adb emu kill).
#
# Usage:
#   make kill-emulator
#   EMULATOR_SERIAL=emulator-5554 make kill-emulator
set -euo pipefail

ANDROID_HOME="${ANDROID_HOME:-$HOME/Library/Android/sdk}"
ADB="${ANDROID_HOME}/platform-tools/adb"

if [[ -x "$ADB" ]]; then
  ADB_CMD=("$ADB")
elif command -v adb >/dev/null 2>&1; then
  ADB_CMD=(adb)
else
  echo "ERROR: adb not found (set ANDROID_HOME or install platform-tools)" >&2
  exit 1
fi

kill_emulator() {
  local serial="$1"
  echo "kill-emulator: stopping $serial" >&2
  if ! "${ADB_CMD[@]}" -s "$serial" emu kill >/dev/null 2>&1; then
    echo "kill-emulator: adb emu kill failed for $serial; trying disconnect" >&2
    "${ADB_CMD[@]}" -s "$serial" disconnect "$serial" >/dev/null 2>&1 || true
  fi
}

if [[ -n "${EMULATOR_SERIAL:-}" ]]; then
  kill_emulator "$EMULATOR_SERIAL"
  exit 0
fi

killed=0
while IFS= read -r serial; do
  [[ -z "$serial" ]] && continue
  kill_emulator "$serial"
  killed=$((killed + 1))
done < <(
  "${ADB_CMD[@]}" devices 2>/dev/null |
    awk '/^emulator-[0-9]+[[:space:]]+(device|offline)/ { print $1 }'
)

if (( killed == 0 )); then
  echo "kill-emulator: no running Android emulators found" >&2
  exit 0
fi

echo "kill-emulator: stopped $killed emulator(s)" >&2
