# Shared environment for EddyScout shell scripts.
# shellcheck shell=bash

# Pub global executables (melos when activated globally).
export PATH="${PATH}:${PUB_CACHE:-${HOME}/.pub-cache}/bin"

# Prefer global melos when available; fall back to workspace dev_dependency.
melos() {
  if command -v melos >/dev/null 2>&1; then
    command melos "$@"
  else
    dart run melos "$@"
  fi
}
