import 'package:eddyscout_conditions/src/data/firebase/conditions_callables.dart';
import 'package:eddyscout_conditions/src/domain/condition_reports_refresh_token_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Firebase-backed condition report reads and AI digest calls.
class ConditionReportsRepository {
  /// Creates a stateless repository for Callable wrappers.
  const ConditionReportsRepository();

  /// Lists recent community reports for [launchId].
  Future<List<ConditionReportListItem>> listReports(String launchId) async {
    return callListConditionReports(launchId: launchId);
  }

  /// Summarizes recent reports into an on-demand digest.
  Future<LaunchReportsDigestResult> summarizeLaunchReports({
    required String launchId,
    bool forceRefresh = false,
  }) {
    return callSummarizeLaunchReports(
      launchId: launchId,
      forceRefresh: forceRefresh,
    );
  }
}

/// Injectable [ConditionReportsRepository] for tests and overrides.
final Provider<ConditionReportsRepository> conditionReportsRepositoryProvider =
    Provider<ConditionReportsRepository>(
      (ref) => const ConditionReportsRepository(),
    );

/// Recent paddler reports for a launch.
///
/// Refetches when [conditionReportsRefreshTokenProvider] changes.
final AutoDisposeFutureProviderFamily<List<ConditionReportListItem>, String>
conditionReportsListProvider = FutureProvider.autoDispose
    .family<List<ConditionReportListItem>, String>((ref, launchId) {
      ref.watch(conditionReportsRefreshTokenProvider);
      return ref.read(conditionReportsRepositoryProvider).listReports(launchId);
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
  @override
  LaunchReportsDigestState build(String launchId) {
    return const LaunchReportsDigestState();
  }

  /// Fetches or refreshes the community digest for this family's launch id.
  Future<void> summarize({bool forceRefresh = false}) async {
    state = const LaunchReportsDigestState(isLoading: true);
    try {
      final result = await ref
          .read(conditionReportsRepositoryProvider)
          .summarizeLaunchReports(launchId: arg, forceRefresh: forceRefresh);
      state = LaunchReportsDigestState(result: result);
    } on Object catch (_) {
      state = const LaunchReportsDigestState(
        errorMessage: 'Could not load digest. Try again.',
      );
    }
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
