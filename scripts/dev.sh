#!/usr/bin/env bash
# make dev — prep worktree, pick a mobile target, start it if needed, flutter run.
#
# Flow:
#   1. Bootstrap worktree + link secrets
#   2. Show connected devices + AVDs not already running
#   3. Start chosen AVD via the emulator binary (not flutter emulators --launch)
#   4. Wait until adb reports boot complete
#   5. flutter run
#
# Usage:
#   make dev
#   RUN_TARGET=run:emulator-5554 make dev
#   DEV_INTERACTIVE=0 make dev
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
APP_ROOT="$REPO_ROOT/apps/eddyscout"
FLUTTER_DEVICES="$SCRIPT_DIR/flutter_devices.dart"
ANDROID_HOME="${ANDROID_HOME:-$HOME/Library/Android/sdk}"
EMULATOR_BIN="$ANDROID_HOME/emulator/emulator"

EMULATOR_BOOT_TIMEOUT_SEC="${EMULATOR_BOOT_TIMEOUT_SEC:-180}"
AUTO_LAUNCH="${AUTO_LAUNCH:-1}"

read_run_targets() {
  dart "$FLUTTER_DEVICES" list-run-targets
}

read_connected_ids() {
  dart "$FLUTTER_DEVICES" connected-ids
}

