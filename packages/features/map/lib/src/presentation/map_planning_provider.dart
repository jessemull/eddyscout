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

/// Waypoint selection and route geometry for map route planning mode.
class RoutePlanningState {
  const RoutePlanningState({
    this.planningMode = false,
    this.waypoints = const [],
    this.routeLengthKm,
    this.activeGeometry,
    this.loadedSavedRouteId,
  });

  final bool planningMode;
  final List<LaunchPoint> waypoints;
  final double? routeLengthKm;
  final RouteGeometrySnapshot? activeGeometry;
  final String? loadedSavedRouteId;

  /// First waypoint (put-in).
  LaunchPoint? get putIn => waypoints.isNotEmpty ? waypoints.first : null;

  /// Last waypoint (take-out for two-stop routes).
  LaunchPoint? get takeOut => waypoints.length >= 2 ? waypoints.last : null;

  /// Whether hydro routing can run (at least two distinct stops).
  bool get hasRunnableRoute => waypoints.length >= 2;
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

  void setActiveGeometry({
    required RouteGeometrySnapshot? geometry,
    required double? routeLengthKm,
  }) {
    state = RoutePlanningState(
      planningMode: state.planningMode,
      waypoints: state.waypoints,
      routeLengthKm: routeLengthKm,
      activeGeometry: geometry,
      loadedSavedRouteId: state.loadedSavedRouteId,
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
        waypoints: waypoints,
        loadedSavedRouteId: state.loadedSavedRouteId,
      );
      return RoutePlanningTapResult.putInSelected;
    }
    waypoints.add(launch);
    state = RoutePlanningState(
      planningMode: true,
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
      waypoints: waypoints,
      routeLengthKm: state.routeLengthKm,
      activeGeometry: state.activeGeometry,
      loadedSavedRouteId: state.loadedSavedRouteId,
    );
  }

  void loadFromSavedRoute(
    SavedRoute route,
    List<LaunchPoint> resolvedWaypoints,
  ) {
    state = RoutePlanningState(
      planningMode: true,
      waypoints: resolvedWaypoints,
      loadedSavedRouteId: route.id,
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
    final now = DateTime.now();
    final metadata =
        computeSavedRouteMetadata(
          launches: state.waypoints,
          distanceMeters: state.activeGeometry!.lengthMeters,
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
        for (var i = 0; i < state.waypoints.length; i++)
          RouteWaypoint(launchId: state.waypoints[i].id, order: i),
      ],
      metadata: metadata,
      geometrySnapshot: state.activeGeometry,
      createdAt: existingCreatedAt ?? now,
      updatedAt: now,
    );
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
