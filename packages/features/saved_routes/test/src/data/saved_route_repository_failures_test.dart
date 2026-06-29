import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_persistence/eddyscout_persistence.dart';
import 'package:eddyscout_saved_routes/src/data/repositories/saved_route_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockSavedRoutesDatabase extends Mock implements SavedRoutesDatabase {}

void main() {
  late _MockSavedRoutesDatabase database;
  late SavedRouteRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(
      SavedRoutesCompanion.insert(
        id: 'fallback',
        name: 'Fallback',
        waypointsJson: '[]',
        metadataJson: '{}',
        createdAt: 0,
        updatedAt: 0,
      ),
    );
  });

  setUp(() {
    database = _MockSavedRoutesDatabase();
    repository = SavedRouteRepositoryImpl(database);
  });

  test('listAll returns StorageFailure when database throws', () async {
    when(() => database.getAllRoutes()).thenThrow(Exception('db'));

    final result = await repository.listAll();

    expect(result.errorOrNull, isA<StorageFailure>());
  });

  test('listFavorites returns StorageFailure when database throws', () async {
    when(() => database.getFavoriteRoutes()).thenThrow(Exception('db'));

    final result = await repository.listFavorites();

    expect(result.errorOrNull, isA<StorageFailure>());
  });

  test('getById returns StorageFailure when database throws', () async {
    when(() => database.getRouteById('x')).thenThrow(Exception('db'));

    final result = await repository.getById('x');

    expect(result.errorOrNull, isA<StorageFailure>());
  });

  test('upsert returns StorageFailure when database throws', () async {
    final route = SavedRoute(
      id: 'r1',
      name: 'Route',
      waypoints: const [
        RouteWaypoint.catalog(launchId: 'a', order: 0),
        RouteWaypoint.catalog(launchId: 'b', order: 1),
      ],
      metadata: const SavedRouteMetadata(),
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
    );
    when(() => database.upsertRoute(any())).thenThrow(Exception('db'));

    final result = await repository.upsert(route);

    expect(result.errorOrNull, isA<StorageFailure>());
  });

  test('delete returns StorageFailure when database throws', () async {
    when(() => database.deleteRoute('r1')).thenThrow(Exception('db'));

    final result = await repository.delete('r1');

    expect(result.errorOrNull, isA<StorageFailure>());
  });

  test('setFavorite returns StorageFailure when database throws', () async {
    when(() => database.getRouteById('r1')).thenThrow(Exception('db'));

    final result = await repository.setFavorite('r1', isFavorite: true);

    expect(result.errorOrNull, isA<StorageFailure>());
  });
}
