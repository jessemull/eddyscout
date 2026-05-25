# Migrations

> **Precedence**: CONTEXT.md > GOVERNANCE.md > ARCHITECTURE.md > this document
>
> **AI agents**: Read this if your task touches legacy code under `apps/eddyscout/lib/`, migrating to Riverpod/go_router/dio/freezed, or addressing analyzer warnings from baseline suppression.

## Overview

The EddyScout app was originally a single-package Flutter app. It has been restructured into a melos monorepo with workspace packages. The existing application code under `apps/eddyscout/lib/` predates the governance system and uses patterns that do not conform to the target architecture.

This document tracks every legacy file and its migration path. **No legacy file should be modified without consulting this migration plan.**

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

**Status**: Not started

The app uses a flat directory structure. Must migrate to feature-first packages with presentation/domain/data layers.

| Legacy Directory | Target Package | Notes |
|-----------------|----------------|-------|
| `lib/screens/` | `packages/features/map/presentation/` | Map and launch detail screens |
| `lib/conditions/` | `packages/features/conditions/` | Conditions domain + data + parsing |
| `lib/data/` | `packages/features/map/data/` or `packages/core/` | Launch point data |
| `lib/decision/` | `packages/features/conditions/domain/` | Go/no-go decision logic |
| `lib/firebase/` | `packages/features/conditions/data/` | Firebase data sources |
| `lib/network/` | `packages/networking/` | HTTP client abstraction |
| `lib/routing/` | `packages/features/routing/` or domain-specific | River graph/routing logic |
| `lib/preferences/` | `packages/persistence/` | User preference storage |
| `lib/debug/` | `apps/eddyscout/lib/debug/` (keep) | Debug-only tooling |

### Phase M6 — Analysis Baseline Removal

**Status**: Not started

The legacy app uses `tooling/analysis_options.legacy_app.yaml` (lighter than package rules).
Preflight and CI run `dart analyze --fatal-infos` on workspace packages and
`dart analyze --no-fatal-warnings` on `apps/eddyscout` until migration completes.

As files are migrated, tighten the legacy app profile toward `analysis_options.app.yaml`.

Current baseline suppressions in `tooling/analysis_options.legacy_app.yaml`:
- `avoid_print: warning` → must become `error` after replacing `debugPrint` with logger
- `prefer_const_constructors: warning` → must become `error` after adding `const` where needed
- `prefer_const_declarations: warning` → must become `error`
- `prefer_const_literals_to_create_immutables: warning` → must become `error`

## Legacy File Inventory

Every Dart file in the legacy codebase with its migration status:

### `lib/main.dart`
- **Migration**: M1 (Riverpod ProviderScope), M2 (GoRouter)
- **Status**: M2 done — `MaterialApp.router` + `goRouterProvider`
- **Notes**: Token/web gate screens moved to `screens/` and routed via go_router.

### `lib/screens/map_screen.dart` (26,547 lines)
- **Migration**: M1, M5
- **Status**: M1 done — route planning, planner load, map interactivity via Riverpod
- **Priority**: HIGH — God widget, must be decomposed (M5)
- **Notes**: Mapbox map instance, annotation managers, and tap cancelables remain in `ConsumerState` (platform lifecycle).

### `lib/screens/launch_detail_screen.dart` (37,263 lines)
- **Migration**: M1, M5
- **Status**: Done for M1 — `_ConditionReportSheet` keeps ephemeral form UI state only
- **Priority**: HIGH — God widget, must be decomposed (M5)
- **Notes**: M5 will extract nested cards and decompose the file.

### `lib/conditions/conditions_models.dart`
- **Migration**: M4
- **Status**: Done — `@freezed` + JSON for snapshot types

### `lib/conditions/conditions_service.dart`
- **Migration**: M3, M5
- **Status**: M3 done — Dio-backed HTTP; M5 moves to feature package

### `lib/conditions/conditions_provider.dart`
- **Migration**: M1
- **Status**: Done — `conditionsServiceProvider`, `conditionsSnapshotProvider`, `launchPointByIdProvider`

### `lib/conditions/parsing/nws_marine_cwf.dart`
- **Migration**: M5
- **Status**: Not started

### `lib/conditions/parsing/noaa_tides_json.dart`
- **Migration**: M5
- **Status**: Not started

### `lib/conditions/parsing/open_meteo_json.dart`
- **Migration**: M5
- **Status**: Not started

### `lib/conditions/parsing/usgs_iv_json.dart`
- **Migration**: M5
- **Status**: Not started

