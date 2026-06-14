import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_hydro_routing/src/domain/route_result.dart';

/// Builds a [PlannedRoute] from hydro planner output and launch picks.
PlannedRoute plannedRouteFromRouteSuccess(
  RouteSuccess success, {
  LaunchPoint? putIn,
  LaunchPoint? takeOut,
}) {
  final points = success.polylineLonLat
      .map(
        (pair) => GpxPoint(
          latitude: pair[1],
          longitude: pair[0],
        ),
      )
      .toList(growable: false);
  final name = putIn != null && takeOut != null
      ? '${putIn.name} → ${takeOut.name}'
      : null;
  return PlannedRoute(
    points: points,
    putIn: putIn,
    takeOut: takeOut,
    lengthMeters: success.lengthMeters,
    name: name,
  );
}
