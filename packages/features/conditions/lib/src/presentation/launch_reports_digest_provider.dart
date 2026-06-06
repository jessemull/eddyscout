import 'package:dio/dio.dart';
import 'package:eddyscout_conditions/src/domain/condition_report_models.dart';
import 'package:eddyscout_conditions/src/domain/condition_reports_repository_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'launch_reports_digest_provider.g.dart';

/// UI state for the on-demand community digest card.
class LaunchReportsDigestState {
  /// Creates digest card state.
  const LaunchReportsDigestState({
    this.isLoading = false,
    this.result,
    this.errorMessage,
  });

  /// True while the Callable request is in flight.
  final bool isLoading;

  /// Last successful digest, if any.
  final LaunchReportsDigestResult? result;

  /// User-facing error when the request failed.
  final String? errorMessage;

  /// True before the user has requested a digest.
  bool get isIdle => !isLoading && result == null && errorMessage == null;
}

/// Deprecated alias for [LaunchReportsDigest] after `@riverpod` codegen
/// migration.
typedef LaunchReportsDigestNotifier = LaunchReportsDigest;

/// Notifier for the launch reports digest card.
///
/// Keep-alive preserves card state when navigating away from launch detail
/// and back within the same app session (matches pre-codegen behavior).
@Riverpod(keepAlive: true)
class LaunchReportsDigest extends _$LaunchReportsDigest {
  CancelToken? _activeCancelToken;

  @override
  LaunchReportsDigestState build(String launchId) {
    ref.onDispose(() {
      _activeCancelToken?.cancel('launchReportsDigestProvider disposed');
    });
    return const LaunchReportsDigestState();
  }

  /// Fetches or refreshes the community digest for this family's launch id.
  Future<void> summarize({bool forceRefresh = false}) async {
    _activeCancelToken?.cancel('superseded');
    final cancelToken = CancelToken();
    _activeCancelToken = cancelToken;

    state = const LaunchReportsDigestState(isLoading: true);
    final result = await ref
        .read(conditionReportsRepositoryProvider)
        .summarizeLaunchReports(
          launchId: launchId,
          forceRefresh: forceRefresh,
          cancelToken: cancelToken,
        );

    if (cancelToken.isCancelled) {
      return;
    }
    state = result.when(
      success: (value) => LaunchReportsDigestState(result: value),
      failure: (error) => LaunchReportsDigestState(errorMessage: error.message),
    );
  }
}
