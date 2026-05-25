# Migrations

> **Precedence**: CONTEXT.md > GOVERNANCE.md > ARCHITECTURE.md > this document
>
> **AI agents**: Read this for where migrated code lives today. Phases M1–M6 are complete; the app shell under `apps/eddyscout/lib/` is composition-only (screens, go_router, preferences, debug).

## Overview

EddyScout was a single-package Flutter app and is now a melos monorepo. **Migration phases M1–M6 are complete.** Domain, data, and shared providers live in `packages/features/` and shared packages; the app imports them via `eddyscout_conditions`, `eddyscout_map`, and `eddyscout_hydro_routing`.

Duplicate trees that remained under `apps/eddyscout/lib/{conditions,data,decision,firebase,network}/` after M5 were removed in the final inventory sync (they were not referenced by the app).

Use this document as a **layout map**, not an active migration checklist.

## Migration Phases

### Phase M1 — State Management (Provider → Riverpod)

**Status**: Complete

The app uses Riverpod for shared and async application state. Remaining `StatefulWidget` / `setState` usage is limited to ephemeral UI (report sheet form, Mapbox platform handles).

| Action | Target | Status |
|--------|--------|--------|
| Add `ProviderScope` to `main.dart` | `apps/eddyscout/lib/main.dart` | Done |
| Convert `MapScreen` state to Riverpod providers | `apps/eddyscout/lib/screens/map_screen.dart` | Done |
| Convert `LaunchDetailScreen` state to Riverpod providers | `apps/eddyscout/lib/screens/launch_detail_screen.dart` | Done |
| Extract preferences as Riverpod providers | `apps/eddyscout/lib/preferences/go_no_go_profile_prefs.dart` | Done |

### Phase M2 — Navigation (MaterialApp → go_router)

**Status**: Complete

Navigation uses `MaterialApp.router` with typed `go_router_builder` routes in `apps/eddyscout/lib/routing/`. Platform/token redirects live in `app_router_provider.dart`.

| Action | Target | Status |
|--------|--------|--------|
| Replace `MaterialApp` with `MaterialApp.router` | `apps/eddyscout/lib/main.dart` | Done |
| Define typed routes for all screens | `apps/eddyscout/lib/routing/app_routes.dart` | Done |
| Replace `Navigator.push` with `context.go`/`context.push` | All screen files | Done |

### Phase M3 — Networking (http → dio)

**Status**: Complete

Conditions HTTP uses Dio via `EddyScoutHttpClient` and `EddyScoutDioFactory` in `packages/networking/`. Firebase callables unchanged (Cloud Functions SDK).

| Action | Target | Status |
|--------|--------|--------|
| Replace `http` client with `Dio` | `apps/eddyscout/lib/network/eddy_scout_http_client.dart` | Done |
| Add interceptors (retry, logging) | `packages/networking/` | Done |
| Update all API call sites | `conditions_service.dart`, `conditions_provider.dart` | Done |
| Firebase callables | `conditions_callables.dart` | N/A — not HTTP |

### Phase M4 — Models (classes → freezed)

**Status**: Complete

Domain and payload models use `@freezed` with `json_serializable` where JSON is required (conditions, launch summary, Firebase payload).

| Action | Target | Status |
|--------|--------|--------|
| Convert launch models to freezed | `apps/eddyscout/lib/data/launch_models.dart` | Done |
| Convert conditions models to freezed | `apps/eddyscout/lib/conditions/conditions_models.dart` | Done |
| Convert decision models to freezed | `go_no_go.dart`, `go_no_go_thresholds.dart` | Done |
| Convert route result to freezed | `apps/eddyscout/lib/routing/route_result.dart` | Done |
| Convert Firebase payloads to freezed | `conditions_summary_payload.dart` | Done |

### Phase M5 — Architecture (flat → feature-first)

**Status**: Complete (domain/data/providers); screens remain app composition layer

Feature packages live under `packages/features/`. The app shell (`apps/eddyscout/lib/`) keeps screens, go_router, preferences, and debug tooling to avoid cross-feature presentation imports.

