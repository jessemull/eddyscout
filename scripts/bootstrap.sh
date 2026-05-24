#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
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
  npm install
else
  echo "WARNING: npm not found. Git hooks (husky/commitlint) will not be installed."
  echo "Install Node.js for commit message linting."
fi

# Activate melos globally if not available
if ! command -v melos &>/dev/null; then
  echo "Installing melos globally..."
  dart pub global activate melos
fi

# Get dependencies
echo "Running dart pub get..."
dart pub get

# Bootstrap melos
echo "Running melos bootstrap..."
melos bootstrap

echo ""
echo "=== Bootstrap complete ==="
echo "Run 'make preflight' to verify everything works."
