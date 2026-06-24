---
name: pr-summary
description: >-
  Generate a copy-pasteable GitHub PR description from the current branch diff.
  Fills `.github/PULL_REQUEST_TEMPLATE.md`. Use when the user runs /pr-summary,
  asks for a PR body, MR summary, or pull request description before opening a PR.
disable-model-invocation: true
---

# PR Summary

Produce a **filled GitHub PR description** for the current branch. The output must match the repo template exactly so the author can paste it into GitHub with one click.

---

## Template source of truth

**Canonical structure:** `.github/PULL_REQUEST_TEMPLATE.md`

Content guidance (when sections need detail):

- `docs/CONTRIBUTING.md` — What / Why / How / Testing (map into **Summary** and **Review Notes**)
- `docs/REVIEW.md` — reviewer focus areas (inform **Review Notes**, not author checklist theater)

**Do not invent sections** not in the GitHub template. **Do not omit sections** from the template.

---

## When to use

- User runs `/pr-summary`
- User asks for PR/MR description, PR body, or copy-paste PR summary
- Before `gh pr create` when the user wants the description drafted first

Companion skills (read only when relevant):

- `manual-test-steps` — manual scenarios for **Review Notes** / testing bullets
- `push-validation` — what gates to cite in **Checklist**
- `testing` — name specific test files added/changed

---

## Workflow

### 1. Gather branch context (parallel)

From repo root:

```bash
git fetch origin main
git branch --show-current
git status --short
git log --oneline origin/main..HEAD
git diff origin/main...HEAD --stat
git diff origin/main...HEAD --shortstat
```

Read the full diff when manageable (`git diff origin/main...HEAD`). For large diffs (> ~800 lines):

- Read `--stat` and commit messages first
- Spot-read changed source files and test files
- Do not skip test or provider changes

Note: include **uncommitted** changes in the summary if `git status` is not clean — mention that the PR should commit or drop them first.

### 2. Infer PR metadata

From commits + diff, determine:

| Field | How |
|-------|-----|
| **Summary — what** | User-visible and technical outcome in 1–3 sentences |
| **Summary — why** | Problem solved, link issue `#NNN` if branch/commits reference one |
| **Type** | Exactly one `[x]` — infer from Conventional Commit types (`feat` → Feature, `fix` → Fix, etc.) |
| **Review Notes** | How (approach, tradeoffs), testing performed, files/areas reviewers should scrutinize |
| **Checklist** | Check `[x]` only for items **verified in this session** or **clearly satisfied by the diff** |

### 3. Checklist rules

- **`[x]`** — evidence exists: tests in diff, `make analyze`/`flutter test` run and passed, codegen files updated with sources, no new user strings without l10n, etc.
- **`[ ]`** — not verified, not applicable, or uncertain — do not guess
- **Internal-only PRs** (perf/refactor/data layer): leave UI/a11y/l10n boxes unchecked unless the diff touches those layers
- **Required / Architecture / Quality / Security** — use the template group headings verbatim

If push validation was **not** run in this session, leave `make preflight` unchecked even if you expect it to pass.

### 4. Write the body

Fill every template section:

1. **Summary** — complete sentences; no HTML comments; no `<!-- -->` placeholders
2. **Type** — one checked box
3. **Checklist** — all subsections preserved; honest check states
4. **Review Notes** — bullets OK; include:
   - Technical approach (**how**)
   - Automated tests added/run (**testing**)
   - Manual verification (if any) or "No manual UI verification — internal-only change"
   - Risk callouts (codegen, cross-package, map/routing, deps)

### 5. Output format (copy-paste)

**Critical:** the deliverable is one fenced markdown code block containing **only** the filled PR body.

```markdown
## Summary

…

## Type
…
```

Rules:

- Put a **one-line intro** outside the fence (e.g. "PR description for `feat/…` vs `main`:")
- **Inside the fence:** no preamble, no "copy below", no trailing commentary
- Use straight markdown checkboxes `- [x]` / `- [ ]` exactly as GitHub expects
- Cursor renders a **copy button** on the fenced block — that is the copy-paste UX

**Do not** run `gh pr create` unless the user explicitly asks.

---

## Mapping CONTRIBUTING → GitHub template

| CONTRIBUTING section | GitHub section |
|---------------------|----------------|
| What | **Summary** (first paragraph) |
| Why | **Summary** (second paragraph) |
| How | **Review Notes** |
| Testing | **Review Notes** (bullets) |
| Checklist | **Checklist** (use template items, not CONTRIBUTING's shorter list) |

---

## Quality bar

- Summary is accurate to the **full** branch diff, not only the latest commit
- Review Notes name **packages** touched (`hydro_routing`, `map`, `apps/eddyscout`, etc.)
- No vague testing ("tests pass") — name commands and packages: `flutter test packages/features/hydro_routing`
- No false `[x]` on checklist items
- Type matches the dominant change on the branch

---

## Anti-patterns

- Outputting prose only, without a fenced copy-paste block
- Using CONTRIBUTING's `## What` / `## Why` headers instead of the GitHub template
- Checking every box to look complete
- Review-style MUST/SHOULD findings (`pr-review` is for reviewers, not this skill)
- Opening the PR without user request

---

## Example output shape

Intro (outside fence): PR description for `feat/hydro-graph-performance` vs `origin/main` (3 commits, +420/−85):

````markdown
## Summary

Adds binary serialization for the unified hydro river graph and a spatial snap index so route planning loads faster at cold start. Behavior is unchanged: map routes should match the prior GeoJSON path.

Optimizes graph bootstrap on the map planning path (R2/R3 performance plan).

## Type

- [x] Feature (new functionality)
- [ ] Fix (bug fix)
…

## Checklist
…

## Review Notes

- **How:** `RiverLineGraph.fromBinary()`, `GraphSnapIndex`, binary-first loader with GeoJSON fallback in `riverRoutePlannerProvider`.
- **Tests:** `river_graph_binary_codec_test.dart`, `graph_snap_index_test.dart`; `flutter test` in `hydro_routing` (109 passed).
- **Manual:** Map route planning regression — Cathedral Park → Sellwood; Cathedral → Glenn Otto.
- **Focus:** Binary/GeoJSON parity, provider override wiring in `app_provider_overrides.dart`, committed `.bin` asset freshness (`make gen-hydro-graph-check`).
````

(Example is illustrative — always generate from the actual diff.)
