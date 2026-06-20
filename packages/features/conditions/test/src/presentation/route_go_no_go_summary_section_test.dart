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

RouteGoNoGoResult _rollupResult({
  GoNoGoVerdict verdict = GoNoGoVerdict.marginal,
  String stopName = 'Kelley Point Park (Slough launch)',
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
          reasons: const [
            GoNoGoReason(
              code: GoNoGoReasonCode.windHigh,
              severity: GoNoGoReasonSeverity.noGo,
              windMph: 25,
              exposure: 'exposed',
            ),
          ],
          computedAt: DateTime.parse('2026-06-15T12:00:00-07:00'),
        ),
      ),
    ],
    waypointFailures: const [],
    triggeringReasons: const [
      GoNoGoReason(
        code: GoNoGoReasonCode.windHigh,
        severity: GoNoGoReasonSeverity.noGo,
        windMph: 25,
        exposure: 'exposed',
      ),
    ],
    triggeringWaypoint: RouteWaypointGoNoGoResult(
      orderIndex: 1,
      launchId: testKelleyPointLaunch.id,
      launchName: stopName,
      result: GoNoGoResult(
        verdict: verdict,
        reasons: const [
          GoNoGoReason(
            code: GoNoGoReasonCode.windHigh,
            severity: GoNoGoReasonSeverity.noGo,
            windMph: 25,
            exposure: 'exposed',
          ),
        ],
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

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows verdict and triggering stop when data loads', (
    tester,
  ) async {
    final launchIds = ['cathedral_park', 'kelley_point'];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          routeGoNoGoRollupProvider(launchIds).overrideWith(
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

    expect(find.textContaining('No-go'), findsWidgets);
    expect(find.textContaining('Kelley Point'), findsOneWidget);
    expect(find.textContaining('25 mph'), findsOneWidget);
  });

  testWidgets('shows retry on error', (tester) async {
    final launchIds = ['cathedral_park', 'kelley_point'];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          routeGoNoGoRollupProvider(launchIds).overrideWith(
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

    expect(find.text('offline'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });
}
