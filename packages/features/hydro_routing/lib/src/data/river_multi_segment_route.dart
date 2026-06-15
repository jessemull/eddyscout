import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_hydro_routing/src/data/river_route_planner.dart';
import 'package:eddyscout_hydro_routing/src/domain/route_result.dart';

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
