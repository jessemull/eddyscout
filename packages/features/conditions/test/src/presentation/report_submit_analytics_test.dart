import 'package:eddyscout_analytics/eddyscout_analytics.dart';
import 'package:eddyscout_conditions/eddyscout_conditions.dart';
import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_persistence/eddyscout_persistence.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/test_launches.dart';
import '../../helpers/test_localized_app.dart';

class _MockConditionReportSubmitRepository extends Mock
    implements ConditionReportSubmitRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final launch = testCathedralParkLaunch;

  testWidgets('logs report_submit_success when report submits', (tester) async {
    FirebaseFlagsTestHooks.firebaseCallablesAvailableOverride = true;
    addTearDown(FirebaseFlagsTestHooks.reset);

    SharedPreferences.setMockInitialValues({});
    final store = await SharedPreferencesKeyValueStore.open();
    final analytics = RecordingAnalyticsClient();
    final submitRepo = _MockConditionReportSubmitRepository();
    when(
      () => submitRepo.submit(
        launchId: any(named: 'launchId'),
        message: any(named: 'message'),
        clientConditionsFetchedAt: any(named: 'clientConditionsFetchedAt'),
        cancelToken: any(named: 'cancelToken'),
      ),
    ).thenAnswer((_) async => const Result.success(null));

    final container = ProviderContainer(
      overrides: [
        goNoGoProfileRepositoryProvider.overrideWithValue(
          GoNoGoProfileRepositoryImpl(store),
        ),
        conditionsSnapshotProvider(launch).overrideWith(
          (ref) => Future.value(
            ConditionsSnapshot(fetchedAt: DateTime.utc(2026, 6, 15, 12)),
          ),
        ),
        conditionReportSubmitRepositoryProvider.overrideWithValue(submitRepo),
        analyticsClientProvider.overrideWithValue(analytics),
      ],
    );
    addTearDown(container.dispose);

    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, state) => UncontrolledProviderScope(
            container: container,
            child: testLocalizedApp(
              child: LaunchDetailScreen(launch: launch),
            ),
          ),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pump();
    await tester.pump();

    final reportTile = find.text('Report conditions');
    await tester.scrollUntilVisible(reportTile, 200);
    await tester.tap(reportTile);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Light chop on the water');
    await tester.tap(find.text('Submit'));
    await tester.pump();
    await tester.pump();

    expect(analytics.events, hasLength(1));
    expect(analytics.events.single.name, AnalyticsEvents.reportSubmitSuccess);
    expect(analytics.events.single.parameters['launch_id'], launch.id);
  });
}
