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
      phase: MapPlanningPhase.routeReady,
      stops: [
        RoutePlanningStop.catalog(putIn!),
        RoutePlanningStop.catalog(takeOut!),
      ],
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

class _MixedSnapRoutePlanning extends RoutePlanning {
  @override
  RoutePlanningState build() {
    final putIn = findLaunchPointById('cathedral_park');
    return RoutePlanningState(
      phase: MapPlanningPhase.routeReady,
      stops: [
        RoutePlanningStop.catalog(putIn!),
        const RoutePlanningStop.snap(
          id: 'snap_test_1',
          latitude: 45.5512,
          longitude: -122.6789,
          label: 'Lunch spot',
        ),
      ],
      routeLengthKm: 3.0,
      activeGeometry: RouteGeometrySnapshot(
        polylineLonLat: const [
          [-122.73, 45.56],
          [-122.67, 45.55],
        ],
        lengthMeters: 3000,
        computedAt: DateTime.utc(2026),
      ),
    );
  }
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
          RouteWaypoint.catalog(launchId: 'a', order: 0),
          RouteWaypoint.catalog(launchId: 'b', order: 1),
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

  testWidgets('showMapSaveRouteSheet persists snap waypoints on save', (
    tester,
  ) async {
    SavedRoute? captured;
    when(() => repository.upsert(any())).thenAnswer((invocation) async {
      captured = invocation.positionalArguments.first as SavedRoute;
      return Result.success(captured!);
    });

    await pumpHost(
      tester,
      overrides: [
        routePlanningProvider.overrideWith(_MixedSnapRoutePlanning.new),
      ],
    );

    await tester.tap(find.text('Open sheet'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'Snap route');
    await tester.tap(find.text('Save'));
    await sheetFuture;
    await tester.pumpAndSettle();

    expect(captured, isNotNull);
    expect(captured!.waypoints, hasLength(2));
    expect(captured!.waypoints[0], isA<CatalogRouteWaypoint>());
    final snap = captured!.waypoints[1];
    expect(snap, isA<SnapRouteWaypoint>());
    expect((snap as SnapRouteWaypoint).label, 'Lunch spot');
    expect(snap.latitude, closeTo(45.5512, 0.0001));
    expect(snap.longitude, closeTo(-122.6789, 0.0001));
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
      expect(planning.stops.length, 2);
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
        RouteWaypoint.catalog(launchId: 'cathedral_park', order: 0),
        RouteWaypoint.catalog(launchId: 'sellwood_riverfront', order: 1),
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
                              .state =
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
    expect(planning.catalogLaunches, [putIn, takeOut]);
    expect(planning.routeLengthKm, closeTo(5.2, 0.01));
    expect(planning.polylineLonLat, route.geometrySnapshot!.polylineLonLat);
  });

  testWidgets('handlePendingSavedRouteLoad restores snap waypoints', (
    tester,
  ) async {
    final putIn = findLaunchPointById('cathedral_park')!;
    final route = SavedRoute(
      id: 'sr_snap_load',
      name: 'Snap load',
      waypoints: const [
        RouteWaypoint.catalog(launchId: 'cathedral_park', order: 0),
        RouteWaypoint.snap(
          latitude: 45.5512,
          longitude: -122.6789,
          order: 1,
          label: 'Lunch spot',
        ),
      ],
      metadata: const SavedRouteMetadata(distanceMeters: 3000),
      geometrySnapshot: RouteGeometrySnapshot(
        polylineLonLat: const [
          [-122.73, 45.56],
          [-122.67, 45.55],
        ],
        lengthMeters: 3000,
        computedAt: DateTime.utc(2026),
      ),
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
    );

    when(() => repository.getById('sr_snap_load')).thenAnswer(
      (_) async => Result.success(route),
    );

    late ProviderContainer container;

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
                              .state =
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
    expect(planning.stops, hasLength(2));
    expect(planning.stops[0], RoutePlanningStop.catalog(putIn));
    expect(planning.stops[1], isA<SnapRoutePlanningStop>());
    final snap = planning.stops[1] as SnapRoutePlanningStop;
    expect(snap.label, 'Lunch spot');
    expect(snap.latitude, closeTo(45.5512, 0.0001));
    expect(snap.longitude, closeTo(-122.6789, 0.0001));
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
          RouteWaypoint.catalog(launchId: 'missing-a', order: 0),
          RouteWaypoint.catalog(launchId: 'missing-b', order: 1),
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
                        ref.read(pendingSavedRouteLoadProvider.notifier).state =
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
          RouteWaypoint.catalog(launchId: 'cathedral_park', order: 0),
          RouteWaypoint.catalog(launchId: 'sellwood_riverfront', order: 1),
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
                        ref.read(pendingSavedRouteLoadProvider.notifier).state =
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
          RouteWaypoint.catalog(launchId: 'cathedral_park', order: 0),
          RouteWaypoint.catalog(launchId: 'sellwood_riverfront', order: 1),
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
          RouteWaypoint.catalog(launchId: 'sellwood_riverfront', order: 0),
          RouteWaypoint.catalog(launchId: 'cathedral_park', order: 1),
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
                        ref.read(pendingSavedRouteLoadProvider.notifier).state =
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
      expect(planning.catalogLaunches, [takeOut, putIn]);
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
        RouteWaypoint.catalog(launchId: 'cathedral_park', order: 0),
        RouteWaypoint.catalog(launchId: 'sellwood_riverfront', order: 1),
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
                      ref.read(pendingSavedRouteLoadProvider.notifier).state =
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

  testWidgets('handlePendingSavedRouteLoad shows error when map draw fails', (
    tester,
  ) async {
    final putIn = findLaunchPointById('cathedral_park')!;
    final takeOut = findLaunchPointById('sellwood_riverfront')!;
    final route = SavedRoute(
      id: 'sr_draw_fail',
      name: 'Draw fail',
      waypoints: const [
        RouteWaypoint.catalog(launchId: 'cathedral_park', order: 0),
        RouteWaypoint.catalog(launchId: 'sellwood_riverfront', order: 1),
      ],
      metadata: const SavedRouteMetadata(),
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

    when(() => repository.getById('sr_draw_fail')).thenAnswer(
      (_) async => Result.success(route),
    );
    debugDrawSavedRouteOnMap = (_, _) async => throw StateError('draw failed');
    addTearDown(() => debugDrawSavedRouteOnMap = null);

    late ProviderContainer container;

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
                          .queueDraft(route);
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
      find.text('Route loaded, but the map could not draw the line.'),
      findsOneWidget,
    );
    final planning = container.read(routePlanningProvider);
    expect(planning.catalogLaunches, [putIn, takeOut]);
  });
}
