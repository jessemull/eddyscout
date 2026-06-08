import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_hydro_routing/src/domain/route_result.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'planned_route.freezed.dart';

/// How a planned route entered the map planner.
enum RouteOrigin {
  /// Computed along bundled hydro geometry between launches.
  planner,

  /// Loaded from an external GPX file.
  imported,
}

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

  /// Builds a route from hydro planner output and launch picks.
  factory PlannedRoute.fromRouteSuccess(
    RouteSuccess success, {
    LaunchPoint? putIn,
    LaunchPoint? takeOut,
  }) {
    final points = success.polylineLonLat
        .map(
          (pair) => GpxPoint(
            latitude: pair[1],
            longitude: pair[0],
          ),
        )
        .toList(growable: false);
    final name = putIn != null && takeOut != null
        ? '${putIn.name} → ${takeOut.name}'
        : null;
    return PlannedRoute(
      points: points,
      putIn: putIn,
      takeOut: takeOut,
      lengthMeters: success.lengthMeters,
      name: name,
    );
  }

  /// Mapbox order: each pair is `[longitude, latitude]`.
  List<List<double>> toPolylineLonLat() => points
      .map((p) => <double>[p.longitude, p.latitude])
      .toList(growable: false);
}
