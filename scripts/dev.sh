#!/usr/bin/env bash
# yarn dev equivalent: bootstrap worktree, link secrets, optionally start Android emulator, flutter run.
#
# Usage:
#   make dev
#   make dev ARGS="-d emulator-5554"
#   EMULATOR_ID=Pixel_7 make dev          # skip emulator picker
#   DEVICE_ID=emulator-5554 make dev      # skip connected-device picker
#   DEV_INTERACTIVE=0 make dev            # pick first emulator/device without prompting
#   DEVICE=none make dev                  # skip auto-launching an emulator
#
# Secrets: set EDDYSCOUT_LOCAL_ENV to a canonical .local.env path, or rely on sibling worktree discovery.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
APP_ROOT="$REPO_ROOT/apps/eddyscout"
FLUTTER_DEVICES="$SCRIPT_DIR/flutter_devices.dart"

# android | none — iOS support deferred until Xcode is configured.
DEVICE="${DEVICE:-android}"
EMULATOR_BOOT_TIMEOUT_SEC="${EMULATOR_BOOT_TIMEOUT_SEC:-120}"

read_android_emulators() {
  dart "$FLUTTER_DEVICES" android-emulators
}

read_android_devices() {
  dart "$FLUTTER_DEVICES" android-devices
}

pick_from_pairs() {
  local prompt="$1"
  local env_override="${2:-}"
  local -a ids=()
  local -a labels=()
  local id label choice

  if [[ -n "$env_override" ]]; then
    echo "$env_override"
    return 0
  fi

  while IFS=$'\t' read -r id label; do
    [[ -z "$id" ]] && continue
    ids+=("$id")
    labels+=("${label:-$id}")
  done

  if ((${#ids[@]} == 0)); then
    return 1
  fi
  if ((${#ids[@]} == 1)); then
    echo "${ids[0]}"
    return 0
  fi
  if [[ ! -t 0 && ! -t 1 ]] || [[ "${DEV_INTERACTIVE:-1}" == "0" ]]; then
    echo "${ids[0]}"
    return 0
  fi

  echo "$prompt" >/dev/tty
  local i=1
  for label in "${labels[@]}"; do
    echo "  [$i] $label" >/dev/tty
    i=$((i + 1))
  done
  while true; do
    read -rp "Choice [1-${#ids[@]}]: " choice </dev/tty
    if [[ "$choice" =~ ^[0-9]+$ ]] && (( choice >= 1 && choice <= ${#ids[@]} )); then
      echo "${ids[$((choice - 1))]}"
      return 0
    fi
    echo "Enter a number between 1 and ${#ids[@]}." >/dev/tty
  done
}

resolve_android_emulator_id() {
  local selected
  if ! selected="$(pick_from_pairs "Select an Android emulator to launch:" "${EMULATOR_ID:-}" < <(read_android_emulators))"; then
    echo "ERROR: no Android emulators configured (flutter emulators lists none)"
    echo "  Create one in Android Studio Device Manager, or: flutter emulators --create"
    exit 1
  fi
  echo "$selected"
}

launch_android_emulator() {
  local id="$1"
  echo "dev: launching emulator '$id'"
  flutter emulators --launch "$id" &
  local elapsed=0
  while (( elapsed < EMULATOR_BOOT_TIMEOUT_SEC )); do
    if read_android_devices | grep -q .; then
      echo "dev: emulator ready"
      return 0
    fi
    sleep 2
    elapsed=$((elapsed + 2))
  done
  echo "ERROR: emulator did not appear within ${EMULATOR_BOOT_TIMEOUT_SEC}s"
  echo "  Start one manually (Android Studio or: flutter emulators --launch $id)"
  exit 1
}

ensure_android_device() {
  if read_android_devices | grep -q .; then
    echo "dev: Android device/emulator already connected"
    return 0
  fi
  if [[ "$DEVICE" == "none" ]]; then
    echo "ERROR: no Android device/emulator connected (DEVICE=none skips auto-launch)"
    echo "  Start an emulator, or run: DEVICE=android make dev"
    exit 1
  fi
  if [[ "$DEVICE" != "android" ]]; then
    echo "ERROR: unsupported DEVICE=$DEVICE (use android or none; iOS coming later)"
    exit 1
  fi
  launch_android_emulator "$(resolve_android_emulator_id)"
}

resolve_android_run_device_id() {
  pick_from_pairs "Select an Android device for flutter run:" "${DEVICE_ID:-}" < <(read_android_devices)
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
ensure_android_device

cd "$APP_ROOT"

if args_contain_device_flag "$@"; then
  exec ./scripts/run_android.sh "$@"
fi

android_id="$(resolve_android_run_device_id)"
if [[ -z "$android_id" ]]; then
  echo "ERROR: no Android device id available for flutter run"
  exit 1
fi

echo "dev: flutter run -d $android_id"
exec ./scripts/run_android.sh -d "$android_id" "$@"
