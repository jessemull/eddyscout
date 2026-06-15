import 'package:eddyscout_core/eddyscout_core.dart';
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

    /// Reach id when both endpoints share one bundled segment.
    String? reachId,
  }) = RouteSuccess;

  const factory RouteResult.failure({
    required RouteFailureCode code,

    /// River system name (for messaging like: no bundled line).
    String? riverSystemName,

    /// Reach id nearest the put-in snap, when known.
    String? putInReachId,

    /// Reach id nearest the take-out snap, when known.
    String? takeOutReachId,
  }) = RouteFailure;

  /// True when this result is [RouteSuccess].
  bool get isSuccess => this is RouteSuccess;
}

/// Maps hydro [RouteFailure] to core [RoutePlanningFailure] for map UI.
RoutePlanningFailure routePlanningFailureFrom(RouteFailure failure) =>
    RoutePlanningFailure(
      code: failure.code,
      riverSystemName: failure.riverSystemName,
      putInReachId: failure.putInReachId,
      takeOutReachId: failure.takeOutReachId,
    );
