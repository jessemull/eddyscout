import 'package:freezed_annotation/freezed_annotation.dart';

part 'route_result.freezed.dart';

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

  const factory RouteResult.failure(String message) = RouteFailure;

  /// True when this result is [RouteSuccess].
  bool get isSuccess => this is RouteSuccess;
}
