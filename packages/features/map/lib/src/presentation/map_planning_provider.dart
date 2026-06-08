import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_hydro_routing/eddyscout_hydro_routing.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'map_planning_provider.g.dart';

/// Outcome of tapping a launch pin while route planning is active.
enum RoutePlanningTapResult { putInSelected, takeOutSelected, sameAsPutIn }

/// UI phase for the route-planning overlay.
enum RoutePlanningPhase {
  pickPutIn,
  pickTakeOut,
  computingRoute,
  routeReady,
  routeError,
}

/// Put-in / take-out selection and route length for map route planning mode.
class RoutePlanningState {
  const RoutePlanningState({
    this.planningMode = false,
    this.phase = RoutePlanningPhase.pickPutIn,
    this.putIn,
    this.takeOut,
    this.routeLengthKm,
    this.polylineLonLat,
    this.routeOrigin,
    this.lastFailureCode,
    this.lastFailurePutInReachId,
    this.lastFailureTakeOutReachId,
  });

  final bool planningMode;
  final RoutePlanningPhase phase;
  final LaunchPoint? putIn;
  final LaunchPoint? takeOut;
  final double? routeLengthKm;

  /// Mapbox order: each pair is `[longitude, latitude]`.
  final List<List<double>>? polylineLonLat;
  final RouteOrigin? routeOrigin;
  final RouteFailureCode? lastFailureCode;
  final String? lastFailurePutInReachId;
  final String? lastFailureTakeOutReachId;
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
      putIn: state.putIn,
      takeOut: state.takeOut,
    );
  }

  /// Leaves put-in / take-out selected after planner data is unavailable.
  void revertFromComputingRoute() {
    state = RoutePlanningState(
      planningMode: state.planningMode,
      phase: RoutePlanningPhase.pickTakeOut,
      putIn: state.putIn,
      takeOut: state.takeOut,
    );
  }

  void setPlannedRoute({
    List<List<double>>? polylineLonLat,
    double? routeLengthKm,
    RouteOrigin? routeOrigin,
    LaunchPoint? putIn,
    LaunchPoint? takeOut,
    RoutePlanningPhase? phase,
  }) {
    final ready =
        polylineLonLat != null &&
        polylineLonLat.length >= 2 &&
        routeLengthKm != null;
    state = RoutePlanningState(
      planningMode: state.planningMode,
      phase:
          phase ??
          (ready
              ? RoutePlanningPhase.routeReady
              : RoutePlanningPhase.pickTakeOut),
      putIn: putIn ?? state.putIn,
      takeOut: takeOut ?? state.takeOut,
      routeLengthKm: routeLengthKm,
      polylineLonLat: polylineLonLat,
      routeOrigin: routeOrigin,
    );
  }

  void setRouteFailure({
    required LaunchPoint putIn,
    required LaunchPoint takeOut,
    required RouteFailure failure,
  }) {
    state = RoutePlanningState(
      planningMode: state.planningMode,
      phase: RoutePlanningPhase.routeError,
      putIn: putIn,
      takeOut: takeOut,
      lastFailureCode: failure.code,
      lastFailurePutInReachId: failure.putInReachId,
      lastFailureTakeOutReachId: failure.takeOutReachId,
    );
  }

  void applyImportedRoute(PlannedRoute route) {
    state = RoutePlanningState(
      planningMode: true,
      phase: RoutePlanningPhase.routeReady,
      putIn: route.putIn,
      takeOut: route.takeOut,
      routeLengthKm: route.lengthMeters != null
          ? route.lengthMeters! / 1000.0
          : null,
      polylineLonLat: route.toPolylineLonLat(),
      routeOrigin: RouteOrigin.imported,
    );
  }

  RoutePlanningTapResult? handleLaunchTap(LaunchPoint launch) {
    if (!state.planningMode) {
      return null;
    }
    if (state.putIn == null) {
      state = RoutePlanningState(
        planningMode: true,
        phase: RoutePlanningPhase.pickTakeOut,
        putIn: launch,
      );
      return RoutePlanningTapResult.putInSelected;
    }
    if (state.putIn!.id == launch.id) {
      return RoutePlanningTapResult.sameAsPutIn;
    }
    state = RoutePlanningState(
      planningMode: true,
      phase: RoutePlanningPhase.pickTakeOut,
      putIn: state.putIn,
      takeOut: launch,
    );
    return RoutePlanningTapResult.takeOutSelected;
  }
}
