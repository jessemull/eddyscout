#!/usr/bin/env bash
# yarn dev equivalent: bootstrap worktree, link secrets, pick device, flutter run.
#
# Usage:
#   make dev                              # interactive device menu when 2+ targets
#   make dev ARGS="-d emulator-5554"
#   RUN_TARGET=launch:Pixel_9 make dev      # skip menu (launch AVD or run device id)
#   DEV_INTERACTIVE=0 make dev            # first target, no menu
#   AUTO_LAUNCH=0 make dev                # connected devices only (no AVD launch)
#
# Legacy overrides still work: EMULATOR_ID=Pixel_9  DEVICE_ID=emulator-5554
#
# Secrets: set EDDYSCOUT_LOCAL_ENV to a canonical .local.env path, or rely on sibling worktree discovery.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
APP_ROOT="$REPO_ROOT/apps/eddyscout"
FLUTTER_DEVICES="$SCRIPT_DIR/flutter_devices.dart"

EMULATOR_BOOT_TIMEOUT_SEC="${EMULATOR_BOOT_TIMEOUT_SEC:-120}"
AUTO_LAUNCH="${AUTO_LAUNCH:-1}"

read_run_targets() {
  dart "$FLUTTER_DEVICES" list-run-targets
}

read_android_device_count() {
  dart "$FLUTTER_DEVICES" list-run-targets | awk -F '\t' '$1 == "run" && $2 != "" { count++ } END { print count + 0 }'
}

pick_run_target() {
  local env_override="${1:-}"
  local -a actions=()
  local -a ids=()
  local -a labels=()
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

  echo "Select a device for make dev:" >/dev/tty
  local i=1
  for label in "${labels[@]}"; do
    echo "  [$i] $label" >/dev/tty
    i=$((i + 1))
  done
  while true; do
    read -rp "Choice [1-${#ids[@]}]: " choice </dev/tty
    if [[ "$choice" =~ ^[0-9]+$ ]] && (( choice >= 1 && choice <= ${#ids[@]} )); then
      echo "${actions[$((choice - 1))]}:${ids[$((choice - 1))]}"
      return 0
    fi
    echo "Enter a number between 1 and ${#ids[@]}." >/dev/tty
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

launch_emulator_and_wait() {
  local avd_id="$1"
  local before_count="$2"
  echo "dev: launching '$avd_id'" >&2
  flutter emulators --launch "$avd_id" &
  local elapsed=0
  while (( elapsed < EMULATOR_BOOT_TIMEOUT_SEC )); do
    local after_count
    after_count="$(read_android_device_count)"
    if (( after_count > before_count )); then
      echo "dev: emulator ready" >&2
      return 0
    fi
    sleep 2
    elapsed=$((elapsed + 2))
  done
  echo "ERROR: emulator did not appear within ${EMULATOR_BOOT_TIMEOUT_SEC}s" >&2
  echo "  Start one manually: flutter emulators --launch $avd_id" >&2
  exit 1
}

device_id_for_run_target() {
  local target="$1"
  local action="${target%%:*}"
  local id="${target#*:}"
  local before_count
  local -a run_ids=()
  local run_action run_label

  if [[ "$action" == "run" ]]; then
    echo "$id"
    return 0
  fi
  if [[ "$action" != "launch" ]]; then
    echo "ERROR: invalid run target '$target' (expected run:<id> or launch:<avd>)" >&2
    exit 1
  fi

  before_count="$(read_android_device_count)"
  launch_emulator_and_wait "$id" "$before_count"

  while IFS=$'\t' read -r run_action id run_label; do
    [[ "$run_action" == "run" && -n "$id" ]] && run_ids+=("$id")
  done < <(read_run_targets)

  if ((${#run_ids[@]} == 0)); then
    return 1
  fi
  if ((${#run_ids[@]} == 1)); then
    echo "${run_ids[0]}"
    return 0
  fi
  echo "${run_ids[$((${#run_ids[@]} - 1))]}"
}

args_contain_device_flag() {
  local arg
  for arg in "$@"; do
    [[ "$arg" == "-d" || "$arg" == "--device-id" ]] && return 0
  done
  return 1
}

cd "$REPO_ROOT"

"$SCRIPT_DIR/ensure_worktree.sh"
"$SCRIPT_DIR/ensure_local_env.sh"
"$SCRIPT_DIR/ensure_android_secrets.sh"

cd "$APP_ROOT"

if args_contain_device_flag "$@"; then
  exec ./scripts/run_android.sh "$@"
fi

if ! target="$(resolve_run_target_override)"; then
  if ! target="$(pick_run_target "" < <(read_run_targets))"; then
    cat <<EOF
ERROR: no mobile devices or emulators found.

Android: create an AVD in Android Studio Device Manager, or run:
  flutter emulators --create

iOS (later): install Xcode from the App Store, then run:
  sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
  sudo xcodebuild -runFirstLaunch
EOF
    exit 1
  fi
fi

run_id="$(device_id_for_run_target "$target")"
if [[ -z "$run_id" ]]; then
  echo "ERROR: could not resolve a flutter device id for target '$target'"
  exit 1
fi

echo "dev: flutter run -d $run_id"
exec ./scripts/run_android.sh -d "$run_id" "$@"
