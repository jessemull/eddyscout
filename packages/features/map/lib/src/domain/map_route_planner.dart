import 'package:eddyscout_core/eddyscout_core.dart';

/// Plans river-line routes between map waypoints without coupling map to hydro.
// ignore: one_member_abstracts
abstract class MapRoutePlanner {
  /// Plans consecutive waypoint pairs and returns merged geometry on success.
  Future<Result<RouteGeometrySnapshot?, RoutePlanningFailure>> planMultiSegment(
    List<LaunchPoint> waypoints,
  );
}
