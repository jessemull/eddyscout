import 'package:dio/dio.dart';
import 'package:eddyscout_conditions/src/domain/condition_report_models.dart';
import 'package:eddyscout_conditions/src/domain/condition_report_moderation_repository_provider.dart';
import 'package:eddyscout_conditions/src/presentation/condition_reports_refresh_token_provider.dart';
import 'package:eddyscout_conditions/src/presentation/moderation/moderation_history_provider.dart';
import 'package:eddyscout_conditions/src/presentation/moderation/moderation_queue_filters_provider.dart';
import 'package:eddyscout_conditions/src/presentation/provider_result.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'pending_reports_provider.g.dart';

/// Held condition reports awaiting moderator action.
@riverpod
class ModerationPendingReports extends _$ModerationPendingReports {
  CancelToken? _cancelToken;

  @override
  Future<List<ModerationQueueReport>> build() async {
    ref
      ..watch(moderationPendingFiltersProvider)
      ..onDispose(() {
        _cancelToken?.cancel('moderationPendingReportsProvider disposed');
      });
    return _load();
  }

  Future<List<ModerationQueueReport>> _load() async {
    _cancelToken?.cancel('superseded');
    final cancelToken = CancelToken();
    _cancelToken = cancelToken;
    final filters = ref.read(moderationPendingFiltersProvider);
    final launchId = resolveLaunchIdFilter(filters.launchQuery);
    final result = await ref
        .read(conditionReportModerationRepositoryProvider)
        .listPendingReports(
          query: ModerationQueueQuery(
            limit: filters.limit,
            launchId: launchId,
            createdAfter: submittedAfterForFilter(filters.submittedDateFilter),
            sort: filters.sort,
          ),
          cancelToken: cancelToken,
        );
    if (cancelToken.isCancelled) {
      throw StateError('cancelled');
    }
    final rows = unwrapResultForAsyncProvider(result);
    return filterPendingReportsClientSide(
      reports: rows,
      launchQuery: launchId == null ? filters.launchQuery : '',
    );
  }

  /// Reloads the moderation queue (pull-to-refresh / retry).
  ///
  /// Keeps the current list visible while refetching.
  Future<void> refresh() async {
    final previous = state.asData?.value;
    try {
      state = AsyncData(await _load());
    } on Object catch (error, stackTrace) {
      if (previous != null) {
        state = AsyncData(previous);
      } else {
        state = AsyncError(error, stackTrace);
      }
    }
  }

  /// Approves or rejects [reportId] with an optimistic queue update.
  Future<bool> moderate({
    required String reportId,
    required bool approve,
  }) async {
    final previous = state.asData?.value;
    if (previous == null) {
      return false;
    }

    final optimistic = previous
        .where((report) => report.id != reportId)
        .toList(growable: false);
    state = AsyncData(optimistic);

    final cancelToken = CancelToken();
    final result = await ref
        .read(conditionReportModerationRepositoryProvider)
        .moderateReport(
          reportId: reportId,
          approve: approve,
          cancelToken: cancelToken,
        );
    if (cancelToken.isCancelled) {
      state = AsyncData(previous);
      return false;
    }
    if (result.isFailure) {
      state = AsyncData(previous);
      return false;
    }

    ref
      ..read(conditionReportsRefreshTokenProvider.notifier).increment()
      ..invalidate(moderationHistoryProvider);
    return true;
  }

  /// Approves or rejects multiple reports with optimistic removal.
  Future<ModerationBatchModerateResult?> moderateBatch({
    required List<String> reportIds,
    required bool approve,
  }) async {
    if (reportIds.isEmpty) {
      return const ModerationBatchModerateResult(succeeded: [], failed: []);
    }

    final previous = state.asData?.value;
    if (previous == null) {
      return null;
    }

    final selected = reportIds.toSet();
    final optimistic = previous
        .where((report) => !selected.contains(report.id))
        .toList(growable: false);
    state = AsyncData(optimistic);

    final cancelToken = CancelToken();
    final result = await ref
        .read(conditionReportModerationRepositoryProvider)
        .moderateReportsBatch(
          reportIds: reportIds,
          approve: approve,
          cancelToken: cancelToken,
        );
    if (cancelToken.isCancelled) {
      state = AsyncData(previous);
      return null;
    }
    if (result.isFailure) {
      state = AsyncData(previous);
      return null;
    }

    final batchResult = result.valueOrNull;
    if (batchResult == null) {
      state = AsyncData(previous);
      return null;
    }

    if (batchResult.failed.isNotEmpty) {
      final failedIds = batchResult.failed.map((e) => e.reportId).toSet();
      final sort = ref.read(moderationPendingFiltersProvider).sort;
      final restored =
          [
            ...optimistic,
            ...previous.where((report) => failedIds.contains(report.id)),
          ]..sort(
            (a, b) => switch (sort) {
              ModerationQueueSort.createdAtAsc => a.createdAt.compareTo(
                b.createdAt,
              ),
              ModerationQueueSort.createdAtDesc => b.createdAt.compareTo(
                a.createdAt,
              ),
            },
          );
      state = AsyncData(restored);
    }

    if (batchResult.succeeded.isNotEmpty) {
      ref
        ..read(conditionReportsRefreshTokenProvider.notifier).increment()
        ..invalidate(moderationHistoryProvider);
    }

    return batchResult;
  }
}
