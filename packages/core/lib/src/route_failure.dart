/// Machine-readable failures for river routing.
///
/// UI must localize these via `AppLocalizations`.
enum RouteFailureCode {
  /// Put-in and take-out are the same launch.
  sameLaunch,

  /// Put-in and take-out are on different river systems with no connected path.
  differentSystem,

  /// The graph has no vertices (e.g., asset missing/empty).
  noRiverGeometryLoaded,

  /// Put-in is too far from the modeled river line.
  putInTooFar,

  /// Take-out is too far from the modeled river line.
  takeOutTooFar,

  /// No connected path exists between snapped vertices.
  noConnectedPath,

  /// Put-in and take-out snap to different disconnected hydro segments.
  disconnectedReach,
}

/// Route planner failure surfaced to map UI for localization.
final class RoutePlanningFailure {
  /// Creates a [RoutePlanningFailure].
  const RoutePlanningFailure({
    required this.code,
    this.riverSystemName,
    this.putInReachId,
    this.takeOutReachId,
  });

  /// Failure category for localization.
  final RouteFailureCode code;

  /// River system name (for messaging like: no bundled line).
  final String? riverSystemName;

  /// Reach id nearest the put-in snap, when known.
  final String? putInReachId;

  /// Reach id nearest the take-out snap, when known.
  final String? takeOutReachId;
}
