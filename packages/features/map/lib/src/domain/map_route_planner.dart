import 'package:eddyscout_core/eddyscout_core.dart';

/// Plans river-line routes between map waypoints without coupling map to hydro.
abstract class MapRoutePlanner {
  /// Plans consecutive waypoint pairs and returns merged geometry on success.
  Future<Result<RouteGeometrySnapshot?, RoutePlanningFailure>> planMultiSegment(
    List<LaunchPoint> waypoints,
  );

  /// Returns failure when [launch] is too far from bundled waterway geometry.
  Future<Result<void, RoutePlanningFailure>> validateLaunch(
    LaunchPoint launch,
  );

  /// Returns failure when [from] and [to] cannot be routed together.
  Future<Result<void, RoutePlanningFailure>> validateSegment(
    LaunchPoint from,
    LaunchPoint to,
  );
}
