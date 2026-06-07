#!/usr/bin/env bash
# yarn dev equivalent: bootstrap worktree, link secrets, optionally start Android emulator, flutter run.
#
# Usage:
#   make dev
#   make dev ARGS="-d emulator-5554"
#   EMULATOR_ID=Pixel_7 make dev
#   DEVICE=none make dev          # skip auto-launching an emulator
#
# Secrets: set EDDYSCOUT_LOCAL_ENV to a canonical .local.env path, or rely on sibling worktree discovery.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
APP_ROOT="$REPO_ROOT/apps/eddyscout"

# android | none — iOS is manual until Xcode is installed (see docs/CONTRIBUTING.md).
DEVICE="${DEVICE:-android}"
EMULATOR_ID="${EMULATOR_ID:-Pixel_7}"
EMULATOR_BOOT_TIMEOUT_SEC="${EMULATOR_BOOT_TIMEOUT_SEC:-120}"

# Plain `flutter devices` footer mentions "emulators" — use machine JSON to avoid false positives.
android_device_id() {
  flutter devices --machine 2>/dev/null | python3 -c '
import json, sys
for device in json.load(sys.stdin):
    platform = str(device.get("targetPlatform", ""))
    if platform.startswith("android"):
        print(device["id"])
        break
'
}

has_android_target() {
  [[ -n "$(android_device_id)" ]]
}

launch_android_emulator() {
  local id="$1"
  echo "dev: no Android device found — launching emulator '$id'"
  flutter emulators --launch "$id" &
  local elapsed=0
  while (( elapsed < EMULATOR_BOOT_TIMEOUT_SEC )); do
    if has_android_target; then
      echo "dev: emulator ready ($(android_device_id))"
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
  if has_android_target; then
    echo "dev: Android device/emulator detected ($(android_device_id))"
    return 0
  fi
  if [[ "$DEVICE" == "none" ]]; then
    echo "ERROR: no Android device/emulator connected (DEVICE=none skips auto-launch)"
    echo "  Start an emulator, or run: DEVICE=android make dev"
    exit 1
  fi
  if [[ "$DEVICE" != "android" ]]; then
    echo "ERROR: unsupported DEVICE=$DEVICE (use android or none)"
    exit 1
  fi
  launch_android_emulator "$EMULATOR_ID"
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

android_id="$(android_device_id)"
if [[ -z "$android_id" ]]; then
  echo "ERROR: no Android device id available for flutter run"
  exit 1
fi

exec ./scripts/run_android.sh -d "$android_id" "$@"
