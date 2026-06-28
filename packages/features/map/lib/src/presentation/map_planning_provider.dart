import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/map_trip_duration.dart';
import 'map_planning_phase.dart';
import 'paddle_speed_provider.dart';

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

/// Waypoint selection and route geometry for map-first paddle planning.
class RoutePlanningState {
  const RoutePlanningState({
    this.phase = MapPlanningPhase.browse,
    this.waypoints = const [],
    this.routeLengthKm,
    this.activeGeometry,
    this.loadedSavedRouteId,
    this.routeOrigin,
  });

  final MapPlanningPhase phase;
  final List<LaunchPoint> waypoints;
  final double? routeLengthKm;
  final RouteGeometrySnapshot? activeGeometry;
  final String? loadedSavedRouteId;
  final RouteOrigin? routeOrigin;

  /// First waypoint (put-in).
  LaunchPoint? get putIn => waypoints.isNotEmpty ? waypoints.first : null;

  /// Last waypoint (take-out for two-stop routes).
  LaunchPoint? get takeOut => waypoints.length >= 2 ? waypoints.last : null;

  /// Whether hydro routing can run (at least two distinct stops).
  bool get hasRunnableRoute => waypoints.length >= 2;

  /// Whether the user can finish planning edit (valid routed geometry).
  bool get canFinishPlanning => hasRunnableRoute && activeGeometry != null;

  /// Mapbox order: each pair is `[longitude, latitude]`.
  List<List<double>>? get polylineLonLat => activeGeometry?.polylineLonLat;

