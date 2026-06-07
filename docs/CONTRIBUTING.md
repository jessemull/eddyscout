# Contributing

> **Precedence:** CONTEXT.md > GOVERNANCE.md > ARCHITECTURE.md > **CONTRIBUTING.md** > inline comments.
>
> **AI agents — read this file when:** creating a branch, writing a commit message, preparing a PR, or advising on the contribution workflow.

---

## Getting started

### Prerequisites

- Flutter stable channel (latest)
- Dart SDK ^3.11.4
- melos (`dart pub global activate melos`)
- Android Studio or Xcode (for platform builds)
- A Mapbox access token in `.local.env` (never committed)

### Bootstrap

```bash
# Clone the repo
git clone <repo-url> && cd eddyscout

# Install melos globally (if not already)
dart pub global activate melos

# Bootstrap all packages
melos bootstrap

# Run code generation
melos run gen

# Verify everything works
melos run preflight
```

### Running the app

```bash
# Recommended (bootstraps worktree, links .local.env, starts Android emulator, runs app)
make dev

# Optional: one canonical secrets file for all worktrees
export EDDYSCOUT_LOCAL_ENV=~/Development/eddyscout/apps/eddyscout/.local.env

# Manual Android (emulator must already be running)
./scripts/run_android.sh

# iOS — requires full Xcode from the App Store (not Command Line Tools alone)
#   sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
#   sudo xcodebuild -runFirstLaunch
# Then from apps/eddyscout/:
flutter run --dart-define-from-file=.local.env
```

The `.local.env` file must contain your Mapbox token. New worktrees symlink from a sibling worktree or `EDDYSCOUT_LOCAL_ENV` when possible.

---

## Branch naming

Use the following prefixes:

| Prefix | Use |
|--------|-----|
| `feat/<short-description>` | New features |
| `fix/<short-description>` | Bug fixes |
| `refactor/<short-description>` | Code restructuring without behavior change |
| `docs/<short-description>` | Documentation only |
| `test/<short-description>` | Adding or fixing tests |
| `chore/<short-description>` | Tooling, CI, dependency updates |
| `perf/<short-description>` | Performance improvements |

Use lowercase, kebab-case descriptions. Keep them short and scannable.

```
feat/tide-current-display
fix/go-no-go-null-wind
refactor/extract-conditions-provider
docs/governance-framework
```

---

## Commit conventions

Follow [Conventional Commits](https://www.conventionalcommits.org/) strictly.

### Format

```
<type>(<scope>): <subject>

[optional body]

[optional footer(s)]
```

### Types

| Type | When |
|------|------|
| `feat` | New user-facing feature |
| `fix` | Bug fix |
| `refactor` | Code change that neither fixes a bug nor adds a feature |
| `test` | Adding or correcting tests |
| `docs` | Documentation only |
| `style` | Formatting, whitespace (no logic change) |
| `perf` | Performance improvement |
| `chore` | Build, CI, tooling, dependency changes |
| `revert` | Reverting a previous commit |

### Scopes

Use the package or feature name: `core`, `design_system`, `networking`, `persistence`, `routing`, `map`, `conditions`, `decision`, `firebase`, `ci`, etc.

### Rules

- **Subject line:** imperative mood, lowercase, no period, max 72 characters.
- **Body:** explain _why_, not _what_. The diff shows what changed.
- **Breaking changes:** add `BREAKING CHANGE:` footer or `!` after type/scope.

### Examples

```
feat(conditions): add NOAA tide current parsing

fix(decision): handle null wind speed in go/no-go evaluator

refactor(networking)!: migrate HTTP client from http to dio

BREAKING CHANGE: EddyScoutHttpClient removed; use DioClient instead.

chore(ci): add generated code freshness check to preflight
```

---

## PR process

### Before opening a PR

1. **Quality gates:** Commits run a fast staged format/analyze hook. **`git push` runs the full test + codegen + boundary checks.** Optionally run `make preflight` before opening a PR (includes coverage, same as CI minus parallel jobs).

2. **Keep PRs focused.** One logical change per PR. If you find yourself writing "also" in the PR description, consider splitting.

3. **Update documentation** if your change affects architecture, governance, or developer workflow.

4. **Regenerate code** if you modified annotated classes:
   ```bash
   melos run gen
   ```

### PR description template

```markdown
## What

<1-3 sentences: what this PR does>

## Why

<Why this change is needed — link issue if applicable>

## How

<Brief technical approach — what the reviewer should pay attention to>

## Testing

<What you tested and how — new tests, manual verification, etc.>

## Checklist

- [ ] Push validation passed (or `make preflight` for full coverage check)
- [ ] New/changed code has tests
- [ ] Documentation updated (if applicable)
- [ ] Generated code is up to date
- [ ] No new warnings or lint violations
```

### PR size guidelines

| Size | Lines changed | Review expectation |
|------|---------------|-------------------|
| Small | < 100 | Same-day review |
| Medium | 100–400 | 1–2 business days |
| Large | 400+ | Split if possible; expect longer review |

---

## Code review expectations

### For authors

- Respond to all review comments, even if just to acknowledge.
- Don't resolve conversations you didn't start — let the reviewer resolve.
- If you disagree with feedback, explain your reasoning rather than silently ignoring.
- Push fixup commits during review; squash on merge.

### For reviewers

- Use the tiered severity system from `REVIEW.md` (MUST / SHOULD / NICE TO HAVE).
- Review within the agreed SLA (see PR size guidelines above).
- Approve once all MUST items are resolved. SHOULD items may carry with a tracking issue.
- Be specific: quote the line, explain the concern, suggest a fix when possible.

---

## Testing requirements

- **Every PR that changes behavior must include tests.** No exceptions.
- **Bug fix PRs must include a regression test** that fails without the fix.
- **New features require both unit and widget tests** at minimum.
- Use `mocktail` for mocking. `mockito` is not permitted.
- See `TESTING.md` for comprehensive testing guidance.

---

## Preflight checks

Run before every push:

```bash
melos run preflight
```

This executes (in order):

1. `dart format --set-exit-if-changed .` — formatting
2. `dart analyze --fatal-infos` — static analysis
3. `flutter test` — all tests in packages with `test/` directories
4. `melos run gen:check` — generated code freshness

CI runs the same checks via `scripts/preflight.sh --ci`. If preflight passes locally, CI will pass.

### Individual checks

```bash
melos run format        # Check formatting
melos run format:fix    # Auto-fix formatting
melos run analyze       # Static analysis
melos run test          # Run all tests
melos run gen           # Regenerate code
melos run gen:check     # Verify generated code is fresh
```

---

## Merge criteria

A PR may merge when **all** of the following are true:

1. CI is green (all preflight checks pass)
2. At least one human reviewer has approved
3. All MUST-level review comments are resolved
4. No unresolved merge conflicts
5. Branch is up to date with the target branch
6. PR description is complete and accurate
7. If governance/architecture docs are changed: follows the governance change process (see `GOVERNANCE.md`)
8. If security-sensitive: reviewed by a second reviewer (see `GOVERNANCE.md`)

### Merge strategy

- **Squash and merge** for feature branches with multiple fixup commits.
- **Merge commit** for long-lived branches or when individual commit history is valuable.
- **Never force-push** to `main`.
