# Merge latest `main` into current branch (EddyScout)

Bring the current feature branch up to date with `origin/main`. Resolve merge conflicts, then confirm status.

Do **not** push unless the user asks.

---

## 1. Preflight checks

From the repository root:

```bash
git branch --show-current
git status --short
```

Rules:

- If the current branch is **`main`**, stop and tell the user to switch to a feature branch first.
- If there are **uncommitted changes**, stop and ask whether to stash, commit, or discard before merging. Do not merge over dirty work without explicit approval.
- If a merge is **already in progress** (`MERGE_HEAD` exists), continue resolving that merge — do not start a second one.

---

## 2. Fetch and merge `main`

Use **`origin/main`** so this works in **git worktrees** where local `main` may be checked out elsewhere.

```bash
git fetch origin main
git merge origin/main
```

Do **not** `git checkout main` unless the user explicitly asks to update local `main` in this worktree.

If the merge succeeds with no conflicts, skip to **§4 Confirm**.

---

## 3. Resolve conflicts

When `git merge` reports conflicts:

1. List conflicted files: `git diff --name-only --diff-filter=U`
2. Open each file; resolve conflict markers (`<<<<<<<`, `=======`, `>>>>>>>`).
3. Prefer **higher-precedence docs** when governance conflicts arise (`CONTEXT.md` > `GOVERNANCE.md` > `ARCHITECTURE.md`).
4. For code conflicts, preserve the **feature branch intent** while integrating **main** fixes — do not silently drop either side.
5. If generated files conflict (`*.g.dart`, `*.freezed.dart`), prefer **regenerating** with `make gen` after resolving source files — never hand-edit generated output.
6. Stage resolved files: `git add <file>…`
7. Complete the merge:

   ```bash
   git commit --no-edit
   ```

   Use a custom merge message only if `--no-edit` fails.

8. After merge, if source models/providers changed: run `make gen` and `make gen-check` when annotated sources were touched.

Do **not** use `git merge --abort` unless the user asks to cancel.

---

## 4. Confirm when finished

Reply with a short summary:

- [ ] Fetched `origin/main` (include short SHA: `git rev-parse --short origin/main`)
- [ ] Merged into branch `$(git branch --show-current)` (merge commit SHA if created)
- [ ] Conflicts resolved (list files if any were conflicted; otherwise “none”)
- [ ] Working tree clean (`git status --short`)
- [ ] Codegen re-run if needed (`make gen` / `make gen-check`)

If merge could not be completed, report what blocked it and what the user should decide next.

Do **not** push unless the user asks.
