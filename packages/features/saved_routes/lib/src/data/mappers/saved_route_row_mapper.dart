import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_persistence/eddyscout_persistence.dart';

/// Maps Drift rows to core saved route entities.
SavedRoute savedRouteFromRow(SavedRouteRow row) {
  final waypointsJson = jsonDecode(row.waypointsJson) as List<dynamic>;
  final metadataJson = jsonDecode(row.metadataJson) as Map<String, dynamic>;
  RouteGeometrySnapshot? geometry;
  if (row.geometryJson case final String raw?) {
    geometry = RouteGeometrySnapshot.fromJson(
      jsonDecode(raw) as Map<String, dynamic>,
    );
  }
  return SavedRoute(
    id: row.id,
    name: row.name,
    description: row.description,
    notes: row.notes,
    isFavorite: row.isFavorite,
    isPrivate: row.isPrivate,
    waypoints: waypointsJson
        .map((e) => RouteWaypoint.fromJson(e as Map<String, dynamic>))
        .toList(),
    metadata: SavedRouteMetadata.fromJson(metadataJson),
    geometrySnapshot: geometry,
    createdAt: DateTime.fromMillisecondsSinceEpoch(row.createdAt),
    updatedAt: DateTime.fromMillisecondsSinceEpoch(row.updatedAt),
  );
}

/// Maps a [SavedRoute] entity to a Drift companion row.
SavedRoutesCompanion savedRouteToCompanion(SavedRoute route) {
  return SavedRoutesCompanion.insert(
    id: route.id,
    name: route.name,
    description: Value(route.description),
    notes: Value(route.notes),
    isFavorite: Value(route.isFavorite),
    isPrivate: Value(route.isPrivate),
    waypointsJson: jsonEncode(route.waypoints.map((w) => w.toJson()).toList()),
    metadataJson: jsonEncode(route.metadata.toJson()),
    geometryJson: Value(
      route.geometrySnapshot == null
          ? null
          : jsonEncode(route.geometrySnapshot!.toJson()),
    ),
    createdAt: route.createdAt.millisecondsSinceEpoch,
    updatedAt: route.updatedAt.millisecondsSinceEpoch,
  );
}
