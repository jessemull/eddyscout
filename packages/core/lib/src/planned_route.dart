import 'package:eddyscout_core/src/launch_models.dart';
import 'package:eddyscout_core/src/route_origin.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'planned_route.freezed.dart';

/// A single WGS84 point along a planned or imported route.
@freezed
abstract class GpxPoint with _$GpxPoint {
  /// Creates a [GpxPoint].
  const factory GpxPoint({
    required double latitude,
    required double longitude,
    double? elevationMeters,
    DateTime? timestamp,
  }) = _GpxPoint;
}

/// Route geometry and optional launch endpoints for export/import.
@freezed
abstract class PlannedRoute with _$PlannedRoute {
  /// Creates a [PlannedRoute].
  const factory PlannedRoute({
    required List<GpxPoint> points,
    LaunchPoint? putIn,
    LaunchPoint? takeOut,
    double? lengthMeters,
    String? name,
    @Default(RouteOrigin.planner) RouteOrigin origin,
  }) = _PlannedRoute;

  const PlannedRoute._();

  /// Mapbox order: each pair is `[longitude, latitude]`.
  List<List<double>> toPolylineLonLat() => points
      .map((p) => <double>[p.longitude, p.latitude])
      .toList(growable: false);
}
