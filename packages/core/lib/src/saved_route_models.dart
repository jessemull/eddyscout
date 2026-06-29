import 'package:eddyscout_core/src/launch_models.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'saved_route_models.freezed.dart';
part 'saved_route_models.g.dart';

/// Editorial difficulty for a saved route.
enum RouteDifficulty {
  /// Calm water, short distance, sheltered.
  easy,

  /// Typical regional day trip.
  moderate,

  /// Long, exposed, or pushy water.
  hard,

  /// Expert-only conditions or commitment.
  expert,
}

/// Curated category tags for browsing saved routes.
enum RouteCategory {
  /// Scenic / photography paddle.
  scenic,

  /// Skills or fitness training.
  training,

  /// Regular shuttle-style commute.
  commute,

  /// Multi-day or overnight trip.
  overnight,
}

/// Recommended paddler skill for this route (matches go/no-go profile tiers).
enum RecommendedSkillLevel {
  /// Conservative wind and flow bands.
  beginner,

  /// Default planning bands.
  intermediate,

  /// More lenient bands for experienced paddlers.
  advanced,
}

/// Ordered stop on a saved route — catalog launch or snapped map pin.
@Freezed(unionKey: 'type', unionValueCase: FreezedUnionCase.snake)
sealed class RouteWaypoint with _$RouteWaypoint {
  const RouteWaypoint._();

  /// Curated launch id from the catalog.
  const factory RouteWaypoint.catalog({
    required String launchId,
    required int order,
  }) = CatalogRouteWaypoint;

  /// Ad-hoc stop snapped to bundled hydro geometry.
  const factory RouteWaypoint.snap({
    required double latitude,
    required double longitude,
    required int order,
    String? label,
  }) = SnapRouteWaypoint;

  /// Parses from JSON storage (legacy rows omit `type` when `launchId` is set).
  factory RouteWaypoint.fromJson(Map<String, dynamic> json) =>
      _$RouteWaypointFromJson(_migrateRouteWaypointJson(json));
}

Map<String, dynamic> _migrateRouteWaypointJson(Map<String, dynamic> json) {
  if (!json.containsKey('type') && json.containsKey('launchId')) {
    return {...json, 'type': 'catalog'};
  }
  return json;
}

/// Persistence accessors for [RouteWaypoint].
extension RouteWaypointX on RouteWaypoint {
  /// Zero-based order along the route.
  int get order => switch (this) {
    CatalogRouteWaypoint(:final order) => order,
    SnapRouteWaypoint(:final order) => order,
  };

  /// Catalog launch id when this waypoint references the launch catalog.
  String? get launchId => switch (this) {
    CatalogRouteWaypoint(:final launchId) => launchId,
    SnapRouteWaypoint() => null,
  };

  /// Whether this waypoint is a snapped map pin.
  bool get isSnap => this is SnapRouteWaypoint;
}

/// Optional cached geometry from the last successful hydro plan.
///
/// Polyline uses Mapbox order: each pair is `[longitude, latitude]`.
@freezed
abstract class RouteGeometrySnapshot with _$RouteGeometrySnapshot {
  /// Creates a geometry snapshot for list display without re-planning.
  const factory RouteGeometrySnapshot({
    /// Vertices along the river path in Mapbox `[lon, lat]` order.
    required List<List<double>> polylineLonLat,

    /// Total path length in meters.
    required double lengthMeters,

    /// When this geometry was computed.
    required DateTime computedAt,
  }) = _RouteGeometrySnapshot;

  /// Parses from JSON storage.
  factory RouteGeometrySnapshot.fromJson(Map<String, dynamic> json) =>
      _$RouteGeometrySnapshotFromJson(json);
}

/// Parses optional enum values stored as lowercase names.
RouteDifficulty? _routeDifficultyFromJson(Object? json) {
  if (json case final String name?) {
    return RouteDifficulty.values.byName(name);
  }
  return null;
}

String? _routeDifficultyToJson(RouteDifficulty? value) => value?.name;

WindExposure? _windExposureFromJson(Object? json) {
  if (json case final String name?) {
    return WindExposure.values.byName(name);
  }
  return null;
}

String? _windExposureToJson(WindExposure? value) => value?.name;

TideRelevance? _tideRelevanceFromJson(Object? json) {
  if (json case final String name?) {
    return TideRelevance.values.byName(name);
  }
  return null;
}

String? _tideRelevanceToJson(TideRelevance? value) => value?.name;

RecommendedSkillLevel? _recommendedSkillLevelFromJson(Object? json) {
  if (json case final String name?) {
    return RecommendedSkillLevel.values.byName(name);
  }
  return null;
}

String? _recommendedSkillLevelToJson(RecommendedSkillLevel? value) =>
    value?.name;

/// User-editable and auto-derived metadata for a saved route.
@freezed
abstract class SavedRouteMetadata with _$SavedRouteMetadata {
  /// Creates metadata for a saved route.
  const factory SavedRouteMetadata({
    @JsonKey(fromJson: _routeDifficultyFromJson, toJson: _routeDifficultyToJson)
    RouteDifficulty? difficulty,
    double? distanceMeters,
    int? estimatedDurationMinutes,
    @JsonKey(fromJson: _windExposureFromJson, toJson: _windExposureToJson)
    WindExposure? exposure,
    @JsonKey(fromJson: _tideRelevanceFromJson, toJson: _tideRelevanceToJson)
    TideRelevance? tideDependency,
    @JsonKey(
      fromJson: _recommendedSkillLevelFromJson,
      toJson: _recommendedSkillLevelToJson,
    )
    RecommendedSkillLevel? recommendedSkillLevel,
    @Default(<String>[]) List<String> categories,
  }) = _SavedRouteMetadata;

  /// Parses from JSON storage.
  factory SavedRouteMetadata.fromJson(Map<String, dynamic> json) =>
      _$SavedRouteMetadataFromJson(json);
}

/// A named, locally persisted planned route.
@freezed
abstract class SavedRoute with _$SavedRoute {
  /// Creates a saved route entity.
  const factory SavedRoute({
    required String id,
    required String name,
    required List<RouteWaypoint> waypoints,
    required SavedRouteMetadata metadata,
    required DateTime createdAt,
    required DateTime updatedAt,
    String? description,
    @Default('') String notes,
    @Default(false) bool isFavorite,
    @Default(true) bool isPrivate,
    RouteGeometrySnapshot? geometrySnapshot,
  }) = _SavedRoute;

  /// Parses from JSON storage.
  factory SavedRoute.fromJson(Map<String, dynamic> json) =>
      _$SavedRouteFromJson(json);
}

/// Resolves a launch id to a catalog entry; null when unknown.
typedef LaunchPointLookup = LaunchPoint? Function(String launchId);
