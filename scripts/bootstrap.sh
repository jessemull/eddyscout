#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
# shellcheck source=_env.sh
source "$SCRIPT_DIR/_env.sh"
cd "$REPO_ROOT"

echo "=== EddyScout Bootstrap ==="

# Check Flutter
if ! command -v flutter &>/dev/null; then
  echo "ERROR: Flutter not found. Install from https://flutter.dev"
  exit 1
fi

echo "Flutter: $(flutter --version | head -1)"
echo "Dart: $(dart --version 2>&1)"

# Install Node dependencies (for husky/commitlint)
if command -v npm &>/dev/null; then
  echo "Installing Node dependencies..."
  "$SCRIPT_DIR/npm_install.sh"
else
  echo "WARNING: npm not found. Git hooks (husky/commitlint) will not be installed."
  echo "Install Node.js for commit message linting."
fi

# Get dependencies (includes melos as a workspace dev_dependency)
echo "Running dart pub get..."
dart pub get

# Bootstrap workspace packages
echo "Running melos bootstrap..."
melos bootstrap

echo ""
echo "--- Git hooks (husky) ---"
"$SCRIPT_DIR/ensure_husky.sh"

echo ""
echo "=== Bootstrap complete ==="
echo "git push runs push validation; use 'make preflight' only for local coverage checks."
