import 'package:eddyscout_conditions/eddyscout_conditions.dart';
import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/test_launches.dart';
import '../../helpers/test_localized_app.dart';

class _MockConditionsRepository extends Mock implements ConditionsRepository {}

class _MockGoNoGoProfileRepository extends Mock
    implements GoNoGoProfileRepository {}

RouteGoNoGoWaypointsKey _waypointsKey(List<String> launchIds) {
  return RouteGoNoGoWaypointsKey.fromOrdered(launchIds);
}

RouteGoNoGoResult _rollupResult({
  GoNoGoVerdict verdict = GoNoGoVerdict.marginal,
  String stopName = 'Kelley Point Park (Slough launch)',
  List<RouteWaypointGoNoGoFailure> waypointFailures = const [],
  List<GoNoGoReason> reasons = const [
    GoNoGoReason(
      code: GoNoGoReasonCode.windHigh,
      severity: GoNoGoReasonSeverity.noGo,
      windMph: 25,
      exposure: 'exposed',
    ),
  ],
}) {
  return RouteGoNoGoResult(
    verdict: verdict,
    computedAt: DateTime.parse('2026-06-15T12:00:00-07:00'),
    waypointResults: [
      RouteWaypointGoNoGoResult(
        orderIndex: 0,
        launchId: testCathedralParkLaunch.id,
        launchName: testCathedralParkLaunch.name,
        result: GoNoGoResult(
          verdict: GoNoGoVerdict.go,
          reasons: const [],
          computedAt: DateTime.parse('2026-06-15T12:00:00-07:00'),
        ),
      ),
      RouteWaypointGoNoGoResult(
        orderIndex: 1,
        launchId: testKelleyPointLaunch.id,
        launchName: testKelleyPointLaunch.name,
        result: GoNoGoResult(
          verdict: verdict,
          reasons: reasons,
          computedAt: DateTime.parse('2026-06-15T12:00:00-07:00'),
        ),
      ),
    ],
    waypointFailures: waypointFailures,
    triggeringReasons: reasons,
    triggeringWaypoint: RouteWaypointGoNoGoResult(
      orderIndex: 1,
      launchId: testKelleyPointLaunch.id,
      launchName: stopName,
      result: GoNoGoResult(
        verdict: verdict,
        reasons: reasons,
        computedAt: DateTime.parse('2026-06-15T12:00:00-07:00'),
      ),
    ),
  );
}

