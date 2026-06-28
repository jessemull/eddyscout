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

/// Stop selection and route geometry for map-first paddle planning.
class RoutePlanningState {
  const RoutePlanningState({
    this.phase = MapPlanningPhase.browse,
    this.stops = const [],
    this.routeLengthKm,
    this.activeGeometry,
    this.loadedSavedRouteId,
    this.routeOrigin,
  });

  final MapPlanningPhase phase;
  final List<RoutePlanningStop> stops;
  final double? routeLengthKm;
  final RouteGeometrySnapshot? activeGeometry;
  final String? loadedSavedRouteId;
  final RouteOrigin? routeOrigin;

  /// First stop (put-in).
  RoutePlanningStop? get putIn => stops.isNotEmpty ? stops.first : null;

  /// Last stop (take-out for two-stop routes).
  RoutePlanningStop? get takeOut => stops.length >= 2 ? stops.last : null;

  /// Catalog launches from stops (metadata, go/no-go, suggested names).
  List<LaunchPoint> get catalogLaunches => catalogLaunchesFromStops(stops);

  /// Whether hydro routing can run (at least two distinct stops).
  bool get hasRunnableRoute => stops.length >= 2;

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
/// Captures stops and geometry before the bottom sheet so a save still
/// succeeds if map planning state is cleared during async work.
class RoutePlanningSaveCapture {
  const RoutePlanningSaveCapture({
    required this.planningMode,
    required this.stops,
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
      stops: List<RoutePlanningStop>.of(state.stops),
      geometry: geometry,
      routeLengthKm: state.routeLengthKm,
      routeOrigin: state.routeOrigin,
      loadedSavedRouteId: state.loadedSavedRouteId,
    );
  }

  final bool planningMode;
  final List<RoutePlanningStop> stops;
  final RouteGeometrySnapshot geometry;
  final double? routeLengthKm;
  final RouteOrigin? routeOrigin;
  final String? loadedSavedRouteId;

