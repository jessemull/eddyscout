import '../data/firebase/conditions_callables.dart';
import 'condition_reports_refresh_token_provider.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Firebase-backed condition report reads and AI digest calls.
class ConditionReportsRepository {
  const ConditionReportsRepository();

  Future<List<ConditionReportListItem>> listReports(String launchId) async {
    // Wait until after the first frame so Callables pick up the Auth ID token
    // (avoids spurious unauthenticated on cold open).
    final binding = WidgetsBinding.instance;
    await binding.endOfFrame;
    return callListConditionReports(launchId: launchId);
  }

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

final conditionReportsRepositoryProvider = Provider<ConditionReportsRepository>(
  (ref) => const ConditionReportsRepository(),
);

/// Recent paddler reports for a launch; refetches when [conditionReportsRefreshTokenProvider] changes.
final conditionReportsListProvider = FutureProvider.autoDispose
    .family<List<ConditionReportListItem>, String>((ref, launchId) {
      ref.watch(conditionReportsRefreshTokenProvider);
      return ref.read(conditionReportsRepositoryProvider).listReports(launchId);
    });

/// UI state for the on-demand community digest card.
class LaunchReportsDigestState {
  const LaunchReportsDigestState({
    this.isLoading = false,
    this.result,
    this.errorMessage,
  });

  final bool isLoading;
  final LaunchReportsDigestResult? result;
  final String? errorMessage;

  bool get isIdle => !isLoading && result == null && errorMessage == null;
}

class LaunchReportsDigestNotifier
    extends FamilyNotifier<LaunchReportsDigestState, String> {
  @override
  LaunchReportsDigestState build(String launchId) {
    return const LaunchReportsDigestState();
  }

  Future<void> summarize({bool forceRefresh = false}) async {
    state = const LaunchReportsDigestState(isLoading: true);
    try {
      final result = await ref
          .read(conditionReportsRepositoryProvider)
          .summarizeLaunchReports(launchId: arg, forceRefresh: forceRefresh);
      state = LaunchReportsDigestState(result: result);
    } on Object catch (error) {
      state = LaunchReportsDigestState(errorMessage: '$error');
    }
  }
}

final launchReportsDigestProvider =
    NotifierProvider.family<
      LaunchReportsDigestNotifier,
      LaunchReportsDigestState,
      String
    >(LaunchReportsDigestNotifier.new);