### `lib/conditions/parsing/nws_marine_json.dart`
- **Migration**: M5
- **Status**: Not started

### `lib/conditions/parsing/nws_json.dart`
- **Migration**: M5
- **Status**: Not started

### `lib/conditions/parsing/wind_parse.dart`
- **Migration**: M5
- **Status**: Not started

### `lib/data/launch_models.dart`
- **Migration**: M4
- **Status**: Done — `LaunchPoint`, `LaunchFlowBands` via freezed

### `lib/data/launch_points.dart`
- **Migration**: M5
- **Status**: Not started

### `lib/decision/go_no_go.dart`
- **Migration**: M4, M5
- **Status**: M4 done — `GoNoGoReason`, `GoNoGoResult` freezed; evaluator unchanged

### `lib/decision/go_no_go_thresholds.dart`
- **Migration**: M4, M5
- **Status**: M4 done — `GoNoGoThresholds`, `RiverFlowThresholds` freezed

### `lib/firebase/conditions_callables.dart`
- **Migration**: M3, M5
- **Status**: Not started

### `lib/firebase/condition_reports_provider.dart`
- **Migration**: M1
- **Status**: Done — report list + community digest Riverpod providers

### `lib/firebase/conditions_ai_summary_provider.dart`
- **Migration**: M1
- **Status**: Done — on-demand conditions AI summary Riverpod provider

### `lib/firebase/conditions_summary_payload.dart`
- **Migration**: M4, M5
- **Status**: M4 done — `ConditionsSummaryPayload` + `LaunchSummary` with `toJson`

### `lib/firebase/firebase_bootstrap.dart`
- **Migration**: M5
- **Status**: Not started

### `lib/firebase/firebase_flags.dart`
- **Migration**: M5
- **Status**: Not started

### `lib/network/eddy_scout_http_client.dart`
- **Migration**: M3
- **Status**: Done — Dio client with retry/logging via `packages/networking`

### `lib/preferences/go_no_go_profile_repository.dart`
- **Migration**: M1, M5
- **Status**: Done — Riverpod provider replaces static prefs helper
- **Notes**: `go_no_go_profile_provider.dart` exposes `goNoGoProfileProvider`; `shared_preferences_provider.dart` is shared for future prefs.

### `lib/preferences/go_no_go_profile_prefs.dart`
- **Migration**: M1, M5
- **Status**: Removed — replaced by repository + Riverpod provider

### `lib/routing/geodesy.dart`
- **Migration**: M5
- **Status**: Not started

### `lib/routing/river_geojson.dart`
- **Migration**: M5
- **Status**: Not started

### `lib/routing/river_graph.dart`
- **Migration**: M5
- **Status**: Not started

### `lib/routing/river_route_planner.dart`
- **Migration**: M5
- **Status**: Not started

### `lib/routing/river_route_planner_provider.dart`
- **Migration**: M1
- **Status**: Done — `riverRoutePlannerProvider`

### `lib/screens/map_planning_provider.dart`
- **Migration**: M1
- **Status**: Done — `routePlanningProvider`

### `lib/routing/app_routes.dart`
- **Migration**: M2
- **Status**: Done — typed routes (`MapRoute`, `LaunchDetailRoute`, token/web routes)

### `lib/routing/app_router_provider.dart`
- **Migration**: M2
- **Status**: Done — `goRouterProvider` with redirects

### `lib/screens/map_session_provider.dart`
- **Migration**: M1
- **Status**: Done — `mapInteractiveProvider`

### `lib/routing/route_result.dart`
- **Migration**: M4, M5
- **Status**: M4 done — sealed `@freezed` union (`RouteSuccess` / `RouteFailure`)

### `lib/debug/map_debug_log.dart`
- **Migration**: Keep in app (debug-only)
- **Status**: No migration needed

## Migration Order

Recommended migration order to minimize risk:

1. **M1** — Add Riverpod (non-breaking, additive)
2. **M4** — Convert models to freezed (can coexist with old code)
3. **M3** — Swap http → dio (isolated to network layer)
4. **M2** — Swap Navigator → go_router (requires touching all screens)
5. **M5** — Extract feature packages (largest refactor)
6. **M6** — Remove analysis baseline suppressions (final cleanup)

## Rules

- Never migrate more than one module at a time
- Every migration must include tests
- Every migration must pass `make preflight`
- Migration PRs must be reviewed by a human
- Generated files must be committed with the migration
- Update this document as migrations are completed
