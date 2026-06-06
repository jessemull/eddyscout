# Cursor Rules ↔ Skills ↔ Application Consistency Audit

> **Purpose:** Record findings from the full consistency audit (rules, skills, governance docs, codebase).
> **Precedence:** Does not override `CONTEXT.md`, `AGENTS.md`, or `docs/GOVERNANCE.md`.
> **Last updated:** 2026-06-06

---

## Summary

| Severity | Count | Action |
|----------|-------|--------|
| MUST fix (contradiction / broken reference) | 4 | Fixed in same PR as this doc |
| SHOULD align (wording / examples) | 6 | Fixed or documented |
| Document gap (aspirational vs. code) | 9 | `docs/ARCHITECTURE.md` § Current implementation status |
| Code backlog (optional follow-up) | 5 | Tracked below; not blocking docs |

---

## Rule ↔ skill mapping

| Rule | Skills | Canonical doc | Status |
|------|--------|---------------|--------|
| `000-context` | (all) | `CONTEXT.md` | Aligned mandatory doc list |
| `010-architecture` | `feature-development`, `riverpod-usage` | `ARCHITECTURE.md` | App shell + partial layers documented |
| `020-state-riverpod` | `state-management`, `riverpod-usage` | `STATE_MANAGEMENT.md` | `@riverpod` = new code preference |
| `030-navigation-go-router` | `navigation-change` | `NAVIGATION.md` | Package/app router split documented |
| `040-testing` | `testing`, `golden-testing` | `TESTING.md` | Examples use real paths |
| `050-codegen` | `code-generation` | `CODEGEN.md` | Aligned |
| `060-security` | `security-review` | `SECURITY.md` | Secure storage qualified |
| `070-performance` | `performance-profiling` | `PERFORMANCE.md` | CachedNetworkImage qualified |
| `080-comments` | — | `COMMENTS.md` | Aligned |
| `090-widgets` | `form-creation`, `responsive-ui-validation`, `accessibility-review` | `UI.md` | App `screens/` noted |
| `100-imports-boundaries` | `feature-development`, `riverpod-usage` | `ARCHITECTURE.md` | Diagram correct |

**Review-only skills:** `pr-review`, `repo-review`, `commit`, `push-validation`, `debugging`, `dependency-upgrade`, `localization`, `platform-specific` — doc references verified; no phantom `docs/*.md` paths.

---

## Findings (resolved in documentation)

### MUST fix

| ID | Finding | Files changed |
|----|---------|---------------|
| M1 | `CONTEXT.md` used linear `presentation → domain → data` | `CONTEXT.md` |
| M2 | Fictional `test/features/auth/` examples | `040-testing.mdc`, `testing/SKILL.md` |
| M3 | Router described only in `packages/routing/` | `010-architecture.mdc`, `030-navigation-go-router.mdc`, `navigation-change/SKILL.md`, `feature-development/SKILL.md` |
| M4 | `000-context` missing mandatory doc names from `CONTEXT.md` | `000-context.mdc` |

### SHOULD align

| ID | Finding | Resolution |
|----|---------|------------|
| S1 | Test naming `should X when Y` vs `group('Name')` | Hybrid guidance in `040-testing`, `testing` skill |
| S2 | Golden path: `test/goldens/` vs `_golden_test.dart` | Both allowed; `TESTING.md` + `golden-testing` aligned |
| S3 | `StatefulShellRoute` / session auth guards | Marked required when adding tabs/protected routes |
| S4 | `ref.read` in widgets | Clarified: callbacks/init OK; not in `build()` for reactive reads |
| S5 | Primary UI in `apps/eddyscout/lib/screens/` | `010-architecture`, `090-widgets`, `feature-development` |
| S6 | `packages/routing` scaffold | Resolved — router assembly in package; typed routes in app |

### Aspirational vs. current code (documented, not enforced as present)

| Policy | Current repo | Guidance |
|--------|--------------|----------|
| `@riverpod` codegen | **Done** — conditions, map, hydro, app shell, routing | New providers MUST use `@riverpod` |
| `Result<T, AppFailure>` at boundaries | **Done** — conditions repos/providers/callables; hydro/map `AsyncError` with typed failures | New I/O at package boundaries MUST use `Result` or typed `AppFailure` via `AsyncError` |
| Golden tests (design system) | `app_theme_golden_test.dart` in design_system | Required for new design-system widgets |
| `integration_test/` | Map → launch detail journey + token gate | Expand when adding new critical E2E flows |
| `StatefulShellRoute` | Not used | Required when adding tab shell navigation |
| Session auth router guards | Token/web redirects only | Required when adding protected routes |
| `flutter_secure_storage` | Not in pubspecs | Required when storing tokens/credentials |
| `CachedNetworkImage` | Not used | Required when adding remote image UI |
| `CancelToken` on Dio | Partial / networking layer | Required for new HTTP calls per `docs/NETWORKING.md` |
| Full 3-layer feature packages | Partial; UI in app shell | Target layout per `_TEMPLATE`; see `ARCHITECTURE.md` |

---

## Code backlog (optional follow-up PRs)

1. ~~Add golden tests under `packages/design_system/test/goldens/`.~~ Done.
2. ~~Pilot `@riverpod` on one new or refactored provider.~~ Done (wave 2 A1).
3. ~~Adopt `Result` in one feature repository boundary.~~ Done (wave 2 A2).
4. ~~Move router assembly into `packages/routing` when route count grows.~~ Done.
5. Migrate app-shell screens into feature `presentation/` packages (wave 3).

---

## Validation commands

```bash
rg 'features/auth|test/unit/' .cursor docs
rg 'presentation/.*→.*domain/.*→.*data' CONTEXT.md AGENTS.md .cursor docs --glob '*.{md,mdc}'
```

Expected: no `features/auth` or `test/unit/` in cursor/docs; no linear three-arrow dependency chain in governance text.