  /// Catalog launches from [stops] for suggested names and metadata.
  List<LaunchPoint> get catalogLaunches => catalogLaunchesFromStops(stops);
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
      stops: [RoutePlanningStop.catalog(launch)],
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
      stops: [
        RoutePlanningStop.catalog(putIn),
        RoutePlanningStop.catalog(takeOut),
      ],
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
      stops: state.stops.isNotEmpty ? [state.stops.first] : const [],
      loadedSavedRouteId: state.loadedSavedRouteId,
    );
  }

  void setActiveGeometry({
    required RouteGeometrySnapshot? geometry,
    required double? routeLengthKm,
    RouteOrigin? routeOrigin,
  }) {
    final phase = geometry != null && state.stops.length >= 2
        ? MapPlanningPhase.routeReady
        : state.phase == MapPlanningPhase.browse
        ? MapPlanningPhase.planning
        : state.phase;
    state = RoutePlanningState(
      phase: phase,
      stops: state.stops,
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
      stops: [
        for (final launch in waypoints) RoutePlanningStop.catalog(launch),
      ],
      routeLengthKm: routeLengthKm,
      activeGeometry: geometry,
      routeOrigin: routeOrigin,
    );
  }

  RoutePlanningTapResult? handleLaunchTap(LaunchPoint launch) {
    return addStop(RoutePlanningStop.catalog(launch));
  }

  RoutePlanningTapResult? handleSnapStop(
    WaterwaySnapPoint snap, {
    required String label,
  }) {
    return addStop(
      RoutePlanningStop.snap(
        id: generatePlanningSnapId(),
        latitude: snap.latitude,
        longitude: snap.longitude,
        label: label,
        reachId: snap.reachId,
      ),
    );
  }

  /// Adds [stop] to the active plan when planning mode is active.
  RoutePlanningTapResult? addStop(RoutePlanningStop stop) => _addStop(stop);

  RoutePlanningTapResult? _addStop(RoutePlanningStop stop) {
    if (!state.planningMode && state.stops.isEmpty) {
      return null;
    }
    final stops = List<RoutePlanningStop>.of(state.stops);
    if (stops.isNotEmpty && stops.last.sameStopAs(stop)) {
      return RoutePlanningTapResult.sameAsPutIn;
    }
    if (stops.length == 1 && stops.first.sameStopAs(stop)) {
      return RoutePlanningTapResult.sameAsPutIn;
    }
    if (stops.isEmpty) {
      stops.add(stop);
      state = RoutePlanningState(
        phase: MapPlanningPhase.planning,
        stops: stops,
        loadedSavedRouteId: state.loadedSavedRouteId,
      );
      return RoutePlanningTapResult.putInSelected;
    }
    stops.add(stop);
    state = RoutePlanningState(
      phase: MapPlanningPhase.planning,
      stops: stops,
      loadedSavedRouteId: state.loadedSavedRouteId,
    );
    return RoutePlanningTapResult.takeOutSelected;
  }

  void removeStop(int index) {
    if (index < 0 || index >= state.stops.length) {
      return;
    }
    final stops = List<RoutePlanningStop>.of(state.stops)..removeAt(index);
    _applyStopList(stops);
  }

  /// Removes the last stop after a failed route attempt.
  void removeLastStop() {
    if (state.stops.isEmpty) {
      return;
    }
    removeStop(state.stops.length - 1);
  }

  void _applyStopList(List<RoutePlanningStop> stops) {
    state = RoutePlanningState(
      phase: stops.length >= 2 && state.activeGeometry != null
          ? MapPlanningPhase.routeReady
          : MapPlanningPhase.planning,
      stops: stops,
      routeLengthKm: stops.length >= 2 ? state.routeLengthKm : null,
      activeGeometry: stops.length >= 2 ? state.activeGeometry : null,
      loadedSavedRouteId: state.loadedSavedRouteId,
      routeOrigin: state.routeOrigin,
    );
  }

  void reorderStops(int oldIndex, int newIndex) {
    final stops = List<RoutePlanningStop>.of(state.stops);
    if (oldIndex < 0 ||
        oldIndex >= stops.length ||
        newIndex < 0 ||
        newIndex >= stops.length) {
      return;
    }
    final item = stops.removeAt(oldIndex);
    stops.insert(newIndex, item);
    state = RoutePlanningState(
      phase: state.phase,
      stops: stops,
      routeLengthKm: state.routeLengthKm,
      activeGeometry: state.activeGeometry,
      loadedSavedRouteId: state.loadedSavedRouteId,
      routeOrigin: state.routeOrigin,
    );
  }

  /// Restores a prior stop order after a failed reorder reroute.
  void restoreStops(List<RoutePlanningStop> stops) {
    if (stops.length != state.stops.length) {
      return;
    }
    state = RoutePlanningState(
      phase: state.phase,
      stops: List<RoutePlanningStop>.of(stops),
      routeLengthKm: state.routeLengthKm,
      activeGeometry: state.activeGeometry,
      loadedSavedRouteId: state.loadedSavedRouteId,
      routeOrigin: state.routeOrigin,
    );
  }

  void loadFromSavedRoute(
    SavedRoute route,
    List<RoutePlanningStop> resolvedStops,
  ) {
    state = RoutePlanningState(
      phase: route.geometrySnapshot != null && resolvedStops.length >= 2
          ? MapPlanningPhase.routeReady
          : MapPlanningPhase.planning,
      stops: resolvedStops,
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
      stops: List<RoutePlanningStop>.of(capture.stops),
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
    if (capture.stops.length < 2) {
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
          launches: capture.catalogLaunches,
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
        for (var i = 0; i < capture.stops.length; i++)
          routeWaypointFromPlanningStop(capture.stops[i], i),
      ],
      metadata: metadata,
      geometrySnapshot: capture.geometry,
      createdAt: existingCreatedAt ?? now,
      updatedAt: now,
    );
  }
}
