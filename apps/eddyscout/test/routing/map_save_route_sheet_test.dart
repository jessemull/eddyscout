import 'dart:async' show unawaited;

import 'package:eddyscout/routing/map_save_route_sheet.dart';
import 'package:eddyscout_analytics/eddyscout_analytics.dart';
import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_map/eddyscout_map.dart';
import 'package:eddyscout_saved_routes/eddyscout_saved_routes.dart';
import 'package:eddyscout_saved_routes/src/domain/repositories/saved_route_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../test_localized_app.dart';

class _MockSavedRouteRepository extends Mock implements SavedRouteRepository {}

class _RunnableRoutePlanning extends RoutePlanning {
  @override
  RoutePlanningState build() {
    final putIn = findLaunchPointById('cathedral_park');
    final takeOut = findLaunchPointById('sellwood_riverfront');
    return RoutePlanningState(
      planningMode: true,
      waypoints: [putIn!, takeOut!],
      routeLengthKm: 5.2,
      activeGeometry: RouteGeometrySnapshot(
        polylineLonLat: const [
          [-122.73, 45.56],
          [-122.66, 45.47],
        ],
        lengthMeters: 5200,
        computedAt: DateTime.utc(2026),
      ),
    );
  }
}

class _NoRoutePlanning extends RoutePlanning {
  @override
  RoutePlanningState build() => const RoutePlanningState();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _MockSavedRouteRepository repository;
  Future<void>? sheetFuture;

  setUpAll(() {
    registerFallbackValue(
      SavedRoute(
        id: 'fallback',
        name: 'Fallback',
        waypoints: const [
          RouteWaypoint(launchId: 'a', order: 0),
          RouteWaypoint(launchId: 'b', order: 1),
        ],
        metadata: const SavedRouteMetadata(),
        createdAt: DateTime.utc(2026),
        updatedAt: DateTime.utc(2026),
      ),
    );
  });

  setUp(() {
    repository = _MockSavedRouteRepository();
    when(() => repository.listAll()).thenAnswer(
      (_) async => const Result.success([]),
    );
    when(() => repository.listFavorites()).thenAnswer(
      (_) async => const Result.success([]),
    );
    sheetFuture = null;
  });

