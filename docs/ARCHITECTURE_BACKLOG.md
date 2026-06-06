# EddyScout — architecture & platform backlog

> **Purpose:** Single checklist for repo/platform architecture work (not product features).
> **Product roadmap:** `docs/ROADMAP.md`
> **Target architecture:** `docs/ARCHITECTURE.md`
> **Last updated:** 2026-06-06

Tick `- [ ]` → `- [x]` here when work ships. Link PRs inline when helpful.

---

## Platform status (summary)

| Area | Status | Notes |
|------|--------|-------|
| Monorepo / melos / preflight / husky | **Done** | Fast pre-commit; full gate on pre-push + CI |
| 85% coverage gates | **Done** | `tooling/coverage.yaml`; CI enforces thresholds |
| Design system goldens + CI strategy | **Done** | Goldens on `macos-latest`; Ubuntu excludes `golden` tag |
| Riverpod 3 (manual providers) | **Done** | Merged PR #19 |
| Result-based repos + DI layering (conditions) | **Partial** | Domain repo contracts + data impls + app binding; providers still bridge via exceptions |
| `@riverpod` codegen migration | **Nearly done** | Conditions (#20), app shell (#21), map + hydro (#23); **`goRouterProvider` still manual** |
| Full feature layering (`presentation` / `domain` / `data` in packages) | **Partial** | Conditions has domain + data + one presentation provider; most UI in `apps/eddyscout/lib/screens/` |
| `packages/routing/` as live router | **Scaffold only** | Live router in `apps/eddyscout/lib/routing/` — Agent #4 / A3 not merged |
| `Result<T, AppFailure>` everywhere | **Partial** | Conditions repository boundaries only; `map` / `hydro_routing` not migrated |
| Integration tests (E2E) | **Done** | Token gate + map → launch detail journey; CI `integration-test` job (PR #22) |
| CancelToken on HTTP / callables | **Done** (conditions) | Extend when adding new I/O in other features |

### Deferred until a product feature needs them

| Area | Status | Trigger |
|------|--------|---------|
| `flutter_secure_storage` | Not started | Real auth / credential storage |
| `StatefulShellRoute` / tab shell | Not started | Multi-tab navigation |
| `CachedNetworkImage` | Not started | Remote image UI |
| Session auth router guards | Not started | Protected routes beyond Mapbox token |

---

## Merged PR audit (wave 1 — last four merges)

Verification against `main` @ PR #23 merge (`08a004a`).

| PR | Branch | Verdict | Evidence on `main` |
|----|--------|---------|-------------------|
| **#20** | `chore/riverpod-codegen-conditions` | **Solid** | `packages/features/conditions/build.yaml`; all conditions providers have `.g.dart`; refresh token pilot in production; `docs/CODEGEN.md` + `docs/STATE_MANAGEMENT.md` updated |
| **#21** | `chore/riverpod-codegen-app` | **Solid** | `go_no_go_profile`, `key_value_store`, `map_planning`, `map_session`, `mapbox_map_controller` use `@Riverpod`; tests updated. **`goRouterProvider` intentionally still `Provider<GoRouter>`** |
| **#22** | `test/integration-map-launch-detail` | **Solid** | `integration_test/map_launch_detail_journey_test.dart` + harness; CI `integration-test` job with xvfb; `docs/TESTING.md`, `docs/CI_CD.md`, `docs/CURSOR_CONSISTENCY_AUDIT.md` updated; dependency-review workflow documented |
| **#23** | `chore/riverpod-codegen-map-hydro` | **Solid** | `launch_providers.g.dart`, `river_route_planner_provider.g.dart`; `riverpod_annotation` in map + hydro `pubspec.yaml`; provider tests added/updated |

**Wave 1 gaps (expected, not regressions):**

- A1: `goRouterProvider` not codegen'd (defer to router package move or follow-up)
- A3: Router package move — **not merged** (branch `refactor/routing-package` may still be open)
- A2: Result completion — **not started** (wave 2)
- `docs/ARCHITECTURE_BACKLOG.md` itself landed via PR #20/#21 trail (restored from `a225e25` note)

---

## Remaining work (checklist)

Complete **Bucket A** before returning to product features. **Bucket B** is optional / feature-gated.

### Bucket A — architecture completion

#### A1 — `@riverpod` codegen

- [x] Add `riverpod_annotation` / `riverpod_generator` + `build.yaml` to `eddyscout_conditions` (PR #20)
- [x] Migrate `condition_reports_refresh_token_provider` (pilot → production) (PR #20)
- [x] Migrate remaining conditions providers to `@riverpod` (PR #20)
- [x] Migrate map providers to `@riverpod` (PR #23)
- [x] Migrate hydro_routing providers to `@riverpod` (PR #23)
- [x] Migrate app-shell providers: `go_no_go_profile`, `map_planning`, `map_session`, `key_value_store`, `mapbox_map_controller` (PR #21)
- [ ] Migrate `goRouterProvider` to `@riverpod` (or as part of A3 router package move)
- [x] Run `make gen`; update tests for generated provider names
- [x] Update `docs/CODEGEN.md` and `docs/STATE_MANAGEMENT.md`

#### A2 — `Result<T, AppFailure>` completion

- [ ] Conditions: stop re-throwing in providers; surface `AppFailure` via `AsyncError` consistently
- [ ] Map: adopt `Result` at repository / I/O boundaries when I/O is added or refactored
- [ ] Hydro routing: adopt `Result` at planner / geometry load boundaries
- [ ] Firebase callables: wrap throws in `Result` at repository impl layer (conditions)
- [ ] Update `docs/ARCHITECTURE.md` § Current implementation status when done

#### A3 — Router package

- [ ] Move live `GoRouter` assembly from `apps/eddyscout/lib/routing/` to `packages/routing/`
- [ ] App shell consumes `goRouterProvider` from routing package
- [ ] Update `docs/NAVIGATION.md` examples

#### A4 — Tests & docs hygiene

- [x] Expand `integration_test/` (map → launch detail journey) (PR #22)
- [x] Sync `docs/CURSOR_CONSISTENCY_AUDIT.md` (PR #22)
- [x] Dependency review workflow documented + dependency graph enabled (PR #22 / repo settings)

### Bucket B — full target layout (defer)

- [ ] Move `apps/eddyscout/lib/screens/*` into feature `presentation/` packages
- [ ] Align `map` package with full `presentation` / `domain` / `data` split

> **Do not block product work on Bucket B.** Revisit when a feature forces a screen move.

---

## Suggested PR sequence

| PR | Scope | Bucket | Status |
|----|-------|--------|--------|
| #20 | `@riverpod` codegen — conditions | A1 | Merged |
| #21 | `@riverpod` codegen — app shell (excl. router) | A1 | Merged |
| #23 | `@riverpod` codegen — map + hydro | A1 | Merged |
| #22 | Integration tests + A4 docs hygiene | A4 | Merged |
| Next | Router → `packages/routing/` (+ `goRouterProvider`) | A3 | Open |
| Next | `Result` completion — conditions + map/hydro | A2 | Open |

After A2–A3 (and `goRouterProvider` codegen), treat platform architecture as **done for now** and use `docs/ROADMAP.md` for product work.

---

## References

- Pilot: `docs/examples/condition_reports_refresh_token_provider.riverpod_pilot.dart`
- Conditions repos: `packages/features/conditions/lib/src/domain/repositories/`
- Live router: `apps/eddyscout/lib/routing/app_router_provider.dart`
- Integration tests: `apps/eddyscout/integration_test/`
- Cursor audit: `docs/CURSOR_CONSISTENCY_AUDIT.md`
