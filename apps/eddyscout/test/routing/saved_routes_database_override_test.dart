import 'package:eddyscout/routing/saved_routes_database_override.dart';
import 'package:eddyscout_persistence/eddyscout_persistence.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('test override opens in-memory database', () async {
    final container = ProviderContainer(
      overrides: [savedRoutesDatabaseTestOverride()],
    );
    addTearDown(container.dispose);

    final db = await container.read(savedRoutesDatabaseProvider.future);
    expect(db, isA<SavedRoutesDatabase>());
  });

  test('openTestSavedRoutesDatabase closes on container dispose', () async {
    SavedRoutesDatabase? db;
    final container = ProviderContainer(
      overrides: [
        savedRoutesDatabaseProvider.overrideWith((ref) async {
          db = openTestSavedRoutesDatabase(ref);
          return db!;
        }),
      ],
    );
    addTearDown(container.dispose);

    await container.read(savedRoutesDatabaseProvider.future);
    expect(db, isNotNull);
    container.dispose();
    await db!.close();
  });
}