  /// Whether launch taps add waypoints (planning or route-ready session).
  bool get planningMode =>
      phase == MapPlanningPhase.planning ||
      phase == MapPlanningPhase.routeReady;
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
      resetToBrowse();
      return;
    }
    state = const RoutePlanningState(phase: MapPlanningPhase.planning);
  }

  void resetToBrowse() {
    state = const RoutePlanningState();
  }

  void selectPlace(LaunchPoint launch) {
    state = const RoutePlanningState(phase: MapPlanningPhase.placeSelected);
  }

  void startPlanPaddle(LaunchPoint launch) {
    state = RoutePlanningState(
      phase: MapPlanningPhase.planning,
      waypoints: [launch],
      loadedSavedRouteId: state.loadedSavedRouteId,
    );
  }

  /// Pre-fills put-in and take-out for trips-from-here discovery.
  void startPlanFromHereTo({
    required LaunchPoint putIn,
    required LaunchPoint takeOut,
  }) {
    state = RoutePlanningState(
      phase: MapPlanningPhase.planning,
      waypoints: [putIn, takeOut],
      loadedSavedRouteId: state.loadedSavedRouteId,
    );
  }

  void clearSelection() {
    if (state.phase == MapPlanningPhase.browse ||
        state.phase == MapPlanningPhase.placeSelected) {
      state = RoutePlanningState(phase: state.phase);
      return;
    }
    state = RoutePlanningState(
      phase: MapPlanningPhase.planning,
      waypoints: state.waypoints.isNotEmpty
          ? [state.waypoints.first]
          : const [],
      loadedSavedRouteId: state.loadedSavedRouteId,
    );
  }

  void setActiveGeometry({
    required RouteGeometrySnapshot? geometry,
    required double? routeLengthKm,
    RouteOrigin? routeOrigin,
  }) {
    final phase = geometry != null && state.waypoints.length >= 2
        ? MapPlanningPhase.routeReady
        : state.phase == MapPlanningPhase.browse
        ? MapPlanningPhase.planning
        : state.phase;
    state = RoutePlanningState(
      phase: phase,
      waypoints: state.waypoints,
      routeLengthKm: routeLengthKm,
      activeGeometry: geometry,
      loadedSavedRouteId: state.loadedSavedRouteId,
      routeOrigin: geometry != null
          ? (routeOrigin ?? RouteOrigin.planner)
          : routeOrigin,
    );
  }

  void applyImportedWaypoints({
    required List<LaunchPoint> waypoints,
    required RouteGeometrySnapshot? geometry,
    required double? routeLengthKm,
    required RouteOrigin routeOrigin,
  }) {
    state = RoutePlanningState(
      phase: geometry != null && waypoints.length >= 2
          ? MapPlanningPhase.routeReady
          : MapPlanningPhase.planning,
      waypoints: waypoints,
      routeLengthKm: routeLengthKm,
      activeGeometry: geometry,
      routeOrigin: routeOrigin,
    );
  }

  RoutePlanningTapResult? handleLaunchTap(LaunchPoint launch) {
    if (!state.planningMode && state.waypoints.isEmpty) {
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
        phase: MapPlanningPhase.planning,
        waypoints: waypoints,
        loadedSavedRouteId: state.loadedSavedRouteId,
      );
      return RoutePlanningTapResult.putInSelected;
    }
    waypoints.add(launch);
    state = RoutePlanningState(
      phase: MapPlanningPhase.planning,
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
    _applyWaypointList(waypoints);
  }

  /// Removes the last waypoint after a failed route attempt.
  void removeLastWaypoint() {
    if (state.waypoints.isEmpty) {
      return;
    }
    removeWaypoint(state.waypoints.length - 1);
  }

  void _applyWaypointList(List<LaunchPoint> waypoints) {
    state = RoutePlanningState(
      phase: waypoints.length >= 2 && state.activeGeometry != null
          ? MapPlanningPhase.routeReady
          : MapPlanningPhase.planning,
      waypoints: waypoints,
      routeLengthKm: waypoints.length >= 2 ? state.routeLengthKm : null,
      activeGeometry: waypoints.length >= 2 ? state.activeGeometry : null,
      loadedSavedRouteId: state.loadedSavedRouteId,
      routeOrigin: state.routeOrigin,
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
      phase: state.phase,
      waypoints: waypoints,
      routeLengthKm: state.routeLengthKm,
      activeGeometry: state.activeGeometry,
      loadedSavedRouteId: state.loadedSavedRouteId,
      routeOrigin: state.routeOrigin,
    );
  }

  /// Restores a prior waypoint order after a failed reorder reroute.
  void restoreWaypoints(List<LaunchPoint> waypoints) {
    if (waypoints.length != state.waypoints.length) {
      return;
    }
    state = RoutePlanningState(
      phase: state.phase,
      waypoints: List<LaunchPoint>.of(waypoints),
      routeLengthKm: state.routeLengthKm,
      activeGeometry: state.activeGeometry,
      loadedSavedRouteId: state.loadedSavedRouteId,
      routeOrigin: state.routeOrigin,
    );
  }

  void loadFromSavedRoute(
    SavedRoute route,
    List<LaunchPoint> resolvedWaypoints,
  ) {
    state = RoutePlanningState(
      phase: route.geometrySnapshot != null && resolvedWaypoints.length >= 2
          ? MapPlanningPhase.routeReady
          : MapPlanningPhase.planning,
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
      phase: capture.planningMode
          ? MapPlanningPhase.routeReady
          : MapPlanningPhase.browse,
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
    final distanceKm = capture.geometry.lengthMeters / 1000.0;
    final speedKmh = ref.read(effectivePaddleSpeedKmhProvider);
    final durationMinutes =
        estimatedDurationMinutes ??
        estimateTripDurationMinutes(
          distanceKm: distanceKm,
          speedKmh: speedKmh,
        );
    final metadata =
        computeSavedRouteMetadata(
          launches: capture.waypoints,
          distanceMeters: capture.geometry.lengthMeters,
        ).copyWith(
          difficulty: difficulty,
          recommendedSkillLevel: recommendedSkillLevel,
          estimatedDurationMinutes: durationMinutes,
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
}
