import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_hydro_routing/eddyscout_hydro_routing.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'map_planning_provider.g.dart';

/// Outcome of tapping a launch pin while route planning is active.
enum RoutePlanningTapResult { putInSelected, takeOutSelected, sameAsPutIn }

/// Put-in / take-out selection and route length for map route planning mode.
class RoutePlanningState {
  const RoutePlanningState({
    this.planningMode = false,
    this.putIn,
    this.takeOut,
    this.routeLengthKm,
    this.polylineLonLat,
    this.routeOrigin,
  });

  final bool planningMode;
  final LaunchPoint? putIn;
  final LaunchPoint? takeOut;
  final double? routeLengthKm;

  /// Mapbox order: each pair is `[longitude, latitude]`.
  final List<List<double>>? polylineLonLat;
  final RouteOrigin? routeOrigin;
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

  void setPlannedRoute({
    List<List<double>>? polylineLonLat,
    double? routeLengthKm,
    RouteOrigin? routeOrigin,
    LaunchPoint? putIn,
    LaunchPoint? takeOut,
  }) {
    state = RoutePlanningState(
      planningMode: state.planningMode,
      putIn: putIn ?? state.putIn,
      takeOut: takeOut ?? state.takeOut,
      routeLengthKm: routeLengthKm,
      polylineLonLat: polylineLonLat,
      routeOrigin: routeOrigin,
    );
  }

  void applyImportedRoute(PlannedRoute route) {
    state = RoutePlanningState(
      planningMode: true,
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
      state = RoutePlanningState(planningMode: true, putIn: launch);
      return RoutePlanningTapResult.putInSelected;
    }
    if (state.putIn!.id == launch.id) {
      return RoutePlanningTapResult.sameAsPutIn;
    }
    state = RoutePlanningState(
      planningMode: true,
      putIn: state.putIn,
      takeOut: launch,
    );
    return RoutePlanningTapResult.takeOutSelected;
  }
}
