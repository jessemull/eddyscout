import 'package:eddyscout_core/eddyscout_core.dart';

/// Whether [updatedWaypoints] differ in launch order or count from [existing].
bool savedRouteWaypointsChanged(
  SavedRoute existing,
  List<RouteWaypoint> updatedWaypoints,
) {
  final previous = List<RouteWaypoint>.of(existing.waypoints)
    ..sort((a, b) => a.order.compareTo(b.order));
  final next = List<RouteWaypoint>.of(updatedWaypoints)
    ..sort((a, b) => a.order.compareTo(b.order));
  if (previous.length != next.length) {
    return true;
  }
  for (var i = 0; i < previous.length; i++) {
    if (previous[i].launchId != next[i].launchId) {
      return true;
    }
  }
  return false;
}
