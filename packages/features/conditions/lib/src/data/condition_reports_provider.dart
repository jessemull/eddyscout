import 'package:dio/dio.dart';
import 'package:eddyscout_conditions/src/data/repositories/condition_reports_repository_impl.dart';
import 'package:eddyscout_conditions/src/domain/condition_report_models.dart';
import 'package:eddyscout_conditions/src/domain/condition_reports_refresh_token_provider.dart';
import 'package:eddyscout_conditions/src/domain/repositories/condition_reports_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Injectable [ConditionReportsRepository] for tests and overrides.
final Provider<ConditionReportsRepository> conditionReportsRepositoryProvider =
    Provider<ConditionReportsRepository>(
      (ref) => const ConditionReportsRepositoryImpl(),
    );

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

/// Notifier for the launch reports digest card.
class LaunchReportsDigestNotifier
    extends FamilyNotifier<LaunchReportsDigestState, String> {
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
          launchId: arg,
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

/// Family notifier provider keyed by launch id.
final NotifierProviderFamily<
  LaunchReportsDigestNotifier,
  LaunchReportsDigestState,
  String
>
launchReportsDigestProvider =
    NotifierProvider.family<
      LaunchReportsDigestNotifier,
      LaunchReportsDigestState,
      String
    >(LaunchReportsDigestNotifier.new);