  Future<void> pumpHost(
    WidgetTester tester, {
    required List<Override> overrides,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          analyticsClientProvider.overrideWithValue(
            RecordingAnalyticsClient(),
          ),
          launchPointLookupProvider.overrideWithValue(findLaunchPointById),
          savedRouteRepositoryProvider.overrideWithValue(repository),
          ...overrides,
        ],
        child: testLocalizedApp(
          child: Consumer(
            builder: (context, ref, _) {
              return Scaffold(
                body: FilledButton(
                  onPressed: () {
                    sheetFuture = showMapSaveRouteSheet(context, ref);
                  },
                  child: const Text('Open sheet'),
                ),
              );
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('showMapSaveRouteSheet no-ops without runnable route', (
    tester,
  ) async {
    await pumpHost(
      tester,
      overrides: [routePlanningProvider.overrideWith(_NoRoutePlanning.new)],
    );

    await tester.tap(find.text('Open sheet'));
    await sheetFuture;
    await tester.pumpAndSettle();

    expect(find.text('Save route'), findsNothing);
    verifyNever(() => repository.upsert(any()));
  });

  testWidgets('showMapSaveRouteSheet requires route name', (tester) async {
    await pumpHost(
      tester,
      overrides: [
        routePlanningProvider.overrideWith(_RunnableRoutePlanning.new),
      ],
    );

    await tester.tap(find.text('Open sheet'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, '');
    await tester.tap(find.text('Save'));
    await sheetFuture;
    await tester.pumpAndSettle();

    expect(find.text('Enter a route name.'), findsOneWidget);
    verifyNever(() => repository.upsert(any()));
  });

  testWidgets('showMapSaveRouteSheet pre-fills name from waypoints', (
    tester,
  ) async {
    await pumpHost(
      tester,
      overrides: [
        routePlanningProvider.overrideWith(_RunnableRoutePlanning.new),
      ],
    );

    await tester.tap(find.text('Open sheet'));
    await tester.pumpAndSettle();

    expect(
      find.text('Cathedral Park Boat Ramp → Sellwood Riverfront Park'),
      findsOneWidget,
    );
  });

  testWidgets('showMapSaveRouteSheet saves route on success', (tester) async {
    when(() => repository.upsert(any())).thenAnswer(
      (invocation) async => Result.success(
        invocation.positionalArguments.first as SavedRoute,
      ),
    );

    await pumpHost(
      tester,
      overrides: [
        routePlanningProvider.overrideWith(_RunnableRoutePlanning.new),
      ],
    );

    await tester.tap(find.text('Open sheet'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'Morning paddle');
    await tester.tap(find.text('Save'));
    await sheetFuture;
    await tester.pumpAndSettle();

    expect(find.text('Route saved.'), findsOneWidget);
    verify(() => repository.upsert(any(that: isA<SavedRoute>()))).called(1);
  });

  testWidgets(
    'showMapSaveRouteSheet keeps planning state when cleared during save',
    (tester) async {
      late ProviderContainer container;

      when(() => repository.upsert(any())).thenAnswer((invocation) async {
        container.read(routePlanningProvider.notifier).togglePlanningMode();
        return Result.success(
          invocation.positionalArguments.first as SavedRoute,
        );
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            analyticsClientProvider.overrideWithValue(
              RecordingAnalyticsClient(),
            ),
            launchPointLookupProvider.overrideWithValue(findLaunchPointById),
            savedRouteRepositoryProvider.overrideWithValue(repository),
            routePlanningProvider.overrideWith(_RunnableRoutePlanning.new),
          ],
          child: testLocalizedApp(
            child: Consumer(
              builder: (context, ref, _) {
                container = ProviderScope.containerOf(context);
                return Scaffold(
                  body: FilledButton(
                    onPressed: () {
                      sheetFuture = showMapSaveRouteSheet(context, ref);
                    },
                    child: const Text('Open sheet'),
                  ),
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open sheet'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'Morning paddle');
      await tester.tap(find.text('Save'));
      await sheetFuture;
      await tester.pumpAndSettle();

      final planning = container.read(routePlanningProvider);
      expect(planning.planningMode, isTrue);
      expect(planning.waypoints.length, 2);
      expect(planning.activeGeometry, isNotNull);
      expect(planning.routeLengthKm, closeTo(5.2, 0.01));
    },
  );

  testWidgets('showMapSaveRouteSheet shows error when save fails', (
    tester,
  ) async {
    when(() => repository.upsert(any())).thenAnswer(
      (_) async => const Result.failure(
        StorageFailure(message: 'disk full'),
      ),
    );

    await pumpHost(
      tester,
      overrides: [
        routePlanningProvider.overrideWith(_RunnableRoutePlanning.new),
      ],
    );

    await tester.tap(find.text('Open sheet'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'Evening paddle');
    await tester.tap(find.text('Save'));
    await sheetFuture;
    await tester.pumpAndSettle();

    expect(find.text('Could not save route.'), findsOneWidget);
  });

  testWidgets('handlePendingSavedRouteLoad loads planning state and geometry', (
    tester,
  ) async {
    final putIn = findLaunchPointById('cathedral_park')!;
    final takeOut = findLaunchPointById('sellwood_riverfront')!;
    final route = SavedRoute(
      id: 'sr_load_ok',
      name: 'Load me',
      waypoints: const [
        RouteWaypoint(launchId: 'cathedral_park', order: 0),
        RouteWaypoint(launchId: 'sellwood_riverfront', order: 1),
      ],
      metadata: const SavedRouteMetadata(distanceMeters: 5200),
      geometrySnapshot: RouteGeometrySnapshot(
        polylineLonLat: const [
          [-122.73, 45.56],
          [-122.66, 45.47],
        ],
        lengthMeters: 5200,
        computedAt: DateTime.utc(2026),
      ),
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
    );

    late ProviderContainer container;

    when(() => repository.getById('sr_load_ok')).thenAnswer(
      (_) async => Result.success(route),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          launchPointLookupProvider.overrideWithValue(findLaunchPointById),
          savedRouteRepositoryProvider.overrideWithValue(repository),
        ],
        child: testLocalizedApp(
          child: Consumer(
            builder: (context, ref, _) {
              container = ProviderScope.containerOf(context);
              return Scaffold(
                body: FilledButton(
                  onPressed: () {
                    unawaited(() async {
                      container
                              .read(pendingSavedRouteLoadProvider.notifier)
                              .draftRoute =
                          route;
                      await handlePendingSavedRouteLoad(context, ref);
                    }());
                  },
                  child: const Text('Load pending'),
                ),
              );
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Load pending'));
    await tester.pumpAndSettle();

    final planning = container.read(routePlanningProvider);
    expect(planning.planningMode, isTrue);
    expect(planning.waypoints, [putIn, takeOut]);
    expect(planning.routeLengthKm, closeTo(5.2, 0.01));
    expect(planning.polylineLonLat, route.geometrySnapshot!.polylineLonLat);
  });

  testWidgets(
    'handlePendingSavedRouteLoad shows snackbar for unknown launches',
    (
      tester,
    ) async {
      final route = SavedRoute(
        id: 'sr_load',
        name: 'Load me',
        waypoints: const [
          RouteWaypoint(launchId: 'missing-a', order: 0),
          RouteWaypoint(launchId: 'missing-b', order: 1),
        ],
        metadata: const SavedRouteMetadata(),
        createdAt: DateTime.utc(2026),
        updatedAt: DateTime.utc(2026),
      );

      when(() => repository.getById('sr_load')).thenAnswer(
        (_) async => Result.success(route),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            launchPointLookupProvider.overrideWithValue((_) => null),
            savedRouteRepositoryProvider.overrideWithValue(repository),
          ],
          child: testLocalizedApp(
            child: Consumer(
              builder: (context, ref, _) {
                return Scaffold(
                  body: FilledButton(
                    onPressed: () {
                      unawaited(() async {
                        ref
                                .read(pendingSavedRouteLoadProvider.notifier)
                                .draftRoute =
                            route;
                        await handlePendingSavedRouteLoad(context, ref);
                      }());
                    },
                    child: const Text('Load pending'),
                  ),
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Load pending'));
      await tester.pumpAndSettle();

      expect(
        find.text('Could not load route — too few known launch points.'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'handlePendingSavedRouteLoad shows not found when route was deleted',
    (
      tester,
    ) async {
      final draft = SavedRoute(
        id: 'missing',
        name: 'Ghost route',
        waypoints: const [
          RouteWaypoint(launchId: 'cathedral_park', order: 0),
          RouteWaypoint(launchId: 'sellwood_riverfront', order: 1),
        ],
        metadata: const SavedRouteMetadata(),
        createdAt: DateTime.utc(2026),
        updatedAt: DateTime.utc(2026),
      );
      when(() => repository.getById('missing')).thenAnswer(
        (_) async => const Result.success(null),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            launchPointLookupProvider.overrideWithValue(findLaunchPointById),
            savedRouteRepositoryProvider.overrideWithValue(repository),
          ],
          child: testLocalizedApp(
            child: Consumer(
              builder: (context, ref, _) {
                return Scaffold(
                  body: FilledButton(
                    onPressed: () {
                      unawaited(() async {
                        ref
                                .read(pendingSavedRouteLoadProvider.notifier)
                                .draftRoute =
                            draft;
                        await handlePendingSavedRouteLoad(context, ref);
                      }());
                    },
                    child: const Text('Load pending'),
                  ),
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Load pending'));
      await tester.pumpAndSettle();

      expect(find.text('Route not found.'), findsOneWidget);
    },
  );

  testWidgets(
    'handlePendingSavedRouteLoad uses draft waypoints over persisted route',
    (tester) async {
      final putIn = findLaunchPointById('cathedral_park')!;
      final takeOut = findLaunchPointById('sellwood_riverfront')!;
      final persisted = SavedRoute(
        id: 'sr_draft',
        name: 'Persisted',
        waypoints: const [
          RouteWaypoint(launchId: 'cathedral_park', order: 0),
          RouteWaypoint(launchId: 'sellwood_riverfront', order: 1),
        ],
        metadata: const SavedRouteMetadata(distanceMeters: 5200),
        geometrySnapshot: RouteGeometrySnapshot(
          polylineLonLat: const [
            [-122.73, 45.56],
            [-122.66, 45.47],
          ],
          lengthMeters: 5200,
          computedAt: DateTime.utc(2026),
        ),
        createdAt: DateTime.utc(2026),
        updatedAt: DateTime.utc(2026),
      );
      final draft = persisted.copyWith(
        waypoints: const [
          RouteWaypoint(launchId: 'sellwood_riverfront', order: 0),
          RouteWaypoint(launchId: 'cathedral_park', order: 1),
        ],
        geometrySnapshot: null,
      );

      late ProviderContainer container;

      when(() => repository.getById('sr_draft')).thenAnswer(
        (_) async => Result.success(persisted),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            launchPointLookupProvider.overrideWithValue(findLaunchPointById),
            savedRouteRepositoryProvider.overrideWithValue(repository),
          ],
          child: testLocalizedApp(
            child: Consumer(
              builder: (context, ref, _) {
                container = ProviderScope.containerOf(context);
                return Scaffold(
                  body: FilledButton(
                    onPressed: () {
                      unawaited(() async {
                        ref
                                .read(pendingSavedRouteLoadProvider.notifier)
                                .draftRoute =
                            draft;
                        await handlePendingSavedRouteLoad(context, ref);
                      }());
                    },
                    child: const Text('Load pending'),
                  ),
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Load pending'));
      await tester.pumpAndSettle();

      final planning = container.read(routePlanningProvider);
      expect(planning.waypoints, [takeOut, putIn]);
      expect(planning.activeGeometry, isNull);
    },
  );

  testWidgets('handlePendingSavedRouteLoad no-ops when queue is empty', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          savedRouteRepositoryProvider.overrideWithValue(repository),
        ],
        child: testLocalizedApp(
          child: Consumer(
            builder: (context, ref, _) {
              return Scaffold(
                body: FilledButton(
                  onPressed: () {
                    unawaited(() async {
                      await handlePendingSavedRouteLoad(context, ref);
                    }());
                  },
                  child: const Text('Load pending'),
                ),
              );
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Load pending'));
    await tester.pumpAndSettle();

    expect(find.byType(SnackBar), findsNothing);
    verifyNever(() => repository.getById(any()));
  });

  testWidgets('handlePendingSavedRouteLoad shows error when load fails', (
    tester,
  ) async {
    final draft = SavedRoute(
      id: 'broken',
      name: 'Broken',
      waypoints: const [
        RouteWaypoint(launchId: 'cathedral_park', order: 0),
        RouteWaypoint(launchId: 'sellwood_riverfront', order: 1),
      ],
      metadata: const SavedRouteMetadata(),
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
    );
    when(() => repository.getById('broken')).thenAnswer(
      (_) async => const Result.failure(
        StorageFailure(message: 'db down'),
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          launchPointLookupProvider.overrideWithValue(findLaunchPointById),
          savedRouteRepositoryProvider.overrideWithValue(repository),
        ],
        child: testLocalizedApp(
          child: Consumer(
            builder: (context, ref, _) {
              return Scaffold(
                body: FilledButton(
                  onPressed: () {
                    unawaited(() async {
                      ref
                              .read(pendingSavedRouteLoadProvider.notifier)
                              .draftRoute =
                          draft;
                      await handlePendingSavedRouteLoad(context, ref);
                    }());
                  },
                  child: const Text('Load pending'),
                ),
              );
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Load pending'));
    await tester.pumpAndSettle();

    expect(find.text('Could not load this route.'), findsOneWidget);
  });
}
