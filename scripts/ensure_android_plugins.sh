#!/usr/bin/env bash
# Drop stale Flutter Android plugin registrant so Gradle regenerates it on build.
#
# A committed or leftover GeneratedPluginRegistrant.java under app/src can compile
# before Kotlin plugin modules after ~/.gradle/caches is cleared, causing:
#   cannot find symbol FilePickerPlugin / SharedPreferencesPlugin
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
APP_ROOT="$REPO_ROOT/apps/eddyscout"
REGISTRANT="$APP_ROOT/android/app/src/main/java/io/flutter/plugins/GeneratedPluginRegistrant.java"
PLUGINS_DEPS="$APP_ROOT/.flutter-plugins-dependencies"

if [[ ! -f "$REGISTRANT" ]]; then
  exit 0
fi

# Gradle cache wipe or flutter clean leaves a registrant that compiles before plugins.
if [[ ! -d "${HOME}/.gradle/caches/modules-2" || ! -d "$APP_ROOT/build/app" ]]; then
  rm -f "$REGISTRANT"
  echo "android-plugins: removed GeneratedPluginRegistrant.java (fresh Gradle/Flutter build state)"
  exit 0
fi

if [[ ! -f "$PLUGINS_DEPS" ]]; then
  rm -f "$REGISTRANT"
  echo "android-plugins: removed stale GeneratedPluginRegistrant.java (no .flutter-plugins-dependencies yet)"
  exit 0
fi

# Regenerate when plugin list changed or registrant predates current deps snapshot.
if [[ "$PLUGINS_DEPS" -nt "$REGISTRANT" ]]; then
  rm -f "$REGISTRANT"
  echo "android-plugins: removed stale GeneratedPluginRegistrant.java (plugins changed)"
fi
