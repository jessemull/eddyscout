---
name: commit
description: >-
  Prepare and create commits for EddyScout following Conventional Commits,
  governance rules, and codegen verification. Use when staging, committing,
  or preparing changes for PR.
---

# Commit Changes

Read the following before committing changes:

- `CONTEXT.md`
- `AGENTS.md`
- `docs/GOVERNANCE.md`
- `docs/ARCHITECTURE.md`
- `docs/REVIEW.md`
- `docs/CODEGEN.md`
- `docs/TESTING.md`

Safety rules:
- Only commit when the user explicitly requests it.
- Never use `--no-verify` to skip pre-commit hooks unless the user explicitly requests it.
- Never amend commits that have been pushed to remote.
- Never force-push to `main`/`master`.

Commits are part of the repository governance system.

A commit is not merely a snapshot of files.

A commit is:
- a documented architectural change
- a historical record
- a review boundary
- a rollback unit
- a deployment unit
- and a source of repository context for humans and AI systems

Commits must remain:
- atomic
- intentional
- reproducible
- reviewable
- and semantically meaningful

---

# When to Use

Use this skill when:
- staging changes
- creating commits
- preparing PRs
- restructuring commits
- splitting changes
- squashing commits
- preparing generated code updates
- committing dependency changes
- committing architecture changes

---

# Core Commit Principles

## Atomicity

Each commit should represent:
- one logical change
- one architectural concern
- one coherent improvement

Avoid mixing:
- refactors
- dependency updates
- formatting
- feature work
- generated code unrelated to source changes

into a single commit.

---

## Determinism

A commit must:
- build successfully
- pass analysis
- pass tests
- contain deterministic generated output
- avoid broken intermediate states

Every commit should be independently valid whenever practical.

---

## Reviewability

Commits should:
- be easy to review
- minimize unrelated diffs
- preserve architectural clarity
- isolate risky changes
- explain intent clearly

---

## Repository Integrity

Never commit:
- broken builds
- failing tests
- stale generated code
- debug artifacts
- temporary hacks
- commented-out dead code
- secrets
- local-only configuration
- unrelated formatting churn

---

# Conventional Commit Format

Use Conventional Commits.

Format:

```text
<type>(<scope>): <description>

[optional body]

[optional footer(s)]
```

Example:

```text
feat(auth): add JWT refresh token handling
```

---

# Commit Types

| Type | Use When |
|---|---|
| `feat` | new feature |
| `fix` | bug fix |
| `refactor` | restructuring without behavior change |
| `perf` | performance improvement |
| `test` | tests only |
| `docs` | documentation only |
| `style` | formatting/style-only changes |
| `chore` | maintenance/tooling/config |
| `build` | build tooling/dependencies |
| `ci` | CI/CD changes |
| `revert` | reverting previous commit |

---

# Scope Rules

Scopes should identify:
- feature
- package
- subsystem
- architecture area

Examples:

```text
feat(auth): add biometric login
fix(networking): handle timeout retries
refactor(map): simplify clustering logic
test(core): improve async coverage
```

Avoid vague scopes like:
- `misc`
- `stuff`
- `update`

---

# Breaking Changes

Breaking changes must be explicit.

Use:

```text
feat(auth)!: replace legacy session storage
```

OR:

```text
BREAKING CHANGE: session format changed
```

Breaking changes require:
- migration notes
- updated documentation
- architecture review
- compatibility analysis

---

# 1. Pre-Commit Review

Before staging files:

- [ ] Review all modified files
- [ ] Understand every change being committed
- [ ] Remove accidental edits
- [ ] Remove debug code
- [ ] Remove temporary logging
- [ ] Remove commented-out code
- [ ] Remove dead code
- [ ] Remove experimental artifacts

---

# 2. Change Isolation Review

## Atomicity

- [ ] Commit contains one logical change
- [ ] Unrelated changes separated
- [ ] Refactors isolated from features where practical
- [ ] Formatting-only changes isolated where practical

## Architecture Integrity

- [ ] Architectural boundaries preserved
- [ ] No temporary hacks hidden in commit
- [ ] No unrelated generated churn included

---

# 3. Generated Code Review

## Codegen Integrity

- [ ] Generated files regenerated
- [ ] No stale generated artifacts
- [ ] Generated output deterministic
- [ ] Generated files match source annotations

## Codegen Validation

Run:

```bash
make gen
make gen-check
```

Never commit stale generated files.

---

# 4. Quality Gates

All quality gates must pass before commit.

## Required Commands

Run:

```bash
make preflight
```

This must validate:

- formatting
- analysis
- tests
- code generation
- linting
- import hygiene
- dependency validation

---

