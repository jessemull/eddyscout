import 'dart:async';

import 'package:dio/dio.dart';
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
  late _MockConditionReportModerationRepository repo;

  setUp(() {
    repo = _MockConditionReportModerationRepository();
    registerFallbackValue(CancelToken());
    registerFallbackValue(const ModerationQueueQuery());
    registerFallbackValue(const ModerationHistoryQuery());
  });

  testWidgets('shows empty state when queue has no items', (tester) async {
    when(
      () => repo.listPendingReports(
        query: any(named: 'query'),
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
    when(
      () => repo.listPendingReports(
        query: any(named: 'query'),
        cancelToken: any(named: 'cancelToken'),
      ),
    ).thenAnswer(
      (_) async => Result.success([
        ModerationQueueReport(
          id: 'r1',
          launchId: 'sellwood',
          message: 'Needs review',
          createdAt: DateTime.utc(2026, 6, 15, 12),
          submitterUid: 'submitter-1',
          holdAgeDays: 3,
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
    expect(find.text('Waiting 3 days'), findsOneWidget);
    expect(find.textContaining('submitt'), findsOneWidget);
  });

  testWidgets('approve removes item without full-screen reload', (
    tester,
  ) async {
    when(
      () => repo.listPendingReports(
        query: any(named: 'query'),
        cancelToken: any(named: 'cancelToken'),
      ),
    ).thenAnswer(
      (_) async => Result.success([
        ModerationQueueReport(
          id: 'r1',
          launchId: 'sellwood',
          message: 'Needs review',
          createdAt: DateTime.utc(2026, 6, 15, 12),
          submitterUid: 'submitter-1',
        ),
        ModerationQueueReport(
          id: 'r2',
          launchId: 'cathedral_park',
          message: 'Also held',
          createdAt: DateTime.utc(2026, 6, 16, 12),
          submitterUid: 'submitter-2',
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
        query: any(named: 'query'),
        cancelToken: any(named: 'cancelToken'),
      ),
    ).called(1);
  });

  testWidgets('failed approve shows snackbar and keeps the item', (
    tester,
  ) async {
    when(
      () => repo.listPendingReports(
        query: any(named: 'query'),
        cancelToken: any(named: 'cancelToken'),
      ),
    ).thenAnswer(
      (_) async => Result.success([
        ModerationQueueReport(
          id: 'r1',
          launchId: 'sellwood',
          message: 'Needs review',
          createdAt: DateTime.utc(2026, 6, 15, 12),
          submitterUid: 'submitter-1',
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

  testWidgets('history tab shows audit metadata', (tester) async {
    when(
      () => repo.listPendingReports(
        query: any(named: 'query'),
        cancelToken: any(named: 'cancelToken'),
      ),
    ).thenAnswer((_) async => const Result.success([]));
    when(
      () => repo.listHistory(
        query: any(named: 'query'),
        cancelToken: any(named: 'cancelToken'),
      ),
    ).thenAnswer(
      (_) async => Result.success([
        ModerationHistoryReport(
          id: 'h1',
          launchId: 'sellwood',
          message: 'Reviewed note',
          createdAt: DateTime.utc(2026, 6, 15, 12),
          submitterUid: 'submitter-1',
          moderationStatus: ConditionReportModerationStatus.approved,
          moderationReason: 'admin_approve',
          reviewedAt: DateTime.utc(2026, 6, 16, 12),
          reviewedBy: 'moderator-uid-123456',
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

    await tester.tap(find.text('History'));
    await tester.pumpAndSettle();

    expect(find.text('Reviewed note'), findsOneWidget);
    expect(find.textContaining('admin_approve'), findsOneWidget);
    expect(find.textContaining('moderato'), findsOneWidget);
  });
}
