# Commit

> Read `CONTEXT.md` and `AGENTS.md` before using this skill.

## When to Use

Use when staging and committing changes to the repository.

## References

- `docs/GOVERNANCE.md` — commit policy and branch naming

## Conventional Commit Format

```
<type>(<scope>): <description>

[optional body]

[optional footer(s)]
```

### Types

| Type | Use When |
|------|----------|
| `feat` | Adding a new feature |
| `fix` | Fixing a bug |
| `refactor` | Restructuring code without behavior change |
| `test` | Adding or updating tests only |
| `docs` | Documentation changes only |
| `chore` | Maintenance (deps, configs, tooling) |
| `ci` | CI/CD pipeline changes |
| `perf` | Performance improvement |
| `style` | Code style (formatting, whitespace) |
| `build` | Build system or external dependency changes |

### Scope

Use the package or feature name: `core`, `networking`, `map`, `auth`, etc.

### Breaking Changes

Add `!` after the type or `BREAKING CHANGE:` in the footer:
```
feat(auth)!: replace session token with JWT
```

## Checklist

### 1. Stage Changes

- [ ] Review changed files with `git diff`
- [ ] Stage only related changes: `git add <files>`
- [ ] Do not stage generated files that are out of date — run `make gen` first

### 2. Run Quality Gates

- [ ] Run `make preflight` — all gates must pass
- [ ] Fix any formatting, analysis, or test failures before committing

### 3. Write the Commit Message

- [ ] Use Conventional Commit format (see above)
- [ ] Keep the subject line ≤ 72 characters
- [ ] Use imperative mood: "add feature" not "added feature"
- [ ] Reference issue numbers in the footer if applicable: `Closes #123`

### 4. Commit

```bash
git commit -m "type(scope): description"
```
