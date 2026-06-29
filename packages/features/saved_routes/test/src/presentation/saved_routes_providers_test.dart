import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_saved_routes/src/presentation/providers/saved_routes_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('savedRouteRepositoryProvider throws when not overridden', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(
      () => container.read(savedRouteRepositoryProvider),
      throwsA(isA<Object>()),
    );
  });

  test('pendingSavedRouteLoad queueDraft and take round-trip', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final route = SavedRoute(
      id: 'sr_pending',
      name: 'Pending',
      waypoints: const [
        RouteWaypoint.catalog(launchId: 'a', order: 0),
        RouteWaypoint.catalog(launchId: 'b', order: 1),
      ],
      metadata: const SavedRouteMetadata(),
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
    );
    final notifier = container.read(pendingSavedRouteLoadProvider.notifier)
      ..queueDraft(route);

    expect(notifier.take(), route);
    expect(notifier.take(), isNull);
  });
}
