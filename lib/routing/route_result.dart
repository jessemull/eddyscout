/// Outcome of routing between two launches along bundled hydro lines.
sealed class RouteResult {
  const RouteResult();

  bool get isSuccess => this is RouteSuccess;
}

/// [polylineLonLat] is Mapbox order: each pair is `[longitude, latitude]`.
final class RouteSuccess extends RouteResult {
  const RouteSuccess({
    required this.polylineLonLat,
    required this.lengthMeters,
  });

  /// Outer list is vertices along the river path.
  final List<List<double>> polylineLonLat;
  final double lengthMeters;
}

final class RouteFailure extends RouteResult {
  const RouteFailure(this.message);

  final String message;
}
