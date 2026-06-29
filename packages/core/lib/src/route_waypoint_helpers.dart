import 'package:eddyscout_core/src/route_planning_stop.dart';
import 'package:eddyscout_core/src/saved_route_id.dart';
import 'package:eddyscout_core/src/saved_route_models.dart';

/// Maps a persisted [RouteWaypoint] to a runtime [RoutePlanningStop].
RoutePlanningStop? routePlanningStopFromWaypoint(
  RouteWaypoint waypoint,
  LaunchPointLookup lookup,
) => switch (waypoint) {
  CatalogRouteWaypoint(:final launchId) => switch (lookup(launchId)) {
    null => null,
    final launch => RoutePlanningStop.catalog(launch),
  },
  SnapRouteWaypoint(
    :final latitude,
    :final longitude,
    :final label,
  ) =>
    RoutePlanningStop.snap(
      id: generatePlanningSnapId(),
      latitude: latitude,
      longitude: longitude,
      label: label ?? _defaultSnapLabel(latitude, longitude),
    ),
};

/// Maps a runtime [RoutePlanningStop] to a persisted [RouteWaypoint].
RouteWaypoint routeWaypointFromPlanningStop(
  RoutePlanningStop stop,
  int order,
) => switch (stop) {
  CatalogRoutePlanningStop(:final launch) => RouteWaypoint.catalog(
    launchId: launch.id,
    order: order,
  ),
  SnapRoutePlanningStop(
    :final latitude,
    :final longitude,
    :final label,
  ) =>
    RouteWaypoint.snap(
      latitude: latitude,
      longitude: longitude,
      order: order,
      label: label,
    ),
};

String _defaultSnapLabel(double latitude, double longitude) {
  final lat = latitude.toStringAsFixed(4);
  final lon = longitude.toStringAsFixed(4);
  return '$lat, $lon';
}
