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
    this.plannedRoute,
    this.lastFailureCode,
  });

  final bool planningMode;
  final RoutePlanningPhase phase;
  final LaunchPoint? putIn;
  final LaunchPoint? takeOut;
  final double? routeLengthKm;
  final PlannedRoute? plannedRoute;
  final RouteFailureCode? lastFailureCode;
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

  void setRouteResult({
    required LaunchPoint putIn,
    required LaunchPoint takeOut,
    required RouteResult result,
    PlannedRoute? plannedRoute,
  }) {
    switch (result) {
      case RouteSuccess(:final lengthMeters):
        state = RoutePlanningState(
          planningMode: state.planningMode,
          phase: RoutePlanningPhase.routeReady,
          putIn: putIn,
          takeOut: takeOut,
          routeLengthKm: lengthMeters / 1000.0,
          plannedRoute: plannedRoute,
        );
      case RouteFailure(:final code):
        state = RoutePlanningState(
          planningMode: state.planningMode,
          phase: RoutePlanningPhase.routeError,
          putIn: putIn,
          takeOut: takeOut,
          lastFailureCode: code,
        );
    }
  }

  void setRouteLengthKm(double? routeLengthKm) {
    state = RoutePlanningState(
      planningMode: state.planningMode,
      phase: state.phase,
      putIn: state.putIn,
      takeOut: state.takeOut,
      routeLengthKm: routeLengthKm,
      plannedRoute: state.plannedRoute,
      lastFailureCode: state.lastFailureCode,
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
