import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_persistence/eddyscout_persistence.dart';
import 'package:eddyscout_saved_routes/src/data/mappers/saved_route_row_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final computedAt = DateTime.utc(2026, 4);

  test('savedRouteFromRow parses geometry and metadata', () {
    final row = SavedRouteRow(
      id: 'sr_row',
      name: 'Row Route',
      description: 'desc',
      notes: 'notes',
      isFavorite: true,
      isPrivate: false,
      waypointsJson: '[{"launchId":"a","order":0},{"launchId":"b","order":1}]',
      metadataJson:
          '{"difficulty":"easy","categories":["training"],'
          '"distanceMeters":4200}',
      geometryJson:
          '{"polylineLonLat":[[-122.7,45.5],[-122.6,45.4]],'
          '"lengthMeters":4200,"computedAt":"2026-04-01T00:00:00.000Z"}',
      createdAt: computedAt.millisecondsSinceEpoch,
      updatedAt: computedAt.millisecondsSinceEpoch,
    );

    final route = savedRouteFromRow(row);

    expect(route.id, 'sr_row');
    expect(route.metadata.difficulty, RouteDifficulty.easy);
    expect(route.metadata.categories, ['training']);
    expect(route.geometrySnapshot?.lengthMeters, 4200);
  });

  test('trySavedRouteFromRow returns null for corrupt json', () {
    const row = SavedRouteRow(
      id: 'bad',
      name: 'Bad',
      notes: '',
      isFavorite: false,
      isPrivate: true,
      waypointsJson: '{',
      metadataJson: '{}',
      createdAt: 0,
      updatedAt: 0,
    );

    expect(trySavedRouteFromRow(row), isNull);
  });

  test('savedRouteToCompanion round-trips through fromRow', () {
    final route = SavedRoute(
      id: 'sr_companion',
      name: 'Companion',
      waypoints: const [
        RouteWaypoint(launchId: 'a', order: 0),
        RouteWaypoint(launchId: 'b', order: 1),
      ],
      metadata: const SavedRouteMetadata(
        distanceMeters: 1000,
        categories: ['commute'],
      ),
      geometrySnapshot: RouteGeometrySnapshot(
        polylineLonLat: const [
          [-122.7, 45.5],
        ],
        lengthMeters: 1000,
        computedAt: computedAt,
      ),
      createdAt: computedAt,
      updatedAt: computedAt,
    );

    final companion = savedRouteToCompanion(route);
    final row = SavedRouteRow(
      id: route.id,
      name: route.name,
      description: route.description,
      notes: route.notes,
      isFavorite: route.isFavorite,
      isPrivate: route.isPrivate,
      waypointsJson: companion.waypointsJson.value,
      metadataJson: companion.metadataJson.value,
      geometryJson: companion.geometryJson.present
          ? companion.geometryJson.value
          : null,
      createdAt: companion.createdAt.value,
      updatedAt: companion.updatedAt.value,
    );

    final decoded = savedRouteFromRow(row);
    expect(decoded.metadata.categories, ['commute']);
    expect(decoded.geometrySnapshot?.lengthMeters, 1000);
  });
}
