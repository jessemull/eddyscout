import 'package:dio/dio.dart';
import 'package:eddyscout_conditions/src/domain/condition_report_models.dart';
import 'package:eddyscout_conditions/src/domain/condition_reports_refresh_token_provider.dart';
import 'package:eddyscout_conditions/src/domain/condition_reports_repository_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

export '../presentation/launch_reports_digest_provider.dart'
    show
        LaunchReportsDigest,
        LaunchReportsDigestState,
        launchReportsDigestProvider;

part 'condition_reports_provider.g.dart';

Duration? _disableProviderRetry(int retryCount, Object error) => null;

/// Recent paddler reports for a launch.
///
/// Refetches when [conditionReportsRefreshTokenProvider] changes.
@Riverpod(retry: _disableProviderRetry)
Future<List<ConditionReportListItem>> conditionReportsList(
  Ref ref,
  String launchId,
) async {
  ref.watch(conditionReportsRefreshTokenProvider);
  final cancelToken = CancelToken();
  ref.onDispose(() {
    if (!cancelToken.isCancelled) {
      cancelToken.cancel('conditionReportsListProvider disposed');
    }
  });
  final result = await ref
      .read(conditionReportsRepositoryProvider)
      .listReports(launchId, cancelToken: cancelToken);
  return result.when(
    success: (value) => value,
    failure: (error) => throw Exception(error.message),
  );
}
