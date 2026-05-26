import 'package:dio/dio.dart';
import 'package:eddyscout_conditions/src/data/repositories/condition_report_submit_repository_impl.dart';
import 'package:eddyscout_conditions/src/domain/condition_reports_refresh_token_provider.dart';
import 'package:eddyscout_conditions/src/domain/repositories/condition_report_submit_repository.dart';
import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Arguments for [conditionReportSubmitProvider].
typedef ConditionReportSubmitArgs = ({
  String launchId,
  String? clientConditionsFetchedAt,
});

/// Injectable submit repository for tests and overrides.
final Provider<ConditionReportSubmitRepository>
conditionReportSubmitRepositoryProvider =
    Provider<ConditionReportSubmitRepository>(
      (ref) => const ConditionReportSubmitRepositoryImpl(),
    );

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
  CancelToken? _submitToken;

  @override
  Future<void> build(ConditionReportSubmitArgs args) async {
    ref.onDispose(() {
      _submitToken?.cancel('conditionReportSubmitProvider disposed');
    });
  }

  /// Posts [message] and bumps the reports refresh token on success.
  Future<bool> submit(String message) async {
    final trimmed = message.trim();
    if (trimmed.isEmpty) {
      return false;
    }

    _submitToken?.cancel('superseded');
    final cancelToken = CancelToken();
    _submitToken = cancelToken;

    state = const AsyncLoading();
    final result = await ref
        .read(conditionReportSubmitRepositoryProvider)
        .submit(
          launchId: arg.launchId,
          message: trimmed,
          clientConditionsFetchedAt: arg.clientConditionsFetchedAt,
          cancelToken: cancelToken,
        );

    if (cancelToken.isCancelled) {
      return false;
    }

    return result.when(
      success: (_) {
        ref.read(conditionReportsRefreshTokenProvider.notifier).increment();
        state = const AsyncData(null);
        return true;
      },
      failure: (error) {
        state = AsyncError(error, error.stackTrace ?? StackTrace.current);
        return false;
      },
    );
  }

  /// User-facing message when [state] is error.
  String? get errorMessage {
    final err = state.error;
    if (err == null) {
      return null;
    }
    if (err is AppFailure) {
      return err.message;
    }
    return err.toString();
  }
}
