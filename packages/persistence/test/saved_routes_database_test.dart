import 'package:drift/drift.dart' show Value;
import 'package:eddyscout_persistence/eddyscout_persistence.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late SavedRoutesDatabase db;

  setUp(() {
    db = openSavedRoutesDatabaseForTest();
  });

  tearDown(() async {
    await db.close();
  });

  SavedRoutesCompanion testRow({
    required String id,
    required String name,
    bool isFavorite = false,
    int updatedAt = 1000,
  }) => SavedRoutesCompanion.insert(
    id: id,
    name: name,
    waypointsJson: '[{"launchId":"a","order":0}]',
    metadataJson: '{}',
    createdAt: updatedAt,
    updatedAt: updatedAt,
    isFavorite: Value(isFavorite),
  );

  test('upsert and getById round-trip', () async {
    await db.upsertRoute(testRow(id: 'r1', name: 'Morning paddle'));

    final saved = await db.getRouteById('r1');
    expect(saved, isNotNull);
    expect(saved!.name, 'Morning paddle');
  });

  test('getAllRoutes orders by updatedAt desc', () async {
    await db.upsertRoute(testRow(id: 'old', name: 'Old', updatedAt: 100));
    await db.upsertRoute(testRow(id: 'new', name: 'New', updatedAt: 200));

    final rows = await db.getAllRoutes();
    expect(rows.map((r) => r.id), ['new', 'old']);
  });

  test('getFavoriteRoutes filters favorites', () async {
    await db.upsertRoute(testRow(id: 'fav', name: 'Fav', isFavorite: true));
    await db.upsertRoute(testRow(id: 'other', name: 'Other'));

    final favorites = await db.getFavoriteRoutes();
    expect(favorites, hasLength(1));
    expect(favorites.single.id, 'fav');
  });

  test('deleteRoute removes row', () async {
    await db.upsertRoute(testRow(id: 'del', name: 'Del'));

    expect(await db.deleteRoute('del'), isTrue);
    expect(await db.getRouteById('del'), isNull);
  });

  test('setFavorite updates flag', () async {
    await db.upsertRoute(testRow(id: 'x', name: 'X'));

    expect(
      await db.setFavorite(id: 'x', isFavorite: true, updatedAtMs: 5000),
      isTrue,
    );
    final updated = await db.getRouteById('x');
    expect(updated!.isFavorite, isTrue);
    expect(updated.updatedAt, 5000);
  });
}
