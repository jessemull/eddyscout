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

    await tester.tap(find.text('Save'));
    await sheetFuture;
    await tester.pumpAndSettle();

    expect(find.text('Enter a route name.'), findsOneWidget);
    verifyNever(() => repository.upsert(any()));
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

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            launchPointLookupProvider.overrideWithValue((_) => null),
            savedRouteByIdProvider(
              'sr_load',
            ).overrideWith((ref) async => route),
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
                                .pendingRouteId =
                            'sr_load';
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

  testWidgets('handlePendingSavedRouteLoad no-ops when route missing', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          savedRouteByIdProvider('missing').overrideWith((ref) async => null),
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
                              .pendingRouteId =
                          'missing';
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
  });
}
