# EddyScout — architecture & platform backlog

> **Purpose:** Single checklist for repo/platform architecture work (not product features).
> **Product roadmap:** `docs/ROADMAP.md`
> **Target architecture:** `docs/ARCHITECTURE.md`
> **Last updated:** 2026-06-05

Tick `- [ ]` → `- [x]` here when work ships. Link PRs inline when helpful.

---

## Platform status (summary)

| Area | Status | Notes |
|------|--------|-------|
| Monorepo / melos / preflight / husky | **Done** | `make preflight`, husky + commitlint |
| 85% coverage gates | **Done** | `tooling/coverage.yaml`; CI enforces thresholds |
| Design system goldens + CI strategy | **Done** | Goldens on `macos-latest`; Ubuntu excludes `golden` tag |
| Riverpod 3 (manual providers) | **Done** | Merged PR #19 (`chore/riverpod3-codegen-foundation`) |
| Result-based repos + DI layering (conditions) | **Partial** | Domain repo contracts + data impls + app binding; providers still bridge via exceptions |
| `@riverpod` codegen migration | **Not started** | Pilot: `docs/examples/condition_reports_refresh_token_provider.riverpod_pilot.dart` |
| Full feature layering (`presentation` / `domain` / `data` in packages) | **Partial** | Conditions has domain + data + one presentation provider; most UI in `apps/eddyscout/lib/screens/` |
| `packages/routing/` as live router | **Scaffold only** | Live router in `apps/eddyscout/lib/routing/` |
| `Result<T, AppFailure>` everywhere | **Partial** | Conditions repository boundaries only; `map` / `hydro_routing` not migrated |
| Integration tests (E2E) | **Done** | Token gate + map → launch detail journey in `apps/eddyscout/integration_test/`; CI `integration-test` job |
| CancelToken on HTTP / callables | **Done** (conditions) | Extend when adding new I/O in other features |

### Deferred until a product feature needs them

| Area | Status | Trigger |
|------|--------|---------|
| `flutter_secure_storage` | Not started | Real auth / credential storage |
| `StatefulShellRoute` / tab shell | Not started | Multi-tab navigation |
| `CachedNetworkImage` | Not started | Remote image UI |
| Session auth router guards | Not started | Protected routes beyond Mapbox token |

---

## Remaining work (checklist)

Complete **Bucket A** before returning to product features. **Bucket B** is optional / feature-gated.

### Bucket A — architecture completion (do now)

#### A1 — `@riverpod` codegen

- [ ] Add `riverpod_annotation` / `riverpod_generator` + `build.yaml` to packages that own providers (start with `eddyscout_conditions`)
- [ ] Migrate `condition_reports_refresh_token_provider` (pilot → production)
- [ ] Migrate remaining conditions providers to `@riverpod`
- [ ] Migrate app-shell providers (`go_no_go_profile`, `map_planning`, `map_session`, router, etc.)
- [ ] Run `make gen`; update tests for generated provider names
- [ ] Update `docs/CODEGEN.md` and `docs/STATE_MANAGEMENT.md`

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

- [x] Expand `integration_test/` (map → launch detail journey) — [compare branch](https://github.com/jessemull/eddyscout/compare/main...test/integration-map-launch-detail)
- [x] Sync `docs/CURSOR_CONSISTENCY_AUDIT.md` (remove stale backlog items) — same PR
- [x] Enable GitHub Dependency graph (or adjust `dependency-review` workflow) — dependency graph enabled in repo settings

### Bucket B — full target layout (defer)

- [ ] Move `apps/eddyscout/lib/screens/*` into feature `presentation/` packages
- [ ] Align `map` package with full `presentation` / `domain` / `data` split

> **Do not block product work on Bucket B.** Revisit when a feature forces a screen move.

---

## Suggested PR sequence

| PR | Scope | Bucket | Notes |
|----|-------|--------|-------|
| 1 | `@riverpod` codegen — conditions package (refresh token + remaining providers) | A1 | |
| 2 | `Result` completion — conditions provider bridge + map/hydro boundaries | A2 | |
| 3 | Router → `packages/routing` | A3 | |
| — | Integration tests + A4 docs hygiene | A4 | Shipped on `test/integration-map-launch-detail` |

After A1–A3, treat platform architecture as **done for now** and use `docs/ROADMAP.md` for product work. New code follows target patterns per `AGENTS.md`; no further migration sprints unless Bucket B is explicitly scheduled.

---

## References

- Pilot: `docs/examples/condition_reports_refresh_token_provider.riverpod_pilot.dart`
- Conditions repos: `packages/features/conditions/lib/src/domain/repositories/`
- Live router: `apps/eddyscout/lib/routing/app_router_provider.dart`
- Integration tests: `apps/eddyscout/integration_test/`
- Cursor audit (rules alignment): `docs/CURSOR_CONSISTENCY_AUDIT.md`
