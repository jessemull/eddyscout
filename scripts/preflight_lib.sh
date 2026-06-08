#!/usr/bin/env bash
# Shared helpers for preflight / push validation performance tuning.
# shellcheck shell=bash

# Max parallel melos package jobs (format, analyze, test, codegen).
preflight_resolve_jobs() {
  if [[ -n "${PUSH_VALIDATE_JOBS:-}" ]]; then
    echo "$PUSH_VALIDATE_JOBS"
    return
  fi
  local ncpu
  if [[ "$(uname -s)" == "Darwin" ]]; then
    ncpu="$(sysctl -n hw.ncpu 2>/dev/null || echo 4)"
  else
    ncpu="$(nproc 2>/dev/null || echo 4)"
  fi
  local cap="${PUSH_VALIDATE_JOBS_CAP:-8}"
  if (( ncpu > cap )); then
    echo "$cap"
  else
    echo "$ncpu"
  fi
}

# Per-package flutter test isolate concurrency (-j / --concurrency).
preflight_resolve_flutter_test_concurrency() {
  if [[ -n "${PUSH_VALIDATE_FLUTTER_TEST_JOBS:-}" ]]; then
    echo "$PUSH_VALIDATE_FLUTTER_TEST_JOBS"
    return
  fi
  preflight_resolve_jobs
}

# Unique changed paths: branch vs origin/main, working tree, and index.
preflight_collect_diff_files() {
  local files=""
  if git rev-parse --verify origin/main >/dev/null 2>&1; then
    files="$(git diff --name-only origin/main...HEAD 2>/dev/null || true)"
  fi
  local wt idx
  wt="$(git diff --name-only 2>/dev/null || true)"
  idx="$(git diff --cached --name-only 2>/dev/null || true)"
  printf '%s\n' "$files" "$wt" "$idx" | sed '/^$/d' | sort -u
}

# True when diff touches repo-wide config that requires a full validation suite.
preflight_global_config_changed() {
  while IFS= read -r file; do
    [[ -z "$file" ]] && continue
    case "$file" in
      pubspec.yaml \
      |pubspec.lock \
      |Makefile \
      |.tool-versions \
      |tooling/* \
      |scripts/* \
      |.github/* \
      |melos.yaml)
        return 0
        ;;
      */pubspec.yaml \
      |*/pubspec.lock \
      |*/analysis_options.yaml)
        return 0
        ;;
    esac
  done < <(preflight_collect_diff_files)
  return 1
}

# True when build_runner should run (lib/pubspec/build config changed).
preflight_needs_codegen_build() {
  if [[ "${CODEGEN_VERIFY_FULL:-}" == "1" ]] || [[ "${CI:-}" == "true" ]]; then
    return 0
  fi
  while IFS= read -r file; do
    [[ -z "$file" ]] && continue
    case "$file" in
      *.g.dart | *.freezed.dart | *.gr.dart) continue ;;
      pubspec.yaml | */pubspec.yaml | */build.yaml) return 0 ;;
      */lib/*.dart | */lib/**/*.dart) return 0 ;;
    esac
  done < <(preflight_collect_diff_files)
  return 1
}

preflight_verify_generated_clean() {
  local dirty
  dirty="$(git diff --name-only -- '*.g.dart' '*.freezed.dart' '*.gr.dart' 2>/dev/null || true)"
  if [[ -n "$dirty" ]]; then
    echo "ERROR: Generated files are out of date:"
    echo "$dirty"
    echo ""
    echo "Run 'make gen' and commit the changes."
    return 1
  fi
  echo "Generated code is up to date."
  return 0
}

preflight_phase_start() {
  PREFLIGHT_PHASE_NAME=$1
  PREFLIGHT_PHASE_START=$SECONDS
  echo ""
  echo "--- ${PREFLIGHT_PHASE_NAME} ---"
}

preflight_phase_end() {
  local elapsed=$((SECONDS - PREFLIGHT_PHASE_START))
  echo "Done: ${PREFLIGHT_PHASE_NAME} (${elapsed}s)"
}

# Run background jobs (label + command pairs); wait and fail if any exit non-zero.
preflight_run_parallel() {
  local -a labels=()
  local -a pids=()

  while [[ $# -ge 2 ]]; do
    local label=$1
    local cmd=$2
    shift 2
    labels+=("$label")
    (
      preflight_phase_start "$label"
      if "$cmd"; then
        preflight_phase_end "$label"
        exit 0
      fi
      echo "FAILED: ${label}"
      exit 1
    ) > >(sed "s/^/[${label}] /") 2>&1 &
    pids+=("$!")
  done

  local failed=0
  local i
  for i in "${!pids[@]}"; do
    if ! wait "${pids[$i]}"; then
      echo "Parallel phase failed: ${labels[$i]}"
      failed=1
    fi
  done
  return "$failed"
}

preflight_should_use_affected_tests() {
  if [[ "${PUSH_VALIDATE_FULL_SUITE:-}" == "1" ]]; then
    return 1
  fi
  if [[ "${PUSH_VALIDATE_AFFECTED:-}" == "1" ]] || [[ "${PUSH_VALIDATE_AUTO_AFFECTED:-}" == "1" ]]; then
    if [[ "${PUSH_VALIDATE_AUTO_AFFECTED:-}" == "1" ]] && preflight_global_config_changed; then
      echo "Global config changed — running full test suite."
      return 1
    fi
    if git rev-parse --verify origin/main >/dev/null 2>&1; then
      return 0
    fi
    echo "origin/main unavailable — running full test suite."
  fi
  return 1
}

preflight_run_tests() {
  local jobs
  jobs="$(preflight_resolve_jobs)"
  local flutter_j
  flutter_j="$(preflight_resolve_flutter_test_concurrency)"
  local -a test_args=(--exclude-tags golden --concurrency="$flutter_j")
  if [[ $# -gt 0 ]]; then
    test_args+=("$@")
  fi

  local -a melos_common=(
    exec
    --fail-fast
    --concurrency="$jobs"
    --dir-exists=test
  )

  if preflight_should_use_affected_tests; then
    echo "Running affected package tests (--since=origin/main, with dependents + dependencies)."
    melos "${melos_common[@]}" \
      --since=origin/main \
      --include-dependents \
      --include-dependencies \
      -- flutter test "${test_args[@]}"
  else
    melos "${melos_common[@]}" -- flutter test "${test_args[@]}"
  fi
}