# 5. Analyzer & Lint Validation

- [ ] `dart analyze` passes cleanly
- [ ] No analyzer warnings
- [ ] No ignored analyzer issues without justification
- [ ] No suppressed lints without explanation

---

# 6. Formatting Validation

- [ ] `dart format` applied
- [ ] No formatting drift
- [ ] Formatting changes intentional
- [ ] Formatting-only churn minimized

---

# 7. Testing Validation

## Required

- [ ] Unit tests pass
- [ ] Widget tests pass
- [ ] Integration tests pass where applicable
- [ ] Golden tests updated intentionally

## Test Quality

- [ ] New functionality tested
- [ ] Edge cases considered
- [ ] Async flows tested
- [ ] No flaky tests introduced

---

# 8. Performance Validation

## Performance Safety

- [ ] No unnecessary rebuild scope increases
- [ ] No obvious memory leaks
- [ ] No expensive synchronous UI work
- [ ] No duplicate async requests introduced

## High-Risk Changes

If touching:
- animations
- lists
- maps
- rendering
- providers
- image loading

verify performance impact intentionally.

---

# 9. Security Validation

- [ ] No secrets committed
- [ ] No API keys committed
- [ ] No sensitive logs added
- [ ] No unsafe debug endpoints added
- [ ] No insecure dependency changes

---

# 10. Dependency Review

If dependencies changed:

- [ ] Dependency addition justified
- [ ] Dependency approved by repository policy
- [ ] Lockfiles updated correctly
- [ ] No accidental dependency drift
- [ ] Transitive dependency impact reviewed

---

# 11. Asset Review

If assets changed:

- [ ] Asset naming follows conventions
- [ ] Asset optimization completed
- [ ] Unused assets removed
- [ ] Large asset additions justified

---

# 12. Documentation Review

If architecture or behavior changed:

- [ ] Relevant docs updated
- [ ] README updated if needed
- [ ] Migration notes added if needed
- [ ] Governance docs updated if needed

---

# 13. Git Staging Rules

## Review Staged Changes

Before commit:

```bash
git diff --staged
```

Verify:
- only intended files staged
- no accidental secrets
- no unrelated changes
- no local-only config changes

---

# 14. Commit Message Review

## Subject Line Rules

- [ ] Imperative mood
- [ ] ≤ 72 characters
- [ ] Clear and specific
- [ ] No vague wording

Good:

```text
fix(auth): prevent duplicate token refresh requests
```

Bad:

```text
fixed stuff
misc updates
changes
```

---

# 15. Commit Body Guidance

Add commit body when:
- architectural reasoning matters
- migration context matters
- tradeoffs exist
- non-obvious decisions exist

Explain:
- why
- constraints
- tradeoffs
- risks
- migration implications

Avoid narrating implementation details unnecessarily.

---

# 16. AI-Assisted Development Validation

## AI Safety

- [ ] No hallucinated APIs committed
- [ ] No fake package usage committed
- [ ] Repository conventions followed
- [ ] Existing patterns reused appropriately

## Complexity Review

- [ ] No overengineering introduced
- [ ] No unnecessary abstractions added
- [ ] Boilerplate justified
- [ ] Architecture consistency preserved

---

# 17. Commit Execution

After all checks pass:

```bash
git commit -m "type(scope): description"
```

For complex commits, use multi-line commit messages.

Example:

```bash
git commit
```

Then provide:
- summary
- reasoning
- migration notes
- issue references

---

# 18. Common Commit Anti-Patterns

## MUST NOT

- [ ] Commit broken builds
- [ ] Commit failing tests
- [ ] Commit stale generated code
- [ ] Commit secrets
- [ ] Commit unrelated changes together
- [ ] Commit temporary debugging artifacts
- [ ] Commit commented-out dead code
- [ ] Commit analyzer violations

## SHOULD AVOID

- [ ] Giant commits
- [ ] Ambiguous commit messages
- [ ] Formatting-only noise mixed with features
- [ ] Mixed refactor + feature commits
- [ ] Drive-by cleanup changes

---

# 19. Final Commit Checklist

Before committing:

- [ ] Repository builds
- [ ] Tests pass
- [ ] Analyzer passes
- [ ] Formatting passes
- [ ] Codegen clean
- [ ] Diff reviewed
- [ ] Commit atomic
- [ ] Commit message clear
- [ ] Documentation updated if needed
- [ ] No accidental files included

---

# Output Expectations

When performing commit preparation, provide:

## Summary
- what changed
- architectural impact
- affected packages/features

## Validation Results
- tests run
- analyzer status
- codegen status
- performance considerations

## Commit Message
Provide final recommended Conventional Commit message.