import 'package:eddyscout_conditions/src/domain/condition_report_models.dart';
import 'package:eddyscout_core/eddyscout_core.dart';

/// Community condition reports and AI digest (Firebase Callables).
abstract interface class ConditionReportsRepository {
  /// Lists recent paddler reports for [launchId].
  FutureResult<List<ConditionReportListItem>, AppFailure> listReports(
    String launchId,
  );

  /// Summarizes recent reports into an on-demand digest.
  FutureResult<LaunchReportsDigestResult, AppFailure> summarizeLaunchReports({
    required String launchId,
    bool forceRefresh = false,
  });
}
