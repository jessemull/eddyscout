import 'package:eddyscout_core/eddyscout_core.dart';

/// Plans river-line routes between map stops without coupling map to hydro.
///
/// Future extension points (not in v1): drag-to-edit midpoints, loop detection,
/// and route alternatives (shortest / sheltered / scenic).
abstract class MapRoutePlanner {
  /// Snaps a map coordinate to bundled hydro geometry.
  Future<Result<WaterwaySnapPoint, RoutePlanningFailure>> snapToWaterway(
    double latitude,
    double longitude,
  );

  /// Returns failure when [stop] is too far from bundled waterway geometry.
  Future<Result<void, RoutePlanningFailure>> validateStop(
    RoutePlanningStop stop,
  );

  /// Returns failure when [from] and [to] cannot be routed together.
  Future<Result<void, RoutePlanningFailure>> validateSegmentStops(
    RoutePlanningStop from,
    RoutePlanningStop to,
  );

  /// Plans consecutive stop pairs and returns merged geometry on success.
  Future<Result<RouteGeometrySnapshot?, RoutePlanningFailure>> planMultiSegment(
    List<RoutePlanningStop> stops,
  );
}
