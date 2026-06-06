# EddyScout — architecture & platform backlog

> **Purpose:** Single checklist for repo/platform architecture work (not product features).
> **Product roadmap:** `docs/ROADMAP.md`
> **Target architecture:** `docs/ARCHITECTURE.md`
> **Last updated:** 2026-06-06

Tick `- [ ]` → `- [x]` **only when the slice is fully done** — no “partially done” rows left behind. Link PRs inline.

---

## Platform status (summary)

| Area | Status | Notes |
|------|--------|-------|
| Monorepo / melos / preflight / husky | **Done** | Fast pre-commit; full gate on pre-push + CI (#24) |
| 85% coverage gates | **Done** | `tooling/coverage.yaml`; CI enforces thresholds |
| Design system goldens + CI strategy | **Done** | Goldens on `macos-latest`; Ubuntu excludes `golden` tag |
| Riverpod 3 (manual providers) | **Done** | PR #19 |
| `@riverpod` codegen migration | **Done** | Conditions, app shell, map, hydro (#20–#21, #23); routing providers in `packages/routing/` |
| `packages/routing/` as live router | **Done** | `goRouterProvider` + redirects in routing package; app overrides routes + launch validation (#26) |
| Result-based repos (conditions data layer) | **Done** | Repository impls return `Result<T, AppFailure>` |
| Result-based providers (conditions UI layer) | **Open** | Providers still `throw` on failure → wrong error types in `AsyncError` |
| Result-based boundaries (map / hydro) | **Open** | Map throws `StateError`; hydro propagates raw parse/load exceptions |
| Firebase callables (conditions) | **Open** | `conditions_callables.dart` still throws; repos catch — finish callable → Result at data boundary |
| Full feature layering (`presentation` / `domain` / `data`) | **Deferred (B)** | Most UI in `apps/eddyscout/lib/screens/` |
| Integration tests (E2E) | **Done** | Token gate + map → launch detail; CI Linux desktop deps (#22, #25, #27) |
| CancelToken on HTTP / callables | **Done** (conditions) | Extend when adding new I/O in other features |

### Deferred until a product feature needs them

| Area | Trigger |
|------|---------|
| `flutter_secure_storage` | Real auth / credential storage |
| `StatefulShellRoute` / tab shell | Multi-tab navigation |
| `CachedNetworkImage` | Remote image UI |
| Session auth router guards | Protected routes beyond Mapbox token |
| Bucket B screen migration | Feature forces `presentation/` package move |

---

## Shipped (wave 1 — do not re-open)

| PR | Scope |
|----|-------|
| #19 | Riverpod 3 foundation |
| #20 | A1 conditions `@riverpod` |
| #21 | A1 app-shell `@riverpod` |
| #22 | A4 integration tests + docs |
| #23 | A1 map + hydro `@riverpod` |
| #24 | Fast git hooks + backlog doc |
| #25 | CI Linux integration deps |
| #26 | A3 router → `packages/routing/` |
| #27 | Integration l10n fix |

---

## Remaining work (checklist)

### Bucket A — finish completely (wave 2)

#### A1 — `@riverpod` codegen

- [x] Conditions, map, hydro, app shell providers
- [x] **`goRouterProvider` (+ related routing providers) → `@riverpod`**
- [x] `make gen`, `docs/CODEGEN.md`, `docs/STATE_MANAGEMENT.md`

#### A2 — `Result<T, AppFailure>` completion

- [ ] **Conditions providers:** no `throw ConditionsLoadException` / `throw Exception` in providers; `AsyncError` carries `AppFailure`; UI reads `AppFailure` from `AsyncValue.error`
- [ ] **Conditions callables:** `conditions_callables.dart` returns `Result` (or throws only inside repo impl after mapping); no raw `FirebaseAuthException` / `StateError` across boundaries
- [ ] **Conditions service:** remove or isolate `loadUnwrapped` rethrow paths used by providers
- [ ] **Hydro:** `hydroGeoJsonLoader` + `riverRoutePlannerProvider` surface load/parse failures as `AppFailure` via `AsyncError`
- [ ] **Map:** `launchPointByIdProvider` uses `Result` or `NotFoundFailure` — no `StateError` throw; unknown-id path tested
- [ ] Update `docs/ARCHITECTURE.md` § Current implementation status — mark Result row **Done** when all above are `[x]`

#### A3 — Router package

- [x] Move `GoRouter` assembly to `packages/routing/` (#26)
- [x] App consumes `goRouterProvider` from routing package (#26)
- [x] Update `docs/NAVIGATION.md` (#26)

#### A4 — Tests & docs hygiene

- [x] Integration tests + CI (#22, #25, #27)
- [x] `docs/CURSOR_CONSISTENCY_AUDIT.md` integration row (#22)
- [ ] **Final doc sweep** after wave 2 merges: `ARCHITECTURE.md`, `CURSOR_CONSISTENCY_AUDIT.md` aspirational rows, this file — no stale “partial” language

### Bucket B — defer

- [ ] Move `apps/eddyscout/lib/screens/*` into feature `presentation/` packages
- [ ] Align `map` with full `presentation` / `domain` / `data` split

---

## Wave 2 — five parallel agents (complete slices)

Use **Cursor New Worktree** → branch from `main` → `/start <branch>` → **plan-first** (§4 in `~/.cursor/commands/start.md`).

**Rule:** Each agent owns **one PR** that **fully closes** its checklist items. Do not merge with “partially done” notes.

| Agent | Branch | Closes |
|-------|--------|--------|
| 1 | `chore/riverpod-codegen-router` | A1 entirely |
| 2 | `refactor/result-conditions-complete` | A2 conditions (all bullets) |
| 3 | `refactor/result-hydro-complete` | A2 hydro bullet |
| 4 | `refactor/result-map-complete` | A2 map bullet |
| 5 | `docs/architecture-wave2-closeout` | A4 final sweep + this backlog accuracy |

**Merge order:** 1–4 in any order (minimal overlap); **5 last** (or rebase after 1–4 merge).

---

## After wave 2

When all A1–A4 boxes are `[x]`:

- **Architecture platform work is done** for now.
- **Next work:** `docs/ROADMAP.md` Phase C (GPX, trip log, saved routes, moderation, etc.).
- **Bucket B** only when a product feature forces screen migration.

---

## References

- Router: `packages/routing/lib/src/go_router_provider.dart`
- App routes: `apps/eddyscout/lib/routing/app_routes.dart`
- Conditions Result pattern: `launch_reports_digest_provider.dart`
- Integration tests: `apps/eddyscout/integration_test/`
