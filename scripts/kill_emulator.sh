#!/usr/bin/env bash
# make kill-emulator — stop Android emulators started by adb or dev.sh.
#
# dev.sh launches "$ANDROID_HOME/emulator/emulator -avd …" in the background.
# adb emu kill only stops the guest; if adb loses the device, qemu can keep running.
# This script tries adb first, then terminates orphan emulator/qemu processes under
# ANDROID_HOME.
#
# Usage:
#   make kill-emulator
#   EMULATOR_SERIAL=emulator-5554 make kill-emulator
set -euo pipefail

ANDROID_HOME="${ANDROID_HOME:-$HOME/Library/Android/sdk}"
ADB="${ANDROID_HOME}/platform-tools/adb"
EMULATOR_HOME="$ANDROID_HOME/emulator"

if [[ -x "$ADB" ]]; then
  ADB_CMD=("$ADB")
elif command -v adb >/dev/null 2>&1; then
  ADB_CMD=(adb)
else
  echo "ERROR: adb not found (set ANDROID_HOME or install platform-tools)" >&2
  exit 1
fi

kill_via_adb() {
  local serial="$1"
  echo "kill-emulator: adb emu kill $serial" >&2
  if ! "${ADB_CMD[@]}" -s "$serial" emu kill >/dev/null 2>&1; then
    echo "kill-emulator: adb emu kill failed for $serial" >&2
    "${ADB_CMD[@]}" -s "$serial" disconnect "$serial" >/dev/null 2>&1 || true
  fi
}

# pgrep -f pattern (macOS + Linux). Returns nothing when no matches.
_pgrep_pids() {
  local pattern="$1"
  pgrep -f "$pattern" 2>/dev/null || true
}

_kill_pids_gracefully() {
  local label="$1"
  shift
  local pid
  local killed=0
  for pid in "$@"; do
    [[ -z "$pid" ]] && continue
    if kill -0 "$pid" 2>/dev/null; then
      echo "kill-emulator: SIGTERM $label pid $pid" >&2
      kill "$pid" 2>/dev/null || true
      killed=$((killed + 1))
    fi
  done
  if (( killed > 0 )); then
    sleep 1
    for pid in "$@"; do
      [[ -z "$pid" ]] && continue
      if kill -0 "$pid" 2>/dev/null; then
        echo "kill-emulator: SIGKILL $label pid $pid" >&2
        kill -9 "$pid" 2>/dev/null || true
      fi
    done
  fi
  echo "$killed"
}

kill_orphan_emulator_processes() {
  if [[ ! -d "$EMULATOR_HOME" ]]; then
    return 0
  fi

  local -a pids=()
  local pid

  while IFS= read -r pid; do
    [[ -n "$pid" ]] && pids+=("$pid")
  done < <(_pgrep_pids "${EMULATOR_HOME}/emulator.*-avd")

  while IFS= read -r pid; do
    [[ -n "$pid" ]] && pids+=("$pid")
  done < <(_pgrep_pids "${EMULATOR_HOME}/.*/qemu-system-")

  while IFS= read -r pid; do
    [[ -n "$pid" ]] && pids+=("$pid")
  done < <(_pgrep_pids "${EMULATOR_HOME}/netsimd")

  if ((${#pids[@]} == 0)); then
    echo 0
    return 0
  fi

  # Deduplicate PIDs (emulator parent + qemu child may both match).
  local -a unique=()
  local seen="$ "
  for pid in "${pids[@]}"; do
    if [[ "$seen" != *" $pid "* ]]; then
      unique+=("$pid")
      seen+=" $pid "
    fi
  done

  _kill_pids_gracefully "emulator" "${unique[@]}"
}

kill_orphan_crashpad_handlers() {
  if [[ ! -d "$EMULATOR_HOME" ]]; then
    return 0
  fi

  local -a pids=()
  local pid
  while IFS= read -r pid; do
    [[ -n "$pid" ]] && pids+=("$pid")
  done < <(_pgrep_pids "${EMULATOR_HOME}/crashpad_handler")

  if ((${#pids[@]} == 0)); then
    echo 0
    return 0
  fi

  _kill_pids_gracefully "crashpad_handler" "${pids[@]}"
}

adb_killed=0
if [[ -n "${EMULATOR_SERIAL:-}" ]]; then
  kill_via_adb "$EMULATOR_SERIAL"
  adb_killed=1
else
  while IFS= read -r serial; do
    [[ -z "$serial" ]] && continue
    kill_via_adb "$serial"
    adb_killed=$((adb_killed + 1))
  done < <(
    "${ADB_CMD[@]}" devices 2>/dev/null |
      awk '/^emulator-[0-9]+[[:space:]]+(device|offline)/ { print $1 }'
  )
fi

orphan_killed="$(kill_orphan_emulator_processes)"
crashpad_killed="$(kill_orphan_crashpad_handlers)"

if (( adb_killed == 0 && orphan_killed == 0 && crashpad_killed == 0 )); then
  echo "kill-emulator: no running Android emulators found" >&2
  exit 0
fi

echo "kill-emulator: stopped via adb=$adb_killed emulator_processes=$orphan_killed crashpad_handlers=$crashpad_killed" >&2
