import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_saved_routes/src/domain/repositories/saved_route_repository.dart';
import 'package:eddyscout_saved_routes/src/presentation/providers/saved_routes_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/test_saved_routes.dart';

class _MockSavedRouteRepository extends Mock implements SavedRouteRepository {}

void main() {
  late _MockSavedRouteRepository repository;

  setUp(() {
    repository = _MockSavedRouteRepository();
  });

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
        RouteWaypoint(launchId: 'a', order: 0),
        RouteWaypoint(launchId: 'b', order: 1),
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

  test('savedRoutesListProvider loads routes from repository', () async {
    final route = testSavedRoute();
    when(() => repository.listAll()).thenAnswer(
      (_) async => Result.success([route]),
    );

    final container = ProviderContainer(
      overrides: [
        savedRouteRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    final routes = await container.read(savedRoutesListProvider.future);
    expect(routes, [route]);
  });

  test(
    'savedRoutesController create invalidates list providers on success',
    () async {
      final route = testSavedRoute();
      when(() => repository.upsert(route)).thenAnswer(
        (_) async => Result.success(route),
      );
      when(() => repository.listAll()).thenAnswer(
        (_) async => Result.success([route]),
      );
      when(() => repository.listFavorites()).thenAnswer(
        (_) async => const Result.success([]),
      );
      when(() => repository.getById(route.id)).thenAnswer(
        (_) async => Result.success(route),
      );

      final container = ProviderContainer(
        overrides: [
          savedRouteRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      final result = await container
          .read(savedRoutesControllerProvider.notifier)
          .create(route);

      expect(result.isSuccess, isTrue);
      expect(
        await container.read(savedRoutesListProvider.future),
        [route],
      );
    },
  );
}
