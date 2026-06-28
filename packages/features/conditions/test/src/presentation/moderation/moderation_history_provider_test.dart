import 'dart:async';

import 'package:dio/dio.dart';
import 'package:eddyscout_conditions/eddyscout_conditions.dart';
import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockConditionReportModerationRepository extends Mock
    implements ConditionReportModerationRepository {}

void main() {
  late _MockConditionReportModerationRepository repo;

  final historyA = ModerationHistoryReport(
    id: 'a',
    launchId: 'sellwood',
    message: 'First',
    createdAt: DateTime.utc(2026, 6, 15),
    submitterUid: 'user-a',
    moderationStatus: ConditionReportModerationStatus.approved,
    moderationReason: 'admin_approve',
    reviewedAt: DateTime.utc(2026, 6, 16),
    reviewedBy: 'mod-a',
  );
  final historyB = ModerationHistoryReport(
    id: 'b',
    launchId: 'cathedral',
    message: 'Second',
    createdAt: DateTime.utc(2026, 6, 14),
    submitterUid: 'user-b',
    moderationStatus: ConditionReportModerationStatus.rejected,
    moderationReason: 'admin_reject',
    reviewedAt: DateTime.utc(2026, 6, 17),
    reviewedBy: 'mod-b',
  );

  setUp(() {
    repo = _MockConditionReportModerationRepository();
    registerFallbackValue(CancelToken());
    registerFallbackValue(const ModerationHistoryQuery());
  });

  Future<ProviderContainer> pumpContainer() async {
    final container = ProviderContainer(
      overrides: [
        conditionReportModerationRepositoryProvider.overrideWithValue(repo),
      ],
    );
    addTearDown(container.dispose);
    await container.read(moderationHistoryProvider.future);
    return container;
  }

  test('reopen success removes item without refetching history', () async {
    when(
      () => repo.listHistory(
        query: any(named: 'query'),
        cancelToken: any(named: 'cancelToken'),
      ),
    ).thenAnswer((_) async => Result.success([historyA, historyB]));
    when(
      () => repo.reopenReport(
        reportId: any(named: 'reportId'),
        cancelToken: any(named: 'cancelToken'),
      ),
    ).thenAnswer((_) async => const Result.success(null));

    final container = await pumpContainer();
    clearInteractions(repo);

    final ok = await container
        .read(moderationHistoryProvider.notifier)
        .reopen(reportId: 'a');

    expect(ok, isTrue);
    expect(
      container.read(moderationHistoryProvider).requireValue,
      [historyB],
    );
    verifyNever(
      () => repo.listHistory(
        query: any(named: 'query'),
        cancelToken: any(named: 'cancelToken'),
      ),
    );
    expect(container.read(conditionReportsRefreshTokenProvider), 1);
  });

  test('reopen failure rolls back optimistic removal', () async {
    when(
      () => repo.listHistory(
        query: any(named: 'query'),
        cancelToken: any(named: 'cancelToken'),
      ),
    ).thenAnswer((_) async => Result.success([historyA, historyB]));
    when(
      () => repo.reopenReport(
        reportId: any(named: 'reportId'),
        cancelToken: any(named: 'cancelToken'),
      ),
    ).thenAnswer(
      (_) async =>
          const Result.failure(NetworkFailure(message: 'network down')),
    );

    final container = await pumpContainer();

    final ok = await container
        .read(moderationHistoryProvider.notifier)
        .reopen(reportId: 'a');

    expect(ok, isFalse);
    expect(
      container.read(moderationHistoryProvider).requireValue,
      [historyA, historyB],
    );
    expect(container.read(moderationHistoryProvider).hasError, isFalse);
    expect(container.read(conditionReportsRefreshTokenProvider), 0);
  });

  test(
    'reopen removes item optimistically before callable completes',
    () async {
      when(
        () => repo.listHistory(
          query: any(named: 'query'),
          cancelToken: any(named: 'cancelToken'),
        ),
      ).thenAnswer((_) async => Result.success([historyA, historyB]));

      final completer = Completer<Result<void, AppFailure>>();
      when(
        () => repo.reopenReport(
          reportId: any(named: 'reportId'),
          cancelToken: any(named: 'cancelToken'),
        ),
      ).thenAnswer((_) => completer.future);

      final container = await pumpContainer();

      final reopenFuture = container
          .read(moderationHistoryProvider.notifier)
          .reopen(reportId: 'a');

      expect(
        container.read(moderationHistoryProvider).requireValue,
        [historyB],
      );

      completer.complete(const Result.success(null));
      expect(await reopenFuture, isTrue);
    },
  );
}
