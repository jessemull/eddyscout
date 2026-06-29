// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saved_route_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CatalogRouteWaypoint _$CatalogRouteWaypointFromJson(
  Map<String, dynamic> json,
) => CatalogRouteWaypoint(
  launchId: json['launchId'] as String,
  order: (json['order'] as num).toInt(),
  $type: json['type'] as String?,
);

Map<String, dynamic> _$CatalogRouteWaypointToJson(
  CatalogRouteWaypoint instance,
) => <String, dynamic>{
  'launchId': instance.launchId,
  'order': instance.order,
  'type': instance.$type,
};

SnapRouteWaypoint _$SnapRouteWaypointFromJson(Map<String, dynamic> json) =>
    SnapRouteWaypoint(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      order: (json['order'] as num).toInt(),
      label: json['label'] as String?,
      $type: json['type'] as String?,
    );

Map<String, dynamic> _$SnapRouteWaypointToJson(SnapRouteWaypoint instance) =>
    <String, dynamic>{
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'order': instance.order,
      'label': instance.label,
      'type': instance.$type,
    };

_RouteGeometrySnapshot _$RouteGeometrySnapshotFromJson(
  Map<String, dynamic> json,
) => _RouteGeometrySnapshot(
  polylineLonLat: (json['polylineLonLat'] as List<dynamic>)
      .map(
        (e) => (e as List<dynamic>).map((e) => (e as num).toDouble()).toList(),
      )
      .toList(),
  lengthMeters: (json['lengthMeters'] as num).toDouble(),
  computedAt: DateTime.parse(json['computedAt'] as String),
);

Map<String, dynamic> _$RouteGeometrySnapshotToJson(
  _RouteGeometrySnapshot instance,
) => <String, dynamic>{
  'polylineLonLat': instance.polylineLonLat,
  'lengthMeters': instance.lengthMeters,
  'computedAt': instance.computedAt.toIso8601String(),
};

_SavedRouteMetadata _$SavedRouteMetadataFromJson(Map<String, dynamic> json) =>
    _SavedRouteMetadata(
      difficulty: _routeDifficultyFromJson(json['difficulty']),
      distanceMeters: (json['distanceMeters'] as num?)?.toDouble(),
      estimatedDurationMinutes: (json['estimatedDurationMinutes'] as num?)
          ?.toInt(),
      exposure: _windExposureFromJson(json['exposure']),
      tideDependency: _tideRelevanceFromJson(json['tideDependency']),
      recommendedSkillLevel: _recommendedSkillLevelFromJson(
        json['recommendedSkillLevel'],
      ),
      categories:
          (json['categories'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
    );

Map<String, dynamic> _$SavedRouteMetadataToJson(_SavedRouteMetadata instance) =>
    <String, dynamic>{
      'difficulty': _routeDifficultyToJson(instance.difficulty),
      'distanceMeters': instance.distanceMeters,
      'estimatedDurationMinutes': instance.estimatedDurationMinutes,
      'exposure': _windExposureToJson(instance.exposure),
      'tideDependency': _tideRelevanceToJson(instance.tideDependency),
      'recommendedSkillLevel': _recommendedSkillLevelToJson(
        instance.recommendedSkillLevel,
      ),
      'categories': instance.categories,
    };

_SavedRoute _$SavedRouteFromJson(Map<String, dynamic> json) => _SavedRoute(
  id: json['id'] as String,
  name: json['name'] as String,
  waypoints: (json['waypoints'] as List<dynamic>)
      .map((e) => RouteWaypoint.fromJson(e as Map<String, dynamic>))
      .toList(),
  metadata: SavedRouteMetadata.fromJson(
    json['metadata'] as Map<String, dynamic>,
  ),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  description: json['description'] as String?,
  notes: json['notes'] as String? ?? '',
  isFavorite: json['isFavorite'] as bool? ?? false,
  isPrivate: json['isPrivate'] as bool? ?? true,
  geometrySnapshot: json['geometrySnapshot'] == null
      ? null
      : RouteGeometrySnapshot.fromJson(
          json['geometrySnapshot'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$SavedRouteToJson(_SavedRoute instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'waypoints': instance.waypoints,
      'metadata': instance.metadata,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'description': instance.description,
      'notes': instance.notes,
      'isFavorite': instance.isFavorite,
      'isPrivate': instance.isPrivate,
      'geometrySnapshot': instance.geometrySnapshot,
    };
