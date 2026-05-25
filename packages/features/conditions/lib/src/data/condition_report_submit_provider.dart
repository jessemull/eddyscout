import 'package:eddyscout_conditions/src/data/firebase/conditions_callables.dart';
import 'package:eddyscout_conditions/src/domain/condition_reports_refresh_token_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Arguments for [conditionReportSubmitProvider].
typedef ConditionReportSubmitArgs = ({
  String launchId,
  String? clientConditionsFetchedAt,
});

/// Submits a paddler condition report via Firebase Callable.
final AutoDisposeAsyncNotifierProviderFamily<
  ConditionReportSubmitNotifier,
  void,
  ConditionReportSubmitArgs
>
conditionReportSubmitProvider = AsyncNotifierProvider.autoDispose
    .family<ConditionReportSubmitNotifier, void, ConditionReportSubmitArgs>(
      ConditionReportSubmitNotifier.new,
    );

/// Firebase report submission; UI calls [submit] only.
class ConditionReportSubmitNotifier
    extends AutoDisposeFamilyAsyncNotifier<void, ConditionReportSubmitArgs> {
  @override
  Future<void> build(ConditionReportSubmitArgs args) async {}

  /// Posts [message] and bumps the reports refresh token on success.
  Future<bool> submit(String message) async {
    final trimmed = message.trim();
    if (trimmed.isEmpty) {
      return false;
    }
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await callSubmitConditionReport(
        launchId: arg.launchId,
        message: trimmed,
        clientConditionsFetchedAt: arg.clientConditionsFetchedAt,
      );
      ref.read(conditionReportsRefreshTokenProvider.notifier).state++;
    });
    return !state.hasError;
  }

  /// User-facing message when [state] is error.
  String? get errorMessage {
    final err = state.error;
    if (err == null) {
      return null;
    }
    return 'Could not submit report. Try again in a moment.';
  }
}
