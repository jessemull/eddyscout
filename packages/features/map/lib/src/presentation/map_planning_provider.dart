import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_hydro_routing/eddyscout_hydro_routing.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'map_planning_provider.g.dart';

/// Outcome of tapping a launch pin while route planning is active.
enum RoutePlanningTapResult {
  /// First waypoint selected.
  putInSelected,

  /// Additional waypoint added; route should be recomputed.
  takeOutSelected,

  /// Same launch as the previous waypoint.
  sameAsPutIn,
}

/// UI phase for the route-planning overlay.
enum RoutePlanningPhase {
  pickPutIn,
  pickTakeOut,
  computingRoute,
  routeReady,
  routeError,
}

/// Waypoint selection and route geometry for map route planning mode.
class RoutePlanningState {
  const RoutePlanningState({
    this.planningMode = false,
    this.phase = RoutePlanningPhase.pickPutIn,
    this.waypoints = const [],
    this.routeLengthKm,
    this.activeGeometry,
    this.loadedSavedRouteId,
    this.routeOrigin,
    this.lastFailureCode,
    this.lastFailureRiverSystemName,
    this.lastFailurePutInReachId,
    this.lastFailureTakeOutReachId,
    this.routeReachId,
  });

  final bool planningMode;
  final RoutePlanningPhase phase;
  final List<LaunchPoint> waypoints;
  final double? routeLengthKm;
  final RouteGeometrySnapshot? activeGeometry;
  final String? loadedSavedRouteId;
  final RouteOrigin? routeOrigin;
  final RouteFailureCode? lastFailureCode;
  final String? lastFailureRiverSystemName;
  final String? lastFailurePutInReachId;
  final String? lastFailureTakeOutReachId;

  /// Bundled hydro reach id when the planner returns a single-segment route.
  final String? routeReachId;

  /// First waypoint (put-in).
  LaunchPoint? get putIn => waypoints.isNotEmpty ? waypoints.first : null;

  /// Last waypoint (take-out for two-stop routes).
  LaunchPoint? get takeOut => waypoints.length >= 2 ? waypoints.last : null;

  /// Whether hydro routing can run (at least two distinct stops).
  bool get hasRunnableRoute => waypoints.length >= 2;

  /// Mapbox order: each pair is `[longitude, latitude]`.
  List<List<double>>? get polylineLonLat => activeGeometry?.polylineLonLat;
}

/// Frozen planning selection used while save UI is open.
///
/// Captures waypoints and geometry before the bottom sheet so a save still
/// succeeds if map planning state is cleared during async work.
class RoutePlanningSaveCapture {
  const RoutePlanningSaveCapture({
    required this.planningMode,
    required this.waypoints,
    required this.geometry,
    required this.routeLengthKm,
    required this.routeOrigin,
    required this.loadedSavedRouteId,
  });

  /// Captures the current [RoutePlanningState] when a route is ready to save.
  factory RoutePlanningSaveCapture.fromState(RoutePlanningState state) {
    final geometry = state.activeGeometry;
    if (!state.hasRunnableRoute || geometry == null) {
      throw StateError('Route planning is not ready to save.');
    }
    return RoutePlanningSaveCapture(
      planningMode: state.planningMode,
      waypoints: List<LaunchPoint>.of(state.waypoints),
      geometry: geometry,
      routeLengthKm: state.routeLengthKm,
      routeOrigin: state.routeOrigin,
      loadedSavedRouteId: state.loadedSavedRouteId,
    );
  }

  final bool planningMode;
  final List<LaunchPoint> waypoints;
  final RouteGeometrySnapshot geometry;
  final double? routeLengthKm;
  final RouteOrigin? routeOrigin;
  final String? loadedSavedRouteId;
}

@Riverpod(keepAlive: true)
class RoutePlanning extends _$RoutePlanning {
  @override
  RoutePlanningState build() => const RoutePlanningState();

  void togglePlanningMode() {
    if (state.planningMode) {
      state = const RoutePlanningState();
      return;
    }
    state = const RoutePlanningState(planningMode: true);
  }

  void clearSelection() {
    state = RoutePlanningState(planningMode: state.planningMode);
  }

  void setComputingRoute() {
    state = RoutePlanningState(
      planningMode: state.planningMode,
      phase: RoutePlanningPhase.computingRoute,
      waypoints: state.waypoints,
      loadedSavedRouteId: state.loadedSavedRouteId,
    );
  }

  /// Leaves waypoints selected after planner data is unavailable.
  void revertFromComputingRoute() {
    state = RoutePlanningState(
      planningMode: state.planningMode,
      phase: _phaseForWaypoints(state.waypoints),
      waypoints: state.waypoints,
      loadedSavedRouteId: state.loadedSavedRouteId,
    );
  }

