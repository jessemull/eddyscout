import 'package:eddyscout_core/src/geodesy.dart';
import 'package:eddyscout_core/src/launch_coordinates.dart';
import 'package:eddyscout_core/src/launch_models.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'route_planning_stop.freezed.dart';

/// Maximum haversine separation (meters) to treat two snap stops as duplicates.
const kRoutePlanningSnapStopDuplicateMeters = 5.0;

/// A stop along an in-progress map route — catalog launch or snapped map pin.
@freezed
sealed class RoutePlanningStop with _$RoutePlanningStop {
  const RoutePlanningStop._();

  /// Curated launch from the catalog.
  const factory RoutePlanningStop.catalog(LaunchPoint launch) =
      CatalogRoutePlanningStop;

  /// Ad-hoc stop snapped to bundled hydro geometry.
  const factory RoutePlanningStop.snap({
    required String id,
    required double latitude,
    required double longitude,
    required String label,
    String? reachId,
  }) = SnapRoutePlanningStop;
}

/// Display and routing accessors for [RoutePlanningStop].
extension RoutePlanningStopX on RoutePlanningStop {
  /// Stable id for stale-route guards and duplicate detection.
  String get stopId => switch (this) {
    CatalogRoutePlanningStop(:final launch) => launch.id,
    SnapRoutePlanningStop(:final id) => id,
  };

  /// Row label in planning chrome.
  String get displayLabel => switch (this) {
    CatalogRoutePlanningStop(:final launch) => launch.name,
    SnapRoutePlanningStop(:final label) => label,
  };

  /// WGS84 latitude used for hydro routing snap.
  double get routingLatitude => switch (this) {
    CatalogRoutePlanningStop(:final launch) => launch.routingLatitude,
    SnapRoutePlanningStop(:final latitude) => latitude,
  };

  /// WGS84 longitude used for hydro routing snap.
  double get routingLongitude => switch (this) {
    CatalogRoutePlanningStop(:final launch) => launch.routingLongitude,
    SnapRoutePlanningStop(:final longitude) => longitude,
  };

  /// Underlying catalog launch when this stop is curated.
  LaunchPoint? get catalogLaunch => switch (this) {
    CatalogRoutePlanningStop(:final launch) => launch,
    SnapRoutePlanningStop() => null,
  };

  /// Whether this stop is a user-dropped snap pin.
  bool get isSnap => this is SnapRoutePlanningStop;

  /// Whether [other] represents the same planning stop.
  bool sameStopAs(RoutePlanningStop other) {
    final self = this;
    if (self is CatalogRoutePlanningStop && other is CatalogRoutePlanningStop) {
      return self.launch.id == other.launch.id;
    }
    if (self is SnapRoutePlanningStop && other is SnapRoutePlanningStop) {
      return haversineMeters(
            self.latitude,
            self.longitude,
            other.latitude,
            other.longitude,
          ) <
          kRoutePlanningSnapStopDuplicateMeters;
    }
    return false;
  }
}

/// Collects catalog launches from an ordered stop list.
List<LaunchPoint> catalogLaunchesFromStops(Iterable<RoutePlanningStop> stops) =>
    [
      for (final stop in stops) ?stop.catalogLaunch,
    ];
