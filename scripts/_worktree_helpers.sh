#!/usr/bin/env bash
# Shared git worktree helpers for symlinked dev secrets.
# shellcheck shell=bash

# Prints the first sibling worktree path that contains RELATIVE_PATH (file).
find_sibling_worktree_file() {
  local repo_root="$1"
  local relative_path="$2"
  local wt_path candidate
  while IFS= read -r wt_path; do
    [[ "$wt_path" == "$repo_root" ]] && continue
    candidate="$wt_path/$relative_path"
    if [[ -f "$candidate" ]]; then
      echo "$candidate"
      return 0
    fi
  done < <(git -C "$repo_root" worktree list --porcelain 2>/dev/null | awk '/^worktree /{print $2}')
  return 1
}
