import 'package:eddyscout_conditions/src/data/app_failure_mapper.dart';
import 'package:eddyscout_conditions/src/data/firebase/conditions_callables.dart';
import 'package:eddyscout_conditions/src/domain/condition_report_models.dart';
import 'package:eddyscout_conditions/src/domain/repositories/condition_reports_repository.dart';
import 'package:eddyscout_core/eddyscout_core.dart';

/// Firebase Callable implementation of [ConditionReportsRepository].
class ConditionReportsRepositoryImpl implements ConditionReportsRepository {
  /// Creates a stateless repository for Callable wrappers.
  const ConditionReportsRepositoryImpl();

  @override
  FutureResult<List<ConditionReportListItem>, AppFailure> listReports(
    String launchId,
  ) async {
    try {
      final list = await callListConditionReports(launchId: launchId);
      return Result.success(list);
    } on Object catch (e, st) {
      return Result.failure(mapToAppFailure(e, st));
    }
  }

  @override
  FutureResult<LaunchReportsDigestResult, AppFailure> summarizeLaunchReports({
    required String launchId,
    bool forceRefresh = false,
  }) async {
    try {
      final result = await callSummarizeLaunchReports(
        launchId: launchId,
        forceRefresh: forceRefresh,
      );
      return Result.success(result);
    } on Object catch (e, st) {
      return Result.failure(mapToAppFailure(e, st));
    }
  }
}
