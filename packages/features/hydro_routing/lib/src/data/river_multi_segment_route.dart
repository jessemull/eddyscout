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

/// Plans all consecutive coordinate pairs; returns failures on first error.
Result<List<RouteSuccess>, RouteFailure> planMultiSegmentCoordinates(
  RiverRoutePlanner planner,
  List<({double lat, double lon})> endpoints,
) {
  if (endpoints.length < 2) {
    return const Result.failure(
      RouteFailure(code: RouteFailureCode.sameLaunch),
    );
  }
  final successes = <RouteSuccess>[];
  for (var i = 0; i < endpoints.length - 1; i++) {
    final from = endpoints[i];
    final to = endpoints[i + 1];
    final result = planner.planBetween(from.lat, from.lon, to.lat, to.lon);
    if (result case final RouteFailure failure) {
      return Result.failure(failure);
    }
    successes.add(result as RouteSuccess);
  }
  return Result.success(successes);
}

/// Plans all consecutive [stops]; returns failures on first error.
Result<List<RouteSuccess>, RouteFailure> planMultiSegmentStops(
  RiverRoutePlanner planner,
  List<RoutePlanningStop> stops,
) {
  if (stops.length < 2) {
    return const Result.failure(
      RouteFailure(code: RouteFailureCode.sameLaunch),
    );
  }
  final successes = <RouteSuccess>[];
  for (var i = 0; i < stops.length - 1; i++) {
    final from = stops[i];
    final to = stops[i + 1];
    if (from.sameStopAs(to)) {
      return const Result.failure(
        RouteFailure(code: RouteFailureCode.sameLaunch),
      );
    }
    final result = planner.planBetween(
      from.routingLatitude,
      from.routingLongitude,
      to.routingLatitude,
      to.routingLongitude,
      putIn: from.catalogLaunch,
      takeOut: to.catalogLaunch,
    );
    if (result case final RouteFailure failure) {
      return Result.failure(failure);
    }
    successes.add(result as RouteSuccess);
  }
  return Result.success(successes);
}

/// Plans all consecutive waypoint pairs; returns failures on first error.
Result<List<RouteSuccess>, RouteFailure> planMultiSegmentRoute(
  RiverRoutePlanner planner,
  List<LaunchPoint> waypoints,
) {
  return planMultiSegmentCoordinates(
    planner,
    [
      for (final waypoint in waypoints)
        (lat: waypoint.routingLatitude, lon: waypoint.routingLongitude),
    ],
  );
}