| Legacy Directory | Target Package | Status |
|-----------------|----------------|--------|
| `lib/screens/` | `apps/eddyscout/lib/screens/` (composition) | Done — split into focused files (`launch_detail/`, `map/`) |
| `lib/conditions/` | `packages/features/conditions/` | Done |
| `lib/data/` | `packages/features/map/` | Done |
| `lib/decision/` | `packages/features/conditions/` (domain) | Done |
| `lib/firebase/` | `packages/features/conditions/` (data) | Done |
| `lib/network/` | `packages/networking/` | Done — `EddyScoutHttpClient` |
| `lib/routing/` (river graph) | `packages/features/hydro_routing/` | Done |
| `lib/routing/` (go_router) | `apps/eddyscout/lib/routing/` | Done — stays in app |
| `lib/preferences/` | `persistence` + `conditions` (repository) / app (providers) | Done |
| `lib/debug/` | `apps/eddyscout/lib/debug/` | Done — unchanged |

### Phase M6 — Analysis Baseline Removal

**Status**: Done

The app uses `tooling/analysis_options.app.yaml` (strict package rules; `public_member_api_docs: false` in the app shell only).
Preflight and CI run `dart analyze --fatal-infos` on all workspace packages **including** `apps/eddyscout`.

`tooling/analysis_options.legacy_app.yaml` was removed. Feature packages now inherit
`tooling/analysis_options.package.yaml` (only style-only `prefer_*` bodies/methods remain ignored).

## Current layout (post-M6)

Paths below are relative to the repo root. **Status** is the migration outcome (all **Done** unless noted).

### App shell — `apps/eddyscout/lib/`

Composition, navigation, and app-only Riverpod wiring. Imports feature packages; does not duplicate domain/data.

| Path | Role | Phases | Status |
|------|------|--------|--------|
| `main.dart` | `ProviderScope`, Firebase init, `MaterialApp.router` | M1, M2 | Done |
| `routing/app_routes.dart` | Typed `go_router_builder` routes | M2 | Done |
| `routing/app_router_provider.dart` | `goRouterProvider`, token/web redirects | M2 | Done |
| `screens/map_screen.dart` | Map composition; Mapbox widget host | M1, M5 | Done |
| `screens/map/mapbox_map_controller.dart` | Mapbox lifecycle (`mapboxMapControllerProvider`) | M1, follow-up | Done |
| `screens/map/map_constants.dart` | Map style / camera constants | M5 | Done |
| `screens/map/map_planning_overlay.dart` | Route planning UI overlay | M5 | Done |
| `screens/map/map_ui_callbacks.dart` | Map gesture callbacks (types) | M5 | Done |
| `screens/map/map_ui_callbacks_provider.dart` | Callback holder provider | M1 | Done |
| `screens/map_planning_provider.dart` | `routePlanningProvider` | M1 | Done |
| `screens/map_session_provider.dart` | `mapInteractiveProvider` | M1 | Done |
| `screens/launch_detail_screen.dart` | Launch detail page | M1, M5 | Done |
| `screens/launch_detail/helpers.dart` | Part: shared helpers | M5 | Done |
| `screens/launch_detail/widgets_conditions.dart` | Part: conditions cards | M5 | Done |
| `screens/launch_detail/widgets_reports.dart` | Part: reports UI | M5 | Done |
| `screens/missing_mapbox_token_screen.dart` | `--dart-define` gate | M2 | Done |
| `screens/web_map_placeholder_screen.dart` | Web placeholder | M2 | Done |
| `preferences/key_value_store_provider.dart` | `KeyValueStore` → persistence | M1, M5 | Done |
| `preferences/go_no_go_profile_provider.dart` | Skill profile Riverpod | M1, M5 | Done |
| `debug/map_debug_log.dart` | Debug-only map/route logging | — | Keep in app |

**Removed from app shell (duplicate of feature packages):** `lib/conditions/`, `lib/data/`, `lib/decision/`, `lib/firebase/`, `lib/network/` — deleted after M5; no `package:eddyscout/...` imports remained.

### Feature — `packages/features/conditions/`

