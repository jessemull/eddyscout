#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$REPO_ROOT"

echo "=== Running Code Generation ==="

melos exec -- "dart run build_runner build --delete-conflicting-outputs" \
  --depends-on=build_runner

echo "=== Code Generation Complete ==="
