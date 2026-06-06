# Governance

> **Precedence:** CONTEXT.md > **GOVERNANCE.md** > ARCHITECTURE.md > feature docs > inline comments.
>
> **AI agents — read this file when:** making any structural decision, resolving conflicting guidance, determining what requires human review, or proposing changes to governance docs themselves.

---

## Source-of-truth precedence

When guidance conflicts, the higher-ranked document wins:

| Rank | Document | Scope |
|------|----------|-------|
| 1 | `CONTEXT.md` | Project identity, mission, and product intent |
| 2 | `GOVERNANCE.md` | Process, constraints, authority, enforcement |
| 3 | `ARCHITECTURE.md` | Structure, layers, dependency rules |
| 4 | Feature docs (`STATE_MANAGEMENT.md`, `NAVIGATION.md`, etc.) | Domain-specific governance |
| 5 | Inline code comments | Local intent, non-obvious rationale |

If a feature doc contradicts `ARCHITECTURE.md`, architecture wins. If `ARCHITECTURE.md` contradicts this file, governance wins. Resolve upward, never downward.

---

## Non-negotiable constraints

These constraints apply to every change. Violations are blocking — no exceptions without the formal exception process below.

### Language and type safety
- **Null safety is mandatory.** No `// ignore: unnecessary_null_check` to suppress real null concerns. Every `!` operator requires a comment justifying why it cannot be null.
- **No `dynamic` except at serialization boundaries.** Even there, prefer typed deserialization (`fromJson` factories).
- **Immutable models.** Domain and data-transfer objects use `freezed` or are `@immutable`. No mutable fields on model classes.

### Architecture
- **No business logic in widgets.** Widgets call providers, notifiers, or services — never raw HTTP, parsing, or decision logic.
- **Dependency direction:** `presentation → domain ← data`. Presentation may depend on domain; data may depend on domain; domain depends on neither.
- **Package boundaries are import boundaries.** A package never imports from `apps/`. Packages import only declared dependencies in `pubspec.yaml`.

### State management
- **Riverpod is the sole state management solution.** No `ChangeNotifier`, `ValueNotifier`, `setState` for shared state, `InheritedWidget` for app state, or `bloc`/`redux`/`provider` (the package). `setState` is acceptable only for local, ephemeral widget state (animation controllers, form field focus, etc.).

### Navigation
- **go_router is the sole navigation solution.** No `Navigator.push`, `Navigator.pop`, or manual `MaterialPageRoute` construction outside go_router configuration.

### Safety and security
- **No hardcoded secrets.** API keys, tokens, and credentials come from `--dart-define`, environment files (`.local.env`, never committed), or platform-secure storage.
- **No PII or tokens in logs.** Ever. See `SECURITY.md`.

### Testing
- **No `mockito`.** Use `mocktail` exclusively. See `TESTING.md`.

### Code quality
- **Zero analyzer warnings on CI.** `dart analyze --fatal-infos` must pass.
- **Formatting is automated.** `dart format` with default settings; no manual overrides.
- **Generated code is committed and verified.** `melos run gen:check` must pass.

---

## Decision authority

### Autonomous (AI agents and developers may proceed without review)
- Bug fixes that do not change public API surface
- Adding tests
- Improving documentation within existing doc files
- Code formatting and lint fixes
- Updating generated code (`*.g.dart`, `*.freezed.dart`)
- Internal refactors that do not change package boundaries, public API, or dependency direction
- Adding inline comments that explain non-obvious intent

### Requires human review (PR approval mandatory)
- New packages or apps in the monorepo
- Changes to any governance doc (this file, `ARCHITECTURE.md`, feature docs)
- New third-party dependencies
- Changes to CI/CD pipelines
- Changes to security-sensitive code (auth, secrets, permissions)
- Database schema changes (drift migrations)
- Public API changes to shared packages (`packages/*`)
- New platform permissions (Android manifest, iOS `Info.plist`)
- Removal of tests or reduction of coverage thresholds
- Any change touching Go/No-Go safety logic or disclaimer copy

