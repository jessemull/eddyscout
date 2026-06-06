import 'package:eddyscout_map/eddyscout_map.dart';
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
  });

  final bool planningMode;
  final LaunchPoint? putIn;
  final LaunchPoint? takeOut;
  final double? routeLengthKm;
}

@riverpod
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

  void setRouteLengthKm(double? routeLengthKm) {
    state = RoutePlanningState(
      planningMode: state.planningMode,
      putIn: state.putIn,
      takeOut: state.takeOut,
      routeLengthKm: routeLengthKm,
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
