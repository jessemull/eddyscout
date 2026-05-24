#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$REPO_ROOT"

echo "=== Dependency Audit ==="

echo ""
echo "--- Outdated Packages ---"
melos exec -- "dart pub outdated" 2>/dev/null || true

echo ""
echo "See docs/DEPENDENCIES.md for dependency governance."
echo "=== Audit Complete ==="
