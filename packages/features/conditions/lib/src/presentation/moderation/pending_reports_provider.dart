import 'package:dio/dio.dart';
import 'package:eddyscout_conditions/src/domain/condition_report_models.dart';
import 'package:eddyscout_conditions/src/domain/condition_report_moderation_repository_provider.dart';
import 'package:eddyscout_conditions/src/presentation/provider_result.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'pending_reports_provider.g.dart';

/// Held condition reports awaiting moderator action.
@riverpod
class ModerationPendingReports extends _$ModerationPendingReports {
  CancelToken? _cancelToken;

  @override
  Future<List<ModerationQueueReport>> build() async {
    ref.onDispose(() {
      _cancelToken?.cancel('moderationPendingReportsProvider disposed');
    });
    return _load();
  }

  Future<List<ModerationQueueReport>> _load() async {
    _cancelToken?.cancel('superseded');
    final cancelToken = CancelToken();
    _cancelToken = cancelToken;
    final result = await ref
        .read(conditionReportModerationRepositoryProvider)
        .listPendingReports(cancelToken: cancelToken);
    if (cancelToken.isCancelled) {
      throw StateError('cancelled');
    }
    return unwrapResultForAsyncProvider(result);
  }

  /// Reloads the moderation queue.
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  /// Approves or rejects [reportId] and reloads the queue.
  Future<bool> moderate({
    required String reportId,
    required bool approve,
  }) async {
    final cancelToken = CancelToken();
    final result = await ref
        .read(conditionReportModerationRepositoryProvider)
        .moderateReport(
          reportId: reportId,
          approve: approve,
          cancelToken: cancelToken,
        );
    if (cancelToken.isCancelled) {
      return false;
    }
    if (result.isFailure) {
      final error = result.errorOrNull!;
      state = AsyncError(error, error.stackTrace ?? StackTrace.current);
      return false;
    }
    await refresh();
    return true;
  }
}
