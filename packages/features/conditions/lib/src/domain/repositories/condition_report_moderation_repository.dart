import 'package:dio/dio.dart';
import 'package:eddyscout_conditions/src/domain/condition_report_models.dart';
import 'package:eddyscout_core/eddyscout_core.dart';

/// Moderator queue and access (Firebase Callables).
abstract interface class ConditionReportModerationRepository {
  /// Whether the signed-in user may access the review queue.
  FutureResult<bool, AppFailure> checkModeratorAccess({
    CancelToken? cancelToken,
  });

  /// Lists reports awaiting moderator review.
  FutureResult<List<ModerationQueueReport>, AppFailure> listPendingReports({
    ModerationQueueQuery query = const ModerationQueueQuery(),
    CancelToken? cancelToken,
  });

  /// Lists moderated report history for audit.
  FutureResult<List<ModerationHistoryReport>, AppFailure> listHistory({
    ModerationHistoryQuery query = const ModerationHistoryQuery(),
    CancelToken? cancelToken,
  });

  /// Approves or rejects a held report.
  FutureResult<ConditionReportModerationStatus, AppFailure> moderateReport({
    required String reportId,
    required bool approve,
    CancelToken? cancelToken,
  });

  /// Approves or rejects multiple held reports.
  FutureResult<ModerationBatchModerateResult, AppFailure> moderateReportsBatch({
    required List<String> reportIds,
    required bool approve,
    CancelToken? cancelToken,
  });

  /// Returns an approved or rejected report to the pending queue.
  FutureResult<void, AppFailure> reopenReport({
    required String reportId,
    CancelToken? cancelToken,
  });
}
