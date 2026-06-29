import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_persistence/eddyscout_persistence.dart';
import 'package:eddyscout_saved_routes/src/data/repositories/saved_route_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late SavedRoutesDatabase db;
  late SavedRouteRepositoryImpl repository;

  setUp(() {
    db = openSavedRoutesDatabaseForTest();
    repository = SavedRouteRepositoryImpl(db);
  });

  tearDown(() async {
    await db.close();
  });

  SavedRoute sampleRoute({
    required String routeId,
    required String routeName,
  }) {
    final now = DateTime.utc(2026);
    return SavedRoute(
      id: routeId,
      name: routeName,
      waypoints: const [
        RouteWaypoint.catalog(launchId: 'a', order: 0),
        RouteWaypoint.catalog(launchId: 'b', order: 1),
      ],
      metadata: const SavedRouteMetadata(),
      createdAt: now,
      updatedAt: now,
    );
  }

  test('upsert and listAll round-trip', () async {
    final route = sampleRoute(routeId: 'r1', routeName: 'Test');
    final upsert = await repository.upsert(route);
    expect(upsert.isSuccess, isTrue);

    final list = await repository.listAll();
    expect(list.valueOrNull, hasLength(1));
    expect(list.valueOrNull!.single.name, 'Test');
  });

  test('setFavorite updates flag', () async {
    await repository.upsert(sampleRoute(routeId: 'f1', routeName: 'Fav'));
    final result = await repository.setFavorite('f1', isFavorite: true);
    expect(result.valueOrNull!.isFavorite, isTrue);

    final favorites = await repository.listFavorites();
    expect(favorites.valueOrNull, hasLength(1));
  });

  test('delete removes route', () async {
    await repository.upsert(sampleRoute(routeId: 'd1', routeName: 'Del'));
    final deleted = await repository.delete('d1');
    expect(deleted.isSuccess, isTrue);

    final get = await repository.getById('d1');
    expect(get.valueOrNull, isNull);
  });

  test('listAll skips rows with corrupt waypoints_json', () async {
    await db.upsertRoute(
      SavedRoutesCompanion.insert(
        id: 'bad',
        name: 'Corrupt',
        waypointsJson: 'not-valid-json',
        metadataJson: '{}',
        createdAt: 1000,
        updatedAt: 1000,
      ),
    );
    await repository.upsert(sampleRoute(routeId: 'good', routeName: 'Good'));

    final list = await repository.listAll();
    expect(list.isSuccess, isTrue);
    expect(list.valueOrNull, hasLength(1));
    expect(list.valueOrNull!.single.id, 'good');
  });

  test('getById returns ParseFailure for corrupt row', () async {
    await db.upsertRoute(
      SavedRoutesCompanion.insert(
        id: 'bad',
        name: 'Corrupt',
        waypointsJson: '{',
        metadataJson: '{}',
        createdAt: 1000,
        updatedAt: 1000,
      ),
    );

    final result = await repository.getById('bad');
    expect(result.isFailure, isTrue);
    expect(result.errorOrNull, isA<ParseFailure>());
  });

  test('delete returns NotFoundFailure when missing', () async {
    final result = await repository.delete('missing');
    expect(result.isFailure, isTrue);
    expect(result.errorOrNull, isA<NotFoundFailure>());
  });

  test('setFavorite returns NotFoundFailure when missing', () async {
    final result = await repository.setFavorite(
      'missing',
      isFavorite: true,
    );
    expect(result.isFailure, isTrue);
    expect(result.errorOrNull, isA<NotFoundFailure>());
  });
}
