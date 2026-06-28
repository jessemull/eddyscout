import 'package:dio/dio.dart';
import 'package:eddyscout_conditions/src/data/firebase/conditions_callables.dart';
import 'package:eddyscout_conditions/src/domain/condition_report_models.dart';
import 'package:eddyscout_conditions/src/domain/repositories/condition_report_moderation_repository.dart';
import 'package:eddyscout_core/eddyscout_core.dart';

/// Firebase Callable implementation of [ConditionReportModerationRepository].
class ConditionReportModerationRepositoryImpl
    implements ConditionReportModerationRepository {
  /// Creates a stateless repository for Callable wrappers.
  const ConditionReportModerationRepositoryImpl();

  @override
  FutureResult<bool, AppFailure> checkModeratorAccess({
    CancelToken? cancelToken,
  }) {
    return callCheckModeratorAccess(cancelToken: cancelToken);
  }

  @override
  FutureResult<List<ModerationQueueReport>, AppFailure> listPendingReports({
    int limit = 25,
    CancelToken? cancelToken,
  }) {
    return callListPendingConditionReports(
      limit: limit,
      cancelToken: cancelToken,
    );
  }

  @override
  FutureResult<ConditionReportModerationStatus, AppFailure> moderateReport({
    required String reportId,
    required bool approve,
    CancelToken? cancelToken,
  }) {
    return callModerateConditionReport(
      reportId: reportId,
      approve: approve,
      cancelToken: cancelToken,
    );
  }
}
