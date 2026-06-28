import 'package:dio/dio.dart';
import 'package:eddyscout_conditions/src/domain/condition_report_models.dart';
import 'package:eddyscout_conditions/src/domain/condition_report_moderation_repository_provider.dart';
import 'package:eddyscout_conditions/src/presentation/moderation/moderation_queue_filters_provider.dart';
import 'package:eddyscout_conditions/src/presentation/provider_result.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'moderation_history_provider.g.dart';

/// Moderation audit history rows.
@riverpod
class ModerationHistory extends _$ModerationHistory {
  CancelToken? _cancelToken;

  @override
  Future<List<ModerationHistoryReport>> build() async {
    ref
      ..watch(moderationHistoryFiltersProvider)
      ..onDispose(() {
        _cancelToken?.cancel('moderationHistoryProvider disposed');
      });
    return _load();
  }

  Future<List<ModerationHistoryReport>> _load() async {
    _cancelToken?.cancel('superseded');
    final cancelToken = CancelToken();
    _cancelToken = cancelToken;
    final filters = ref.read(moderationHistoryFiltersProvider);
    final launchId = resolveLaunchIdFilter(filters.launchQuery);
    final result = await ref
        .read(conditionReportModerationRepositoryProvider)
        .listHistory(
          query: ModerationHistoryQuery(
            limit: filters.limit,
            launchId: launchId,
            status: filters.status,
            reviewedAfter: reviewedAfterForFilter(filters.reviewedDateFilter),
            sort: filters.sort,
          ),
          cancelToken: cancelToken,
        );
    if (cancelToken.isCancelled) {
      throw StateError('cancelled');
    }
    final rows = unwrapResultForAsyncProvider(result);
    return filterHistoryReportsClientSide(
      reports: rows,
      launchQuery: launchId == null ? filters.launchQuery : '',
    );
  }

  /// Reloads history (pull-to-refresh / retry).
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
}
