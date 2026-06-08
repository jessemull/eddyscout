import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_persistence/eddyscout_persistence.dart';
import 'package:eddyscout_saved_routes/src/presentation/providers/saved_routes_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('savedRouteRepository waits for database before upsert', () async {
    final container = ProviderContainer(
      overrides: [
        savedRoutesDatabaseProvider.overrideWith((ref) async {
          await Future<void>.delayed(const Duration(milliseconds: 50));
          final db = openSavedRoutesDatabaseForTest();
          ref.onDispose(db.close);
          return db;
        }),
      ],
    );
    addTearDown(container.dispose);

    final route = SavedRoute(
      id: 'sr_lazy',
      name: 'Lazy Route',
      waypoints: const [
        RouteWaypoint(launchId: 'a', order: 0),
        RouteWaypoint(launchId: 'b', order: 1),
      ],
      metadata: const SavedRouteMetadata(distanceMeters: 1000),
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
    );

    final upsert = await container
        .read(savedRouteRepositoryProvider)
        .upsert(route);
    expect(upsert.isSuccess, isTrue);

    final list = await container.read(savedRoutesListProvider.future);
    expect(list, hasLength(1));
    expect(list.single.name, 'Lazy Route');
  });
}
