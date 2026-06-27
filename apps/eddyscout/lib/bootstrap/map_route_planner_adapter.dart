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

  @override
  Future<Result<void, RoutePlanningFailure>> validateLaunch(
    LaunchPoint launch,
  ) async {
    final planner = await _ref.read(riverRoutePlannerProvider.future);
    final failure = planner.validateLaunchSnap(launch);
    if (failure != null) {
      return Result.failure(routePlanningFailureFrom(failure));
    }
    return const Result.success(null);
  }

  @override
  Future<Result<void, RoutePlanningFailure>> validateSegment(
    LaunchPoint from,
    LaunchPoint to,
  ) async {
    final planner = await _ref.read(riverRoutePlannerProvider.future);
    final failure = planner.validateSegment(from, to);
    if (failure != null) {
      return Result.failure(routePlanningFailureFrom(failure));
    }
    return const Result.success(null);
  }
}
