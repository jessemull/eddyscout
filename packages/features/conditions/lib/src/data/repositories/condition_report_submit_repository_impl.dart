import 'package:dio/dio.dart';
import 'package:eddyscout_conditions/src/data/app_failure_mapper.dart';
import 'package:eddyscout_conditions/src/data/firebase/conditions_callables.dart';
import 'package:eddyscout_conditions/src/domain/repositories/condition_report_submit_repository.dart';
import 'package:eddyscout_core/eddyscout_core.dart';

/// Firebase Callable implementation of [ConditionReportSubmitRepository].
class ConditionReportSubmitRepositoryImpl
    implements ConditionReportSubmitRepository {
  /// Creates a stateless repository.
  const ConditionReportSubmitRepositoryImpl();

  @override
  FutureResult<void, AppFailure> submit({
    required String launchId,
    required String message,
    String? clientConditionsFetchedAt,
    CancelToken? cancelToken,
  }) async {
    try {
      await callSubmitConditionReport(
        launchId: launchId,
        message: message,
        clientConditionsFetchedAt: clientConditionsFetchedAt,
        cancelToken: cancelToken,
      );
      return const Result.success(null);
    } on Object catch (e, st) {
      return Result.failure(mapToAppFailure(e, st));
    }
  }
}