### Requires explicit product decision
- New features not in `ROADMAP.md`
- Changes to product pillars or MVP scope
- User-facing safety language changes
- Data retention or privacy policy changes
- Third-party data source additions

---

## Change process for governance docs

1. **Propose:** Open a PR with the change. Title must include `[governance]` tag.
2. **Justify:** PR description must explain _why_ the change is needed, what problem it solves, and what the previous guidance was.
3. **Review:** Minimum one human reviewer with write access. Changes to `GOVERNANCE.md` itself require two reviewers.
4. **Announce:** After merge, post a summary in the team channel (or PR comment thread) so all contributors are aware.
5. **Cascade:** If the governance change invalidates guidance in lower-ranked docs, update those docs in the same PR or a linked follow-up PR merged within 48 hours.

---

## Enforcement mechanisms

| Mechanism | What it checks | Blocks merge? |
|-----------|---------------|---------------|
| `dart analyze --fatal-infos` | Lint rules, type errors, `very_good_analysis` + `custom_lint` + `dart_code_linter` | Yes |
| `dart format --set-exit-if-changed .` | Code formatting | Yes |
| `melos run gen:check` | Generated code is up to date | Yes |
| `flutter test` | Unit, widget, and integration tests pass | Yes |
| `scripts/pre_commit.sh` (husky) | Format + analyze on **staged** Dart files only | Yes (on commit) |
| `scripts/push_validate.sh` (husky) | Full analyze, test, codegen, import/architecture checks (no coverage) | Yes (on push) |
| `scripts/preflight.sh` | Format, analyze, test, codegen; optional coverage | Yes (manual / CI) |
| PR review + CI | Architecture, security, coverage, goldens | Yes (blocks merge) |
| `riverpod_lint` | Riverpod usage patterns | Yes (via analyze) |

### CI pipeline

The GitHub Actions CI workflow runs `scripts/preflight.sh --ci`, which executes format, analyze, test, and generated-code checks. A PR cannot merge unless CI is green.

### Local quality gates

| When | What runs |
|------|-----------|
| **git commit** | `scripts/pre_commit.sh` — fast format + analyze on staged `.dart` files |
| **git push** | `scripts/push_validate.sh` — analyze, tests, codegen verify, import/architecture (coverage in CI only) |
| **Before PR / optional** | `make preflight` — full gate including coverage thresholds |

Skipping hooks is not acceptable for shared branches — CI will catch violations regardless.

---

## Escalation rules

1. **Lint / CI failure:** Fix locally. If the rule seems wrong, open a governance change PR — do not disable the rule inline without the exception process.
2. **Conflicting guidance between docs:** Apply the precedence chain. If ambiguity remains after applying precedence, escalate to a human maintainer.
3. **AI agent uncertainty:** If an AI agent is uncertain whether a change is autonomous or requires review, it **must** flag for human review. False positives are acceptable; false negatives are not.
4. **Security concern:** Any suspected vulnerability, leaked secret, or unsafe data exposure must be escalated immediately to a human maintainer regardless of severity assessment. Do not attempt to "fix and forget."
5. **Safety-critical logic:** Changes to Go/No-Go evaluator, safety disclaimers, or cold-water warnings always require human sign-off.

---

## Exception process

When a non-negotiable constraint genuinely cannot be met (not "is inconvenient" — truly cannot):

1. **File an exception request** in the PR description with:
   - Which constraint is being violated
   - Why it cannot be avoided (technical limitation, third-party API, platform restriction)
   - Scope of the exception (which files, which duration)
   - Mitigation (what compensating controls are in place)
2. **Tag the exception** with `// EXCEPTION: <constraint> — <reason> — <PR link>` in code.
3. **Time-box it.** Exceptions are temporary unless explicitly made permanent by governance change. Default expiry: 90 days.
4. **Track it.** Add a follow-up issue to remove or resolve the exception.
5. **Two human reviewers** must approve the exception PR.

No exception is valid without a linked PR and documented reason. "We'll fix it later" without a tracking issue is not an exception — it is technical debt, and the PR should not merge.
