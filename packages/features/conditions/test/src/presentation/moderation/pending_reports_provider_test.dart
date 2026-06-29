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

  final reportA = ModerationQueueReport(
    id: 'a',
    launchId: 'sellwood',
    message: 'First',
    createdAt: DateTime.utc(2026, 6, 15),
    submitterUid: 'user-a',
  );
  final reportB = ModerationQueueReport(
    id: 'b',
    launchId: 'cathedral',
    message: 'Second',
    createdAt: DateTime.utc(2026, 6, 16),
    submitterUid: 'user-b',
  );

  setUp(() {
    repo = _MockConditionReportModerationRepository();
    registerFallbackValue(CancelToken());
    registerFallbackValue(const ModerationQueueQuery());
  });

  Future<ProviderContainer> pumpContainer() async {
    final container = ProviderContainer(
      overrides: [
        conditionReportModerationRepositoryProvider.overrideWithValue(repo),
      ],
    );
    addTearDown(container.dispose);
    await container.read(moderationPendingReportsProvider.future);
    return container;
  }

  test('moderate success removes item without refetching the queue', () async {
    when(
      () => repo.listPendingReports(
        query: any(named: 'query'),
        cancelToken: any(named: 'cancelToken'),
      ),
    ).thenAnswer((_) async => Result.success([reportA, reportB]));
    when(
      () => repo.moderateReport(
        reportId: any(named: 'reportId'),
        approve: any(named: 'approve'),
        cancelToken: any(named: 'cancelToken'),
      ),
    ).thenAnswer(
      (_) async =>
          const Result.success(ConditionReportModerationStatus.approved),
    );

    final container = await pumpContainer();
    clearInteractions(repo);

    final ok = await container
        .read(moderationPendingReportsProvider.notifier)
        .moderate(reportId: 'a', approve: true);

    expect(ok, isTrue);
    expect(
      container.read(moderationPendingReportsProvider).requireValue,
      [reportB],
    );
    verifyNever(
      () => repo.listPendingReports(
        query: any(named: 'query'),
        cancelToken: any(named: 'cancelToken'),
      ),
    );
    expect(container.read(conditionReportsRefreshTokenProvider), 1);
  });

  test('moderate failure rolls back optimistic removal', () async {
    when(
      () => repo.listPendingReports(
        query: any(named: 'query'),
        cancelToken: any(named: 'cancelToken'),
      ),
    ).thenAnswer((_) async => Result.success([reportA, reportB]));
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

    final container = await pumpContainer();

    final ok = await container
        .read(moderationPendingReportsProvider.notifier)
        .moderate(reportId: 'a', approve: false);

    expect(ok, isFalse);
    expect(
      container.read(moderationPendingReportsProvider).requireValue,
      [reportA, reportB],
    );
    expect(
      container.read(moderationPendingReportsProvider).hasError,
      isFalse,
    );
    expect(container.read(conditionReportsRefreshTokenProvider), 0);
  });

  test(
    'moderate removes item optimistically before callable completes',
    () async {
      when(
        () => repo.listPendingReports(
          query: any(named: 'query'),
          cancelToken: any(named: 'cancelToken'),
        ),
      ).thenAnswer((_) async => Result.success([reportA, reportB]));

      final completer =
          Completer<Result<ConditionReportModerationStatus, AppFailure>>();
      when(
        () => repo.moderateReport(
          reportId: any(named: 'reportId'),
          approve: any(named: 'approve'),
          cancelToken: any(named: 'cancelToken'),
        ),
      ).thenAnswer((_) => completer.future);

      final container = await pumpContainer();

      final moderateFuture = container
          .read(moderationPendingReportsProvider.notifier)
          .moderate(reportId: 'a', approve: true);

      expect(
        container.read(moderationPendingReportsProvider).requireValue,
        [reportB],
      );

      completer.complete(
        const Result.success(ConditionReportModerationStatus.approved),
      );
      expect(await moderateFuture, isTrue);
    },
  );

  test('refresh keeps previous data when reload fails', () async {
    when(
      () => repo.listPendingReports(
        query: any(named: 'query'),
        cancelToken: any(named: 'cancelToken'),
      ),
    ).thenAnswer((_) async => Result.success([reportA, reportB]));

    final container = await pumpContainer();

    when(
      () => repo.listPendingReports(
        query: any(named: 'query'),
        cancelToken: any(named: 'cancelToken'),
      ),
    ).thenAnswer(
      (_) async => const Result.failure(NetworkFailure(message: 'offline')),
    );

    await container.read(moderationPendingReportsProvider.notifier).refresh();

    expect(
      container.read(moderationPendingReportsProvider).requireValue,
      [reportA, reportB],
    );
  });

  test('moderateBatch returns empty result for empty selection', () async {
    final container = ProviderContainer(
      overrides: [
        conditionReportModerationRepositoryProvider.overrideWithValue(repo),
      ],
    );
    addTearDown(container.dispose);

    final result = await container
        .read(moderationPendingReportsProvider.notifier)
        .moderateBatch(reportIds: [], approve: true);

    expect(
      result,
      const ModerationBatchModerateResult(succeeded: [], failed: []),
    );
  });

  test(
    'moderateBatch restores failed ids and keeps successes removed',
    () async {
      when(
        () => repo.listPendingReports(
          query: any(named: 'query'),
          cancelToken: any(named: 'cancelToken'),
        ),
      ).thenAnswer((_) async => Result.success([reportA, reportB]));
      when(
        () => repo.moderateReportsBatch(
          reportIds: any(named: 'reportIds'),
          approve: any(named: 'approve'),
          cancelToken: any(named: 'cancelToken'),
        ),
      ).thenAnswer(
        (_) async => Result.success(
          ModerationBatchModerateResult(
            succeeded: ['a'],
            failed: [
              ModerationBatchFailure(reportId: 'b', code: 'already_reviewed'),
            ],
          ),
        ),
      );

      final container = await pumpContainer();
      final result = await container
          .read(moderationPendingReportsProvider.notifier)
          .moderateBatch(reportIds: ['a', 'b'], approve: true);

      expect(result?.succeeded, ['a']);
      expect(
        container.read(moderationPendingReportsProvider).requireValue,
        [reportB],
      );
      expect(container.read(conditionReportsRefreshTokenProvider), 1);
    },
  );
}