  void setActiveGeometry({
    required RouteGeometrySnapshot? geometry,
    required double? routeLengthKm,
    RouteOrigin? routeOrigin,
    String? routeReachId,
  }) {
    state = RoutePlanningState(
      planningMode: state.planningMode,
      phase: geometry != null
          ? RoutePlanningPhase.routeReady
          : _phaseForWaypoints(state.waypoints),
      waypoints: state.waypoints,
      routeLengthKm: routeLengthKm,
      activeGeometry: geometry,
      loadedSavedRouteId: state.loadedSavedRouteId,
      routeOrigin: geometry != null
          ? (routeOrigin ?? RouteOrigin.planner)
          : routeOrigin,
      routeReachId: routeReachId,
    );
  }

  void setRouteFailure({required RouteFailure failure}) {
    state = RoutePlanningState(
      planningMode: state.planningMode,
      phase: RoutePlanningPhase.routeError,
      waypoints: state.waypoints,
      loadedSavedRouteId: state.loadedSavedRouteId,
      lastFailureCode: failure.code,
      lastFailureRiverSystemName: failure.riverSystemName,
      lastFailurePutInReachId: failure.putInReachId,
      lastFailureTakeOutReachId: failure.takeOutReachId,
    );
  }

  void applyImportedRoute(PlannedRoute route) {
    final waypoints = <LaunchPoint>[
      if (route.putIn != null) route.putIn!,
      if (route.takeOut != null && route.takeOut!.id != route.putIn?.id)
        route.takeOut!,
    ];
    final polyline = route.toPolylineLonLat();
    state = RoutePlanningState(
      planningMode: true,
      phase: polyline.length >= 2
          ? RoutePlanningPhase.routeReady
          : RoutePlanningPhase.pickTakeOut,
      waypoints: waypoints,
      routeLengthKm: route.lengthMeters != null
          ? route.lengthMeters! / 1000.0
          : null,
      activeGeometry: polyline.length >= 2
          ? RouteGeometrySnapshot(
              polylineLonLat: polyline,
              lengthMeters: route.lengthMeters ?? 0,
              computedAt: DateTime.now(),
            )
          : null,
      routeOrigin: RouteOrigin.imported,
    );
  }

  RoutePlanningTapResult? handleLaunchTap(LaunchPoint launch) {
    if (!state.planningMode) {
      return null;
    }
    final waypoints = List<LaunchPoint>.of(state.waypoints);
    if (waypoints.isNotEmpty && waypoints.last.id == launch.id) {
      return RoutePlanningTapResult.sameAsPutIn;
    }
    if (waypoints.length == 1 && waypoints.first.id == launch.id) {
      return RoutePlanningTapResult.sameAsPutIn;
    }
    if (waypoints.isEmpty) {
      waypoints.add(launch);
      state = RoutePlanningState(
        planningMode: true,
        phase: RoutePlanningPhase.pickTakeOut,
        waypoints: waypoints,
        loadedSavedRouteId: state.loadedSavedRouteId,
      );
      return RoutePlanningTapResult.putInSelected;
    }
    waypoints.add(launch);
    state = RoutePlanningState(
      planningMode: true,
      phase: RoutePlanningPhase.pickTakeOut,
      waypoints: waypoints,
      loadedSavedRouteId: state.loadedSavedRouteId,
    );
    return RoutePlanningTapResult.takeOutSelected;
  }

  void removeWaypoint(int index) {
    if (index < 0 || index >= state.waypoints.length) {
      return;
    }
    final waypoints = List<LaunchPoint>.of(state.waypoints)..removeAt(index);
    state = RoutePlanningState(
      planningMode: state.planningMode,
      phase: _phaseForWaypoints(waypoints),
      waypoints: waypoints,
      loadedSavedRouteId: state.loadedSavedRouteId,
    );
  }

  void reorderWaypoints(int oldIndex, int newIndex) {
    final waypoints = List<LaunchPoint>.of(state.waypoints);
    if (oldIndex < 0 ||
        oldIndex >= waypoints.length ||
        newIndex < 0 ||
        newIndex >= waypoints.length) {
      return;
    }
    final item = waypoints.removeAt(oldIndex);
    waypoints.insert(newIndex, item);
    state = RoutePlanningState(
      planningMode: state.planningMode,
      phase: state.phase,
      waypoints: waypoints,
      routeLengthKm: state.routeLengthKm,
      activeGeometry: state.activeGeometry,
      loadedSavedRouteId: state.loadedSavedRouteId,
      routeOrigin: state.routeOrigin,
      routeReachId: state.routeReachId,
    );
  }

  void loadFromSavedRoute(
    SavedRoute route,
    List<LaunchPoint> resolvedWaypoints,
  ) {
    state = RoutePlanningState(
      planningMode: true,
      phase: route.geometrySnapshot != null
          ? RoutePlanningPhase.routeReady
          : RoutePlanningPhase.pickTakeOut,
      waypoints: resolvedWaypoints,
      loadedSavedRouteId: route.id,
      activeGeometry: route.geometrySnapshot,
      routeLengthKm: route.geometrySnapshot != null
          ? route.geometrySnapshot!.lengthMeters / 1000.0
          : null,
      routeOrigin: route.geometrySnapshot != null ? RouteOrigin.planner : null,
    );
  }