pick_run_target() {
  local env_override="${1:-}"
  local -a actions=() ids=() labels=()
  local action id label choice

  if [[ -n "$env_override" ]]; then
    echo "$env_override"
    return 0
  fi

  while IFS=$'\t' read -r action id label; do
    [[ -z "$action" || -z "$id" ]] && continue
    if [[ "$action" == "launch" && "$AUTO_LAUNCH" == "0" ]]; then
      continue
    fi
    actions+=("$action")
    ids+=("$id")
    labels+=("${label:-$id}")
  done

  if ((${#ids[@]} == 0)); then
    return 1
  fi
  if ((${#ids[@]} == 1)); then
    echo "${actions[0]}:${ids[0]}"
    return 0
  fi
  if [[ "${DEV_INTERACTIVE:-1}" == "0" ]]; then
    echo "${actions[0]}:${ids[0]}"
    return 0
  fi

  echo "" >&2
  echo "Select a device for make dev:" >&2
  local i=1
  for label in "${labels[@]}"; do
    echo "  [$i] $label" >&2
    i=$((i + 1))
  done
  while true; do
    read -rp "Choice [1-${#ids[@]}]: " choice </dev/tty
    if [[ "$choice" =~ ^[0-9]+$ ]] && (( choice >= 1 && choice <= ${#ids[@]} )); then
      echo "${actions[$((choice - 1))]}:${ids[$((choice - 1))]}"
      return 0
    fi
    echo "Enter a number between 1 and ${#ids[@]}." >&2
  done
}

resolve_run_target_override() {
  if [[ -n "${RUN_TARGET:-}" ]]; then
    echo "$RUN_TARGET"
    return 0
  fi
  if [[ -n "${DEVICE_ID:-}" ]]; then
    echo "run:${DEVICE_ID}"
    return 0
  fi
  if [[ -n "${EMULATOR_ID:-}" ]]; then
    echo "launch:${EMULATOR_ID}"
    return 0
  fi
  return 1
}

launch_avd_and_wait() {
  local avd_id="$1"
  local -a before_ids=()
  local id elapsed new_id
  local emu_log="$REPO_ROOT/.dart_tool/dev-emulator-${avd_id}.log"

  if [[ ! -x "$EMULATOR_BIN" ]]; then
    echo "ERROR: emulator binary not found at $EMULATOR_BIN" >&2
    exit 1
  fi

  mkdir -p "$REPO_ROOT/.dart_tool"
  while IFS= read -r id; do
    [[ -n "$id" ]] && before_ids+=("$id")
  done < <(read_connected_ids)

  echo "dev: starting $avd_id (can take 1–2 minutes on first boot)..." >&2
  echo "dev: emulator log → $emu_log (INFO/WARNING only; not shown here)" >&2
  # flutter emulators --launch is unreliable when another AVD is running; use the
  # emulator binary directly instead.
  "$EMULATOR_BIN" -avd "$avd_id" -no-audio -no-boot-anim >>"$emu_log" 2>&1 &
  local emu_pid=$!

  elapsed=0
  while (( elapsed < EMULATOR_BOOT_TIMEOUT_SEC )); do
    if ! kill -0 "$emu_pid" 2>/dev/null; then
      echo "ERROR: '$avd_id' exited during startup." >&2
      echo "  Log: $emu_log" >&2
      echo "  If it is already running, pick the (connected) entry instead." >&2
      exit 1
    fi

    if ((${#before_ids[@]} > 0)); then
      new_id="$(dart "$FLUTTER_DEVICES" first-new-booted-device --avd "$avd_id" "${before_ids[@]}")"
    else
      new_id="$(dart "$FLUTTER_DEVICES" first-new-booted-device --avd "$avd_id")"
    fi
    if [[ -n "$new_id" ]]; then
      echo "dev: waiting for $avd_id to settle..." >&2
      sleep 5
      if ! adb -s "$new_id" get-state 2>/dev/null | grep -q device; then
        echo "dev: $new_id not ready yet, continuing to wait..." >&2
        sleep 3
        elapsed=$((elapsed + 8))
        continue
      fi
      echo "dev: $avd_id ready ($new_id)" >&2
      echo "$new_id"
      return 0
    fi

    sleep 3
    elapsed=$((elapsed + 3))
  done

  echo "ERROR: timed out waiting for '$avd_id' to boot." >&2
  echo "  Log: $emu_log" >&2
  exit 1
}

device_id_for_run_target() {
  local target="$1"
  local action="${target%%:*}"
  local id="${target#*:}"

  if [[ "$action" == "run" ]]; then
    echo "$id"
    return 0
  fi
  if [[ "$action" == "launch" ]]; then
    launch_avd_and_wait "$id"
    return 0
  fi

  echo "ERROR: invalid target '$target' (expected run:<id> or launch:<avd>)" >&2
  exit 1
}

args_contain_device_flag() {
  local arg
  for arg in "$@"; do
    [[ "$arg" == "-d" || "$arg" == "--device-id" ]] && return 0
  done
  return 1
}

cd "$REPO_ROOT"

echo "dev: preparing worktree..." >&2
"$SCRIPT_DIR/ensure_worktree.sh" >&2
"$SCRIPT_DIR/ensure_local_env.sh" >&2
"$SCRIPT_DIR/ensure_android_secrets.sh" >&2
"$SCRIPT_DIR/ensure_android_plugins.sh" >&2

cd "$APP_ROOT"

if args_contain_device_flag "$@"; then
  exec ./scripts/run_android.sh "$@"
fi

target=""
if ! target="$(resolve_run_target_override)"; then
  if ! target="$(pick_run_target "" < <(read_run_targets))"; then
    cat <<EOF >&2
ERROR: no mobile devices or emulators found.

Android: create an AVD in Android Studio → Device Manager
iOS (later): install Xcode, then xcodebuild -runFirstLaunch
EOF
    exit 1
  fi
fi

run_id="$(device_id_for_run_target "$target")"
if [[ -z "$run_id" ]]; then
  echo "ERROR: could not resolve a flutter device for '$target'" >&2
  exit 1
fi

echo "dev: flutter run -d $run_id" >&2
if ! ./scripts/run_android.sh -d "$run_id" --device-timeout=120 "$@"; then
  echo "" >&2
  echo "dev: flutter run failed." >&2
  echo "  • Gradle Read timed out? Re-run make dev (first build after clearing ~/.gradle/caches re-downloads deps)" >&2
  echo "  • cannot find symbol FilePickerPlugin? Run: rm -f apps/eddyscout/android/app/src/main/java/io/flutter/plugins/GeneratedPluginRegistrant.java && make dev" >&2
  echo "  • Or: cd apps/eddyscout && flutter clean && flutter pub get && make dev" >&2
  echo "  • Lost connection? Keep the emulator window open" >&2
  echo "  • Emulator log: $REPO_ROOT/.dart_tool/dev-emulator-*.log" >&2
  echo "  • Device log: adb -s $run_id logcat -d | tail -80" >&2
  exit 1
fi
