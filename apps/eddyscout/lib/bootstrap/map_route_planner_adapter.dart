import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_hydro_routing/eddyscout_hydro_routing.dart';
import 'package:eddyscout_map/eddyscout_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Hydro-backed [MapRoutePlanner] wired in the app composition layer.
final class HydroMapRoutePlanner implements MapRoutePlanner {
  const HydroMapRoutePlanner(this._ref);

  final Ref _ref;

  @override
  Future<Result<RouteGeometrySnapshot?, RoutePlanningFailure>> planMultiSegment(
    List<LaunchPoint> waypoints,
  ) async {
    final planner = await _ref.read(riverRoutePlannerProvider.future);
    final planResult = planMultiSegmentRoute(planner, waypoints);
    return switch (planResult) {
      Success(:final value) => Result.success(mergeRouteSegments(value)),
      Failure(:final error) => Result.failure(
        routePlanningFailureFrom(error),
      ),
    };
  }
}
