import 'package:eddyscout_conditions/eddyscout_conditions.dart';
import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/test_localized_app.dart';

class _MockConditionReportModerationRepository extends Mock
    implements ConditionReportModerationRepository {}

void main() {
  testWidgets('shows empty state when queue has no items', (tester) async {
    final repo = _MockConditionReportModerationRepository();
    when(
      () => repo.listPendingReports(
        limit: any(named: 'limit'),
        cancelToken: any(named: 'cancelToken'),
      ),
    ).thenAnswer((_) async => const Result.success([]));

    await tester.pumpWidget(
      testLocalizedApp(
        child: ProviderScope(
          overrides: [
            conditionReportModerationRepositoryProvider.overrideWithValue(repo),
          ],
          child: const ModerationQueueScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No reports waiting for review.'), findsOneWidget);
  });

  testWidgets('shows pending row with approve and reject actions', (
    tester,
  ) async {
    final repo = _MockConditionReportModerationRepository();
    when(
      () => repo.listPendingReports(
        limit: any(named: 'limit'),
        cancelToken: any(named: 'cancelToken'),
      ),
    ).thenAnswer(
      (_) async => Result.success([
        ModerationQueueReport(
          id: 'r1',
          launchId: 'sellwood',
          message: 'Needs review',
          createdAt: DateTime.utc(2026, 6, 15, 12),
        ),
      ]),
    );

    await tester.pumpWidget(
      testLocalizedApp(
        child: ProviderScope(
          overrides: [
            conditionReportModerationRepositoryProvider.overrideWithValue(repo),
          ],
          child: const ModerationQueueScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Needs review'), findsOneWidget);
    expect(find.text('Approve'), findsOneWidget);
    expect(find.text('Reject'), findsOneWidget);
  });
}
