#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
# shellcheck source=_env.sh
source "$SCRIPT_DIR/_env.sh"
cd "$REPO_ROOT"

echo "=== Running Code Generation ==="

melos exec --depends-on=build_runner -- \
  "dart run build_runner build --delete-conflicting-outputs"

echo "=== Code Generation Complete ==="
