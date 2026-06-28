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
    int limit = 25,
    CancelToken? cancelToken,
  });

  /// Approves or rejects a held report.
  FutureResult<ConditionReportModerationStatus, AppFailure> moderateReport({
    required String reportId,
    required bool approve,
    CancelToken? cancelToken,
  });
}
