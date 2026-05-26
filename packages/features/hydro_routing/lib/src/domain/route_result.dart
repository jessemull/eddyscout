import 'package:freezed_annotation/freezed_annotation.dart';

part 'route_result.freezed.dart';

/// Machine-readable failures for river routing.
///
/// UI must localize these via `AppLocalizations`.
enum RouteFailureCode {
  /// Put-in and take-out are the same launch.
  sameLaunch,

  /// Put-in and take-out are on different river systems.
  differentSystem,

  /// No bundled hydro line exists for the requested river system.
  noBundledLine,

  /// The graph has no vertices (e.g., asset missing/empty).
  noRiverGeometryLoaded,

  /// Put-in is too far from the modeled river line.
  putInTooFar,

  /// Take-out is too far from the modeled river line.
  takeOutTooFar,

  /// No connected path exists between snapped vertices.
  noConnectedPath,
}

/// Outcome of routing between two launches along bundled hydro lines.
@freezed
sealed class RouteResult with _$RouteResult {
  const RouteResult._();

  const factory RouteResult.success({
    /// Outer list is vertices along the river path.
    ///
    /// Mapbox order: each pair is `[longitude, latitude]`.
    required List<List<double>> polylineLonLat,
    required double lengthMeters,
  }) = RouteSuccess;

  const factory RouteResult.failure({
    required RouteFailureCode code,

    /// River system name (for messaging like: no bundled line).
    String? riverSystemName,
  }) = RouteFailure;

  /// True when this result is [RouteSuccess].
  bool get isSuccess => this is RouteSuccess;
}