| Area | Path (under `lib/`) | Phases | Status |
|------|---------------------|--------|--------|
| Domain models | `src/domain/conditions_models.dart` | M4, M5 | Done |
| Go/no-go | `src/domain/go_no_go.dart`, `go_no_go_thresholds.dart` | M4, M5 | Done |
| HTTP service | `src/data/conditions_service.dart` | M3, M5 | Done |
| Providers | `src/data/conditions_provider.dart`, `conditions_http_provider.dart` | M1, M3, M5 | Done |
| Parsing | `src/data/parsing/*.dart` (NWS, NOAA, USGS, Open-Meteo, wind) | M5 | Done |
| Firebase | `src/data/firebase/*.dart` (callables, bootstrap, flags, payloads) | M3, M4, M5 | Done |
| Reports / AI | `src/data/condition_reports_provider.dart`, `conditions_ai_summary_provider.dart` | M1, M5 | Done |
| Profile repo | `src/data/repositories/go_no_go_profile_repository.dart` | M1, M5 | Done |
| Presentation | `src/presentation/condition_reports_refresh_token_provider.dart` | M5 | Done |
| Barrel | `eddyscout_conditions.dart` | M5 | Done |

### Feature — `packages/features/map/`

| Path | Role | Phases | Status |
|------|------|--------|--------|
| `src/data/launch_points.dart` | Static launch catalog | M5 | Done |
| `src/data/launch_providers.dart` | `launchPointByIdProvider`, etc. | M1, M5 | Done |
| `eddyscout_map.dart` | Barrel; re-exports `LaunchPoint` from `packages/core` | M4, M5 | Done |

Launch **models** (`LaunchPoint`, `LaunchFlowBands`) live in `packages/core/lib/src/launch_models.dart` (M4).

### Feature — `packages/features/hydro_routing/`

| Path | Role | Phases | Status |
|------|------|--------|--------|
| `src/data/geodesy.dart` | Distance / bearing helpers | M5 | Done |
| `src/data/river_geojson.dart` | Bundled hydro geometry load | M5 | Done |
| `src/data/river_graph.dart` | Graph over river network | M5 | Done |
| `src/data/river_route_planner.dart` | Route planning | M5 | Done |
| `src/data/river_route_planner_provider.dart` | `riverRoutePlannerProvider` | M1, M5 | Done |
| `src/data/hydro_debug_log.dart` | Debug logging hook | M5 | Done |
| `src/domain/route_result.dart` | `@freezed` success/failure union | M4, M5 | Done |
| `eddyscout_hydro_routing.dart` | Barrel | M5 | Done |

### Shared packages (extracted from app `lib/network/` and governance)

| Package | Replaces legacy app path | Phases | Status |
|---------|--------------------------|--------|--------|
| `packages/networking/` | `lib/network/eddy_scout_http_client.dart` | M3, M5 | Done |
| `packages/persistence/` | Preferences storage abstraction | M5 | Done |
| `packages/core/` | Shared `LaunchPoint`, `Result`, `AppFailure` | M4, M5 | Done |
| `packages/routing/` | Workspace router assembly (when used) | M2+ | Scaffold |
| `packages/design_system/`, `analytics/`, `localization/` | Governance baseline | — | Scaffold |

## Migration Order

Recommended migration order to minimize risk:

1. **M1** — Add Riverpod (non-breaking, additive)
2. **M4** — Convert models to freezed (can coexist with old code)
3. **M3** — Swap http → dio (isolated to network layer)
4. **M2** — Swap Navigator → go_router (requires touching all screens)
5. **M5** — Extract feature packages (largest refactor)
6. **M6** — Done (app on strict `analysis_options.app.yaml`; feature packages on package profile)

## Post-migration follow-ups

All items complete:

1. ~~**Map controller extraction**~~ — `mapboxMapControllerProvider` in `screens/map/mapbox_map_controller.dart`.
2. ~~**Feature-package analysis tightening**~~ — Feature packages on `tooling/analysis_options.feature.yaml` (package strict + two deferred style rules).
3. ~~**Legacy inventory doc sync**~~ — This section replaced the stale per-file inventory; orphan `apps/eddyscout/lib/{conditions,data,decision,firebase,network}/` trees removed.

**Not part of M1–M6 (optional later):** drop the two feature `prefer_*` style ignores, tighten test `analysis_options`, remove `source_gen` override when codegen deps align.

## Rules

- Never migrate more than one module at a time
- Every migration must include tests
- Every migration must pass `make preflight`
- Migration PRs must be reviewed by a human
- Generated files must be committed with the migration
- Update this document as migrations are completed