  /// Captures planning state before opening save UI.
  RoutePlanningSaveCapture captureForSave() =>
      RoutePlanningSaveCapture.fromState(state);

  /// Restores a prior capture when planning state was cleared unexpectedly.
  void restoreCapture(RoutePlanningSaveCapture capture) {
    state = RoutePlanningState(
      planningMode: capture.planningMode,
      phase: RoutePlanningPhase.routeReady,
      waypoints: List<LaunchPoint>.of(capture.waypoints),
      routeLengthKm: capture.routeLengthKm,
      activeGeometry: capture.geometry,
      loadedSavedRouteId: capture.loadedSavedRouteId,
      routeOrigin: capture.routeOrigin,
    );
  }

  /// Builds a draft [SavedRoute] from the current planning selection.
  SavedRoute? snapshotForSave({
    required String name,
    String? description,
    String? notes,
    RouteDifficulty? difficulty,
    RecommendedSkillLevel? recommendedSkillLevel,
    int? estimatedDurationMinutes,
    String? existingId,
    DateTime? existingCreatedAt,
  }) {
    if (!state.hasRunnableRoute || state.activeGeometry == null) {
      return null;
    }
    return snapshotForSaveFromCapture(
      RoutePlanningSaveCapture.fromState(state),
      name: name,
      description: description,
      notes: notes,
      difficulty: difficulty,
      recommendedSkillLevel: recommendedSkillLevel,
      estimatedDurationMinutes: estimatedDurationMinutes,
      existingId: existingId,
      existingCreatedAt: existingCreatedAt,
    );
  }

  /// Builds a draft [SavedRoute] from a frozen planning capture.
  SavedRoute? snapshotForSaveFromCapture(
    RoutePlanningSaveCapture capture, {
    required String name,
    String? description,
    String? notes,
    RouteDifficulty? difficulty,
    RecommendedSkillLevel? recommendedSkillLevel,
    int? estimatedDurationMinutes,
    String? existingId,
    DateTime? existingCreatedAt,
  }) {
    if (capture.waypoints.length < 2) {
      return null;
    }
    final now = DateTime.now();
    final metadata =
        computeSavedRouteMetadata(
          launches: capture.waypoints,
          distanceMeters: capture.geometry.lengthMeters,
        ).copyWith(
          difficulty: difficulty,
          recommendedSkillLevel: recommendedSkillLevel,
          estimatedDurationMinutes: estimatedDurationMinutes,
        );
    return SavedRoute(
      id: existingId ?? generateSavedRouteId(),
      name: name,
      description: description,
      notes: notes ?? '',
      waypoints: [
        for (var i = 0; i < capture.waypoints.length; i++)
          RouteWaypoint(launchId: capture.waypoints[i].id, order: i),
      ],
      metadata: metadata,
      geometrySnapshot: capture.geometry,
      createdAt: existingCreatedAt ?? now,
      updatedAt: now,
    );
  }

  RoutePlanningPhase _phaseForWaypoints(List<LaunchPoint> waypoints) {
    if (waypoints.isEmpty) {
      return RoutePlanningPhase.pickPutIn;
    }
    if (waypoints.length == 1) {
      return RoutePlanningPhase.pickTakeOut;
    }
    return RoutePlanningPhase.pickTakeOut;
  }
}

/// Merges segment polylines from multi-stop routing.
RouteGeometrySnapshot? mergeRouteSegments(List<RouteSuccess> segments) {
  if (segments.isEmpty) {
    return null;
  }
  final merged = <List<double>>[];
  var totalMeters = 0.0;
  for (final segment in segments) {
    totalMeters += segment.lengthMeters;
    if (merged.isEmpty) {
      merged.addAll(segment.polylineLonLat);
    } else {
      merged.addAll(segment.polylineLonLat.skip(1));
    }
  }
  return RouteGeometrySnapshot(
    polylineLonLat: merged,
    lengthMeters: totalMeters,
    computedAt: DateTime.now(),
  );
}

/// When all segments share one bundled reach, returns that reach id.
String? sharedReachIdFromSegments(List<RouteSuccess> segments) {
  final ids = <String>{
    for (final segment in segments)
      if (segment.reachId != null && segment.reachId!.isNotEmpty)
        segment.reachId!,
  };
  if (ids.length == 1) {
    return ids.first;
  }
  return null;
}

/// Plans all consecutive waypoint pairs; returns failures on first error.
Result<List<RouteSuccess>, RouteFailure> planMultiSegmentRoute(
  RiverRoutePlanner planner,
  List<LaunchPoint> waypoints,
) {
  if (waypoints.length < 2) {
    return const Result.failure(
      RouteFailure(code: RouteFailureCode.sameLaunch),
    );
  }
  final successes = <RouteSuccess>[];
  for (var i = 0; i < waypoints.length - 1; i++) {
    final result = planner.plan(waypoints[i], waypoints[i + 1]);
    if (result case final RouteFailure failure) {
      return Result.failure(failure);
    }
    successes.add(result as RouteSuccess);
  }
  return Result.success(successes);
}
