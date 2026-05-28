import 'package:dio/dio.dart';
import 'package:eddyscout_conditions/src/domain/condition_report_models.dart';
import 'package:eddyscout_conditions/src/domain/condition_reports_refresh_token_provider.dart';
import 'package:eddyscout_conditions/src/domain/condition_reports_repository_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

export '../presentation/launch_reports_digest_provider.dart'
    show
        LaunchReportsDigestNotifier,
        LaunchReportsDigestState,
        launchReportsDigestProvider;

/// Recent paddler reports for a launch.
///
/// Refetches when [conditionReportsRefreshTokenProvider] changes.
final AutoDisposeFutureProviderFamily<List<ConditionReportListItem>, String>
conditionReportsListProvider = FutureProvider.autoDispose
    .family<List<ConditionReportListItem>, String>((ref, launchId) async {
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
    });
