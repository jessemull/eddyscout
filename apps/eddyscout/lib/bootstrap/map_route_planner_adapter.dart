import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_hydro_routing/eddyscout_hydro_routing.dart';
import 'package:eddyscout_map/eddyscout_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Hydro-backed [MapRoutePlanner] wired in the app composition layer.
final class HydroMapRoutePlanner implements MapRoutePlanner {
  const HydroMapRoutePlanner(this._ref);

  final Ref _ref;

  @override
  Future<Result<WaterwaySnapPoint, RoutePlanningFailure>> snapToWaterway(
    double latitude,
    double longitude,
  ) async {
    final planner = await _ref.read(riverRoutePlannerProvider.future);
    final snap = planner.snapToWaterway(latitude, longitude);
    if (snap == null) {
      return const Result.failure(
        RoutePlanningFailure(code: RouteFailureCode.putInTooFar),
      );
    }
    return Result.success(snap);
  }

  @override
  Future<Result<RouteGeometrySnapshot?, RoutePlanningFailure>> planMultiSegment(
    List<RoutePlanningStop> stops,
  ) async {
    final planner = await _ref.read(riverRoutePlannerProvider.future);
    final planResult = planMultiSegmentStops(planner, stops);
    return switch (planResult) {
      Success(:final value) => Result.success(mergeRouteSegments(value)),
      Failure(:final error) => Result.failure(
        routePlanningFailureFrom(error),
      ),
    };
  }

  @override
  Future<Result<void, RoutePlanningFailure>> validateStop(
    RoutePlanningStop stop,
  ) async {
    final planner = await _ref.read(riverRoutePlannerProvider.future);
    final failure = planner.validateStop(stop);
    if (failure != null) {
      return Result.failure(routePlanningFailureFrom(failure));
    }
    return const Result.success(null);
  }

  @override
  Future<Result<void, RoutePlanningFailure>> validateSegmentStops(
    RoutePlanningStop from,
    RoutePlanningStop to,
  ) async {
    final planner = await _ref.read(riverRoutePlannerProvider.future);
    final failure = planner.validateSegmentStops(from, to);
    if (failure != null) {
      return Result.failure(routePlanningFailureFrom(failure));
    }
    return const Result.success(null);
  }
}
