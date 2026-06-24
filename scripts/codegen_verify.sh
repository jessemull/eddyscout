#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
# shellcheck source=preflight_lib.sh
source "$SCRIPT_DIR/preflight_lib.sh"
cd "$REPO_ROOT"

echo "--- Verifying generated code is up to date ---"

if preflight_needs_codegen_build; then
  echo "Running build_runner (codegen-relevant sources changed)."
  # shellcheck source=_env.sh
  source "$SCRIPT_DIR/_env.sh"
  melos exec --concurrency="$(preflight_resolve_jobs)" --depends-on=build_runner -- \
    "dart run build_runner build --delete-conflicting-outputs"
else
  echo "Skipping build_runner (no codegen-relevant source changes; CI always runs full verify)."
fi

preflight_verify_generated_clean

echo "--- Verifying launch reachability index is up to date ---"
make gen-reachability-check

echo "--- Verifying launch suggested trips index is up to date ---"
make gen-suggested-trips-check
