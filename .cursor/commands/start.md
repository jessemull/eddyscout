# Start agent session (EddyScout)

Branch name: **$ARGUMENTS**

If `$ARGUMENTS` is empty, stop and ask for a feature branch name (Conventional Commit scope style, e.g. `feat/gpx-export` or `chore/riverpod-codegen`).

---

## 1. Load governance (CONTEXT.md mandatory reading order)

Read these files **in order** before any implementation work:

1. `CONTEXT.md`
2. `AGENTS.md`
3. `docs/GOVERNANCE.md`
4. `docs/ARCHITECTURE.md`
5. `docs/TESTING.md`
6. `docs/COMMENTS.md`
7. `docs/PLATFORMS.md`
8. `docs/DEPENDENCIES.md`
9. `docs/SECURITY.md`
10. `docs/RELEASES.md`

Complete the **Confirmation Requirement** checklist at the bottom of `CONTEXT.md`. If a listed doc is missing, note it and treat `CONTEXT.md` + `AGENTS.md` as authoritative.

Do not skip docs because the task “seems unrelated.”

---

## 2. Sync `main` and create the feature branch

From the repository root:

```bash
git fetch origin main
git checkout main
git pull origin main
git checkout -b $ARGUMENTS
```

Rules:

- Branch from **updated `main`**, not from a stale local branch.
- Use the branch name exactly as provided in `$ARGUMENTS`.
- Do not commit or push unless the user asks.
- If the branch already exists locally, stop and ask whether to check it out or use a different name.

---

## 3. Ensure git hooks (once per worktree)

**Run this every time you `/start` in a worktree.** Do not assume hooks from another checkout are active here.

From the repository root:

```bash
make ensure-husky
```

Verify:

```bash
test -x .husky/_/pre-push && echo OK
```

**Why this is per-worktree, not shared:**

- `.husky/pre-commit`, `.husky/pre-push`, etc. **are in git** — same scripts everywhere.
- `.husky/_/` (the hook stubs Husky actually executes) is **gitignored** — each checkout must run `npm install` (via `make ensure-husky`) to generate it.
- New **git worktrees** get the hook scripts but often **not** `.husky/_/`, so commits/pushes silently skip validation until you run this step.

`make bootstrap` also runs ensure-husky; `/start` must run it explicitly so agents never skip it.

---

## 4. Confirm when finished

Reply with a short summary that includes:

- [ ] All mandatory docs read (list any that were missing)
- [ ] `CONTEXT.md` Confirmation Requirement acknowledged
- [ ] `main` pulled successfully (include the `main` HEAD short SHA)
- [ ] Husky hooks active (`make ensure-husky`; `.husky/_/pre-push` executable)
- [ ] Now on branch `$ARGUMENTS` (include `git branch --show-current` and `git status --short`)

Then ask what task to work on next (or wait for the user’s assignment).

---

## 5. When a task is assigned (plan-first)

If the user assigns a scoped architecture or audit task (branch + checklist in the prompt):

1. **Switch to Plan mode** (or produce a plan only — no file edits in the first response).
2. Explore the scoped directories listed in the prompt.
3. Output a written plan (files, steps, risks, verification) and **stop for approval**.
4. Implement only after the user explicitly approves the plan.