void main() {
  testWidgets('shows loading indicator while rollup loads', (tester) async {
    final repository = _MockConditionsRepository();
    final profileRepository = _MockGoNoGoProfileRepository();
    when(profileRepository.read).thenAnswer(
      (_) async => const Success(GoNoGoProfile.intermediate),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          conditionsRepositoryProvider.overrideWithValue(repository),
          goNoGoProfileRepositoryProvider.overrideWithValue(profileRepository),
        ],
        child: testLocalizedApp(
          child: const Scaffold(
            body: RouteGoNoGoSummarySection(
              launchIdsInOrder: ['cathedral_park', 'kelley_point'],
            ),
          ),
        ),
      ),
    );

    expect(find.bySemanticsLabel('Loading route conditions…'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('shows verdict and triggering stop when data loads', (
    tester,
  ) async {
    final launchIds = ['cathedral_park', 'kelley_point'];
    final waypointsKey = _waypointsKey(launchIds);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          routeGoNoGoRollupProvider(waypointsKey).overrideWith(
            (_) async => _rollupResult(verdict: GoNoGoVerdict.noGo),
          ),
        ],
        child: testLocalizedApp(
          child: Scaffold(
            body: RouteGoNoGoSummarySection(launchIdsInOrder: launchIds),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Poor conditions'), findsWidgets);
    expect(find.textContaining('Kelley Point'), findsOneWidget);
    expect(find.textContaining('25 mph'), findsOneWidget);
  });

  testWidgets('shows retry on error', (tester) async {
    final launchIds = ['cathedral_park', 'kelley_point'];
    final waypointsKey = _waypointsKey(launchIds);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          routeGoNoGoRollupProvider(waypointsKey).overrideWith(
            (_) async => throw const NetworkFailure(message: 'offline'),
          ),
        ],
        child: testLocalizedApp(
          child: Scaffold(
            body: RouteGoNoGoSummarySection(launchIdsInOrder: launchIds),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Route conditions could not be loaded.'),
      findsOneWidget,
    );
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('shows error card when all waypoint conditions fail', (
    tester,
  ) async {
    final launchIds = ['cathedral_park', 'kelley_point'];
    final waypointsKey = _waypointsKey(launchIds);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          routeGoNoGoRollupProvider(waypointsKey).overrideWith(
            (_) async => throw const UnexpectedFailure(
              message: 'No waypoint conditions available for route go/no-go.',
            ),
          ),
        ],
        child: testLocalizedApp(
          child: Scaffold(
            body: RouteGoNoGoSummarySection(launchIdsInOrder: launchIds),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Route conditions could not be loaded.'),
      findsOneWidget,
    );
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets(
    'shows partial failure banner when waypointFailures is non-empty',
    (
      tester,
    ) async {
      final launchIds = ['cathedral_park', 'kelley_point'];
      final waypointsKey = _waypointsKey(launchIds);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            routeGoNoGoRollupProvider(waypointsKey).overrideWith(
              (_) async => _rollupResult(
                verdict: GoNoGoVerdict.go,
                waypointFailures: const [
                  RouteWaypointGoNoGoFailure(
                    orderIndex: 1,
                    launchId: 'kelley_point',
                    launchName: 'Kelley Point Park (Slough launch)',
                    failure: NetworkFailure(message: 'network down'),
                  ),
                ],
              ),
            ),
          ],
          child: testLocalizedApp(
            child: Scaffold(
              body: RouteGoNoGoSummarySection(launchIdsInOrder: launchIds),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ExpansionTile));
      await tester.pumpAndSettle();

      expect(
        find.textContaining(
          'Conditions could not be loaded for this stop.',
        ),
        findsOneWidget,
      );
      expect(find.textContaining('network down'), findsNothing);
      expect(find.text('Some stops could not load conditions:'), findsNothing);
    },
  );

  testWidgets('shows per-stop verdict icon and summary when expanded', (
    tester,
  ) async {
    final launchIds = ['cathedral_park', 'kelley_point'];
    final waypointsKey = _waypointsKey(launchIds);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          routeGoNoGoRollupProvider(waypointsKey).overrideWith(
            (_) async => _rollupResult(
              verdict: GoNoGoVerdict.marginal,
              reasons: const [
                GoNoGoReason(
                  code: GoNoGoReasonCode.windElevated,
                  severity: GoNoGoReasonSeverity.marginal,
                  windMph: 18,
                  exposure: 'moderate',
                ),
              ],
            ),
          ),
        ],
        child: testLocalizedApp(
          child: Scaffold(
            body: RouteGoNoGoSummarySection(launchIdsInOrder: launchIds),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Worst at'), findsNothing);
    expect(find.textContaining('Moderate exposure site.'), findsWidgets);
    expect(find.textContaining('Effective wind speed 18 mph.'), findsWidgets);
    expect(
      find.textContaining('Conditions may feel rougher on the open water.'),
      findsWidgets,
    );
    expect(find.textContaining('exposure exposure'), findsNothing);

    await tester.tap(find.byType(ExpansionTile));
    await tester.pumpAndSettle();

    expect(find.text('No warnings'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
    expect(find.byIcon(Icons.warning_amber_outlined), findsWidgets);
  });

  testWidgets('localizes unknown launch failure in partial failure banner', (
    tester,
  ) async {
    final launchIds = ['cathedral_park', 'kelley_point'];
    final waypointsKey = _waypointsKey(launchIds);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          routeGoNoGoRollupProvider(waypointsKey).overrideWith(
            (_) async => _rollupResult(
              verdict: GoNoGoVerdict.go,
              waypointFailures: const [
                RouteWaypointGoNoGoFailure(
                  orderIndex: 1,
                  launchId: 'missing_launch',
                  launchName: 'missing_launch',
                  failure: NotFoundFailure(message: 'missing_launch'),
                ),
              ],
            ),
          ),
        ],
        child: testLocalizedApp(
          child: Scaffold(
            body: RouteGoNoGoSummarySection(launchIdsInOrder: launchIds),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byType(ExpansionTile));
    await tester.pumpAndSettle();

    expect(find.textContaining('Launch not found in catalog.'), findsOneWidget);
    expect(find.textContaining('Launch not found:'), findsNothing);
  });

  testWidgets('shows snap stops in expanded timeline with placeholder text', (
    tester,
  ) async {
    final launchIds = ['cathedral_park', 'kelley_point'];
    final waypointsKey = _waypointsKey(launchIds);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          routeGoNoGoRollupProvider(waypointsKey).overrideWith(
            (_) async => _rollupResult(verdict: GoNoGoVerdict.marginal),
          ),
        ],
        child: testLocalizedApp(
          child: Scaffold(
            body: RouteGoNoGoSummarySection(
              launchIdsInOrder: launchIds,
              catalogStopOrderIndices: const [0, 2],
              snapStops: const [
                RouteGoNoGoSnapStop(
                  orderIndex: 1,
                  label: 'Lunch spot',
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byType(ExpansionTile));
    await tester.pumpAndSettle();

    expect(find.text('Lunch spot'), findsOneWidget);
    expect(find.text('No conditions data available'), findsOneWidget);
  });

  testWidgets('shows snap-only route with unknown conditions header', (
    tester,
  ) async {
    await tester.pumpWidget(
      testLocalizedApp(
        child: const Scaffold(
          body: RouteGoNoGoSummarySection(
            launchIdsInOrder: [],
            snapStops: [
              RouteGoNoGoSnapStop(orderIndex: 0, label: 'Custom Stop 1'),
              RouteGoNoGoSnapStop(orderIndex: 1, label: 'Custom Stop 2'),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Unknown conditions'), findsOneWidget);

    await tester.tap(find.byType(ExpansionTile));
    await tester.pumpAndSettle();

    expect(find.text('Custom Stop 1'), findsOneWidget);
    expect(find.text('Custom Stop 2'), findsOneWidget);
    expect(find.text('No conditions data available'), findsNWidgets(2));
  });

  testWidgets('shows single catalog launch with snap stops in timeline', (
    tester,
  ) async {
    final launchIds = ['cathedral_park'];
    final waypointsKey = _waypointsKey(launchIds);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          routeGoNoGoRollupProvider(waypointsKey).overrideWith(
            (_) async => RouteGoNoGoResult(
              verdict: GoNoGoVerdict.go,
              computedAt: DateTime.parse('2026-06-15T12:00:00-07:00'),
              waypointResults: [
                RouteWaypointGoNoGoResult(
                  orderIndex: 0,
                  launchId: testCathedralParkLaunch.id,
                  launchName: testCathedralParkLaunch.name,
                  result: GoNoGoResult(
                    verdict: GoNoGoVerdict.go,
                    reasons: const [],
                    computedAt: DateTime.parse('2026-06-15T12:00:00-07:00'),
                  ),
                ),
              ],
              waypointFailures: const [],
              triggeringReasons: const [],
            ),
          ),
        ],
        child: testLocalizedApp(
          child: Scaffold(
            body: RouteGoNoGoSummarySection(
              launchIdsInOrder: launchIds,
              catalogStopOrderIndices: const [0],
              snapStops: const [
                RouteGoNoGoSnapStop(
                  orderIndex: 1,
                  label: 'Lunch spot',
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Favorable conditions'), findsWidgets);

    await tester.tap(find.byType(ExpansionTile));
    await tester.pumpAndSettle();

    expect(find.text(testCathedralParkLaunch.name), findsOneWidget);
    expect(find.text('Lunch spot'), findsOneWidget);
    expect(find.text('No conditions data available'), findsOneWidget);
  });
}
