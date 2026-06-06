# EddyScout — architecture & platform backlog

> **Purpose:** Single checklist for repo/platform architecture work (not product features).
> **Product roadmap:** `docs/ROADMAP.md`
> **Target architecture:** `docs/ARCHITECTURE.md`
> **Last updated:** 2026-06-06 · **Product phases:** `docs/ROADMAP.md` § Execution order

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
| `packages/routing/` as live router | **Done** | `goRouterProvider` + redirects in routing package (#26) |
| Result-based repos (conditions data layer) | **Done** | Repository impls return `Result<T, AppFailure>` |
| Result-based providers & boundaries | **Done** | Conditions (#33), hydro (#32), map (#28); `ARCHITECTURE.md` Result row **Done** |
| Full feature layering (`presentation` / `domain` / `data`) | **Wave 3** | Most UI still in `apps/eddyscout/lib/screens/` — planned migration |
| Integration tests (E2E) | **Done** | Token gate + map → launch detail; CI Linux deps (#22, #25, #27) |
| CancelToken on HTTP / callables | **Done** (conditions) | Extend when adding new I/O in other features |

### Implement alongside product features (not platform backlog)

These are **not** wave 2/3 blockers — add when the feature that needs them ships:

| Area | Trigger |
|------|---------|
| `flutter_secure_storage` | Real auth / credential storage |
| `StatefulShellRoute` / tab shell | Multi-tab navigation |
| `CachedNetworkImage` | Remote image UI |
| Session auth router guards | Protected routes beyond Mapbox token |

---

## Shipped (wave 1 — do not re-open)

| PR | Scope |
|----|-------|
| #19 | Riverpod 3 foundation |
| #20 | A1 conditions `@riverpod` |
| #21 | A1 app-shell `@riverpod` |
| #22 | A4 integration tests + docs |
| #23 | A1 map + hydro `@riverpod` |
| #24 | Fast git hooks |
| #25 | CI Linux integration deps |
| #26 | A3 router → `packages/routing/` |
| #27 | Integration l10n fix |
| #28 | Wave 3 planning + map `launchPointByIdProvider` Result (#28 also shipped `4c799f0`) |
| #29 | PR review skill output sections |
| #30 | A1 routing `@riverpod` codegen |
| #32 | A2 hydro Result / `AppFailure` surfacing |
| #33 | A2 conditions Result completion |

---

## Remaining work (checklist)

### Bucket A — wave 2 (finish completely)

#### A1 — `@riverpod` codegen

- [x] Conditions, map, hydro, app shell providers
- [x] **`goRouterProvider` (+ related routing providers) → `@riverpod`**
- [x] `make gen`, `docs/CODEGEN.md`, `docs/STATE_MANAGEMENT.md`

#### A2 — `Result<T, AppFailure>` completion

- [x] **Conditions providers:** no `throw ConditionsLoadException` / `throw Exception` in providers; `AsyncError` carries `AppFailure`; UI reads `AppFailure` from `AsyncValue.error`
- [x] **Conditions callables:** `conditions_callables.dart` returns `Result` (or throws only inside repo impl after mapping); no raw `FirebaseAuthException` / `StateError` across boundaries
- [x] **Conditions service:** remove or isolate `loadUnwrapped` rethrow paths used by providers
- [x] **Hydro:** `hydroGeoJsonLoader` + `riverRoutePlannerProvider` surface load/parse failures as `AppFailure` via `AsyncError` (#32)
- [x] **Map:** `launchPointByIdProvider` throws `NotFoundFailure` for unknown ids — no `StateError`; unknown-id path tested (#28)
- [x] Update `docs/ARCHITECTURE.md` § Current implementation status — mark Result row **Done** when all above are `[x]`

#### A3 — Router package

- [x] Move `GoRouter` assembly to `packages/routing/` (#26)
- [x] App consumes `goRouterProvider` from routing package (#26)
- [x] Update `docs/NAVIGATION.md` (#26)

#### A4 — Tests & docs hygiene

- [x] Integration tests + CI (#22, #25, #27)
- [x] `docs/CURSOR_CONSISTENCY_AUDIT.md` integration row (#22)
- [x] **Final doc sweep** after wave 2 merges: `ARCHITECTURE.md`, `CURSOR_CONSISTENCY_AUDIT.md` aspirational rows, this file

### Bucket B — wave 3 (follow wave 2, before heavy Phase C)

Screen migration is **planned platform work**, not indefinite defer. Run after wave 2 merges to avoid conflicting with Result/router refactors.

- [ ] **Conditions presentation:** `launch_detail_screen` + `launch_detail/*` → `packages/features/conditions/lib/src/presentation/`
- [ ] **Map presentation:** `map_screen`, planning overlay, `map_planning` / `map_session` providers → `packages/features/map/lib/src/presentation/`
- [ ] **Mapbox layer:** controller + mixins → map package (or documented app-shell exception with thin facade)
- [ ] **App shell screens:** `missing_mapbox_token`, `web_map_placeholder` — stay in app or move to routing; `app_routes.dart` imports from packages
- [ ] **Tests:** move/update `apps/eddyscout/test/screens/` to match package layout
- [ ] **Docs:** `ARCHITECTURE.md` feature layering row → **Done**; Bucket B all `[x]`

---

## Wave 2 — parallel agents (Bucket A code)

Use **Cursor New Worktree** → branch from `main` → `/start <branch>` → **plan-first** (§4 in `~/.cursor/commands/start.md`).

**Rule:** Each agent owns **one PR** that **fully closes** its checklist items.

| Agent | Branch | Closes |
|-------|--------|--------|
| 1 | `chore/riverpod-codegen-router` | A1 entirely |
| 2 | `refactor/result-conditions-complete` | A2 conditions (all bullets) — **done** |
| 3 | `refactor/result-hydro-complete` | A2 hydro bullet — **done** |
| 4 | `refactor/result-map-complete` | A2 map bullet — **done** via #28 (`4c799f0`) |
| 5 | `docs/roadmap-phase-cleanup` | A4 final sweep + wave 2 backlog accuracy + sync `ROADMAP.md` execution order — **in progress** |

**Merge order:** 1–4 in any order (minimal overlap); **5 last**.

---

## Wave 3 — parallel agents (Bucket B — after wave 2)

**Do not start until wave 2 is merged to `main`.** Phase C product work should target feature `presentation/` packages — wave 3 clears existing app-shell debt first.

| Agent | Branch | Closes |
|-------|--------|--------|
| 1 | `refactor/presentation-conditions` | Conditions presentation slice + tests |
| 2 | `refactor/presentation-map-ui` | Map screen, overlay, planning/session providers |
| 3 | `refactor/presentation-mapbox` | Mapbox controller + mixins |
| 4 | `refactor/presentation-app-shell` | Token/web screens + `app_routes` import cleanup |
| 5 | `docs/architecture-wave3-closeout` | Bucket B all `[x]`, `ARCHITECTURE.md` layering row |

**Merge order:** 1–3 can parallel; **4** after 1–2 (routes import new paths); **5** last.

---

## After wave 3

When Bucket A + Bucket B are fully `[x]`:

- **Platform architecture is complete** for the current target.
- **Product work:** `docs/ROADMAP.md` — **Execution order** step 3 (Phase C: GPX, trip log, saved routes, moderation, etc.).
- **New features:** build in `packages/features/<name>/presentation/` from day one; do not add screens under `apps/eddyscout/lib/screens/`.
- **Infra deferrals:** implement `flutter_secure_storage`, tab shell, `CachedNetworkImage`, auth guards **with** the feature that needs them (see table above).
- **Roadmap hygiene:** keep `ROADMAP.md` § Recommended next implementation aligned when Phase C priorities shift.

---

## References

- Router: `packages/routing/lib/src/go_router_provider.dart`
- App routes: `apps/eddyscout/lib/routing/app_routes.dart`
- Conditions Result pattern: `launch_reports_digest_provider.dart`
- App screens (wave 3 source): `apps/eddyscout/lib/screens/`
- Integration tests: `apps/eddyscout/integration_test/`
