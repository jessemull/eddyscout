#!/usr/bin/env bash
# make kill-emulator — stop Android emulators started by adb or dev.sh.
#
# dev.sh launches "$ANDROID_HOME/emulator/emulator -avd …" in the background.
# adb emu kill only stops the guest; if adb loses the device, qemu can keep running.
# This script tries adb first, then terminates orphan emulator/qemu processes under
# ANDROID_HOME.
#
# When EMULATOR_SERIAL is set, adb targets that serial only and orphan cleanup is
# scoped to that AVD (via `adb emu avd name`). Other running emulators are left alone.
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

resolve_avd_for_serial() {
  local serial="$1"
  local avd_name
  avd_name="$("${ADB_CMD[@]}" -s "$serial" emu avd name 2>/dev/null | tr -d '\r' | head -1)"
  if [[ -n "$avd_name" ]]; then
    echo "$avd_name"
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

_dedupe_pids() {
  local -a unique=()
  local seen="$ "
  local pid
  for pid in "$@"; do
    if [[ "$seen" != *" $pid "* ]]; then
      unique+=("$pid")
      seen+=" $pid "
    fi
  done
  if ((${#unique[@]} == 0)); then
    echo 0
    return 0
  fi
  _kill_pids_gracefully "emulator" "${unique[@]}"
}

_append_child_pids() {
  local -a expanded=()
  local pid child

  for pid in "$@"; do
    expanded+=("$pid")
    while IFS= read -r child; do
      [[ -n "$child" ]] && expanded+=("$child")
    done < <(pgrep -P "$pid" 2>/dev/null || true)
  done

  if ((${#expanded[@]} == 0)); then
    return 0
  fi
  printf '%s\n' "${expanded[@]}"
}

kill_orphan_emulator_processes() {
  local avd_filter="${1:-}"

  if [[ ! -d "$EMULATOR_HOME" ]]; then
    echo 0
    return 0
  fi

  local -a pids=()
  local pid

  if [[ -n "$avd_filter" ]]; then
    while IFS= read -r pid; do
      [[ -n "$pid" ]] && pids+=("$pid")
    done < <(_pgrep_pids "${EMULATOR_HOME}/emulator.*-avd ${avd_filter}")

    if ((${#pids[@]} == 0)); then
      echo 0
      return 0
    fi

    local -a tree_pids=()
    while IFS= read -r pid; do
      [[ -n "$pid" ]] && tree_pids+=("$pid")
    done < <(_append_child_pids "${pids[@]}")
    _dedupe_pids "${tree_pids[@]}"
    return 0
  fi

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

  _dedupe_pids "${pids[@]}"
}

kill_orphan_crashpad_handlers() {
  if [[ ! -d "$EMULATOR_HOME" ]]; then
    echo 0
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
scoped_avd=""
if [[ -n "${EMULATOR_SERIAL:-}" ]]; then
  kill_via_adb "$EMULATOR_SERIAL"
  adb_killed=1
  scoped_avd="$(resolve_avd_for_serial "$EMULATOR_SERIAL" || true)"
  if [[ -n "$scoped_avd" ]]; then
    echo "kill-emulator: scoped orphan cleanup to AVD '$scoped_avd'" >&2
  else
    echo "kill-emulator: could not resolve AVD for $EMULATOR_SERIAL; skipping orphan cleanup" >&2
  fi
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

if [[ -n "${EMULATOR_SERIAL:-}" ]]; then
  if [[ -n "$scoped_avd" ]]; then
    orphan_killed="$(kill_orphan_emulator_processes "$scoped_avd")"
  else
    orphan_killed=0
  fi
  crashpad_killed=0
else
  orphan_killed="$(kill_orphan_emulator_processes)"
  crashpad_killed="$(kill_orphan_crashpad_handlers)"
fi

if (( adb_killed == 0 && orphan_killed == 0 && crashpad_killed == 0 )); then
  echo "kill-emulator: no running Android emulators found" >&2
  exit 0
fi

echo "kill-emulator: stopped via adb=$adb_killed emulator_processes=$orphan_killed crashpad_handlers=$crashpad_killed" >&2
