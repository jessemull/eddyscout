import 'package:dio/dio.dart';
import 'package:eddyscout_conditions/src/data/firebase/conditions_callables.dart';
import 'package:eddyscout_conditions/src/domain/condition_report_models.dart';
import 'package:eddyscout_conditions/src/domain/repositories/condition_report_submit_repository.dart';
import 'package:eddyscout_core/eddyscout_core.dart';

/// Firebase Callable implementation of [ConditionReportSubmitRepository].
class ConditionReportSubmitRepositoryImpl
    implements ConditionReportSubmitRepository {
  /// Creates a stateless repository.
  const ConditionReportSubmitRepositoryImpl();

  @override
  FutureResult<ConditionReportSubmitResult, AppFailure> submit({
    required String launchId,
    required String message,
    String? clientConditionsFetchedAt,
    CancelToken? cancelToken,
  }) {
    return callSubmitConditionReport(
      launchId: launchId,
      message: message,
      clientConditionsFetchedAt: clientConditionsFetchedAt,
      cancelToken: cancelToken,
    );
  }
}
