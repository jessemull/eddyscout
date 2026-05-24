#!/usr/bin/env bash
# Run the app with MAPBOX_ACCESS_TOKEN from gitignored .local.env via --dart-define.
# Optional: USE_FIREBASE=true in .local.env → passes --dart-define=USE_FIREBASE=true (needs google-services.json).
# Usage: make run   OR   ./scripts/run_android.sh [extra flutter run args, e.g. -d emulator-5554]
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

if [[ ! -f .local.env ]]; then
  echo "Missing .local.env"
  echo "  cp env.example .local.env"
  echo "  # then set MAPBOX_ACCESS_TOKEN=pk...."
  exit 1
fi

# shellcheck disable=SC1091
set -a
# shellcheck disable=SC1090
source .local.env
set +a

if [[ -z "${MAPBOX_ACCESS_TOKEN:-}" ]]; then
  echo "MAPBOX_ACCESS_TOKEN is empty in .local.env"
  exit 1
fi

args=(--dart-define="MAPBOX_ACCESS_TOKEN=$MAPBOX_ACCESS_TOKEN")
if [[ -n "${USE_FIREBASE:-}" ]]; then
  args+=(--dart-define="USE_FIREBASE=$USE_FIREBASE")
fi
exec flutter run "${args[@]}" "$@"
