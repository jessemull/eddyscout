# Shared environment for EddyScout shell scripts.
# shellcheck shell=bash

_env_dir="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
_eddyscout_root="$(cd "$_env_dir/.." && pwd)"

_eddyscout_prepend_path() {
  case ":${PATH}:" in
    *":$1:"*) ;;
    *) PATH="$1:$PATH" ;;
  esac
}

# Git hooks (husky) often inherit a minimal PATH without Flutter/Dart shims.
if ! command -v flutter >/dev/null 2>&1; then
  for candidate in \
    "${FLUTTER_ROOT:-}/bin" \
    "${HOME}/fvm/default/bin" \
    "/opt/homebrew/bin" \
    "/usr/local/bin" \
    "${HOME}/flutter/bin" \
    "${HOME}/development/flutter/bin"; do
    if [[ -n "$candidate" && -x "${candidate}/flutter" ]]; then
      _eddyscout_prepend_path "$candidate"
      break
    fi
  done
fi

if ! command -v flutter >/dev/null 2>&1 && [[ -f "$_eddyscout_root/.tool-versions" ]]; then
  if command -v mise >/dev/null 2>&1; then
    # shellcheck disable=SC1090
    eval "$(mise activate bash --shims 2>/dev/null || true)"
  elif [[ -f "${HOME}/.asdf/asdf.sh" ]]; then
    # shellcheck source=/dev/null
    source "${HOME}/.asdf/asdf.sh"
  fi
fi

if command -v flutter >/dev/null 2>&1; then
  export FLUTTER_ROOT="${FLUTTER_ROOT:-$(cd "$(dirname "$(command -v flutter)")/.." && pwd)}"
fi

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

unset _env_dir _eddyscout_root _eddyscout_prepend_path
