import 'package:dio/dio.dart';
import 'package:eddyscout_conditions/src/data/firebase/conditions_callables.dart';
import 'package:eddyscout_conditions/src/domain/condition_report_models.dart';
import 'package:eddyscout_conditions/src/domain/repositories/condition_reports_repository.dart';
import 'package:eddyscout_core/eddyscout_core.dart';

/// Firebase Callable implementation of [ConditionReportsRepository].
class ConditionReportsRepositoryImpl implements ConditionReportsRepository {
  /// Creates a stateless repository for Callable wrappers.
  const ConditionReportsRepositoryImpl();

  @override
  FutureResult<ConditionReportsListResult, AppFailure> listReports(
    String launchId, {
    CancelToken? cancelToken,
  }) {
    return callListConditionReports(
      launchId: launchId,
      cancelToken: cancelToken,
    );
  }

  @override
  FutureResult<LaunchReportsDigestResult, AppFailure> summarizeLaunchReports({
    required String launchId,
    bool forceRefresh = false,
    CancelToken? cancelToken,
  }) {
    return callSummarizeLaunchReports(
      launchId: launchId,
      forceRefresh: forceRefresh,
      cancelToken: cancelToken,
    );
  }
}
