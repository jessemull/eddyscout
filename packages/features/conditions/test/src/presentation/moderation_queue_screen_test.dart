import 'dart:async';

import 'package:eddyscout_conditions/eddyscout_conditions.dart';
import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:flutter/material.dart';
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

  testWidgets('approve removes item without full-screen reload', (
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
        ModerationQueueReport(
          id: 'r2',
          launchId: 'cathedral',
          message: 'Also held',
          createdAt: DateTime.utc(2026, 6, 16, 12),
        ),
      ]),
    );

    final completer =
        Completer<Result<ConditionReportModerationStatus, AppFailure>>();
    when(
      () => repo.moderateReport(
        reportId: any(named: 'reportId'),
        approve: any(named: 'approve'),
        cancelToken: any(named: 'cancelToken'),
      ),
    ).thenAnswer((_) => completer.future);

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
    expect(find.text('Also held'), findsOneWidget);

    await tester.tap(find.text('Approve').first);
    await tester.pump();

    expect(find.text('Needs review'), findsNothing);
    expect(find.text('Also held'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsNothing);

    completer.complete(
      const Result.success(ConditionReportModerationStatus.approved),
    );
    await tester.pumpAndSettle();

    verify(
      () => repo.listPendingReports(
        limit: any(named: 'limit'),
        cancelToken: any(named: 'cancelToken'),
      ),
    ).called(1);
  });

  testWidgets('failed approve shows snackbar and keeps the item', (
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
    when(
      () => repo.moderateReport(
        reportId: any(named: 'reportId'),
        approve: any(named: 'approve'),
        cancelToken: any(named: 'cancelToken'),
      ),
    ).thenAnswer(
      (_) async =>
          const Result.failure(NetworkFailure(message: 'network down')),
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

    await tester.tap(find.text('Reject'));
    await tester.pumpAndSettle();

    expect(find.text('Needs review'), findsOneWidget);
    expect(
      find.text('Could not update that report. Try again.'),
      findsOneWidget,
    );
    expect(find.text('Could not load the review queue.'), findsNothing);
  });
}
