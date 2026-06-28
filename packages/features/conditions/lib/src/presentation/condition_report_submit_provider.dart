import 'package:dio/dio.dart';
import 'package:eddyscout_conditions/src/domain/condition_report_models.dart';
import 'package:eddyscout_conditions/src/domain/condition_report_submit_repository_provider.dart';
import 'package:eddyscout_conditions/src/presentation/condition_reports_refresh_token_provider.dart';
import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'condition_report_submit_provider.g.dart';

/// Arguments for [conditionReportSubmitProvider].
typedef ConditionReportSubmitArgs = ({
  String launchId,
  String? clientConditionsFetchedAt,
});

/// Submits a paddler condition report via Firebase Callable.
@riverpod
class ConditionReportSubmit extends _$ConditionReportSubmit {
  CancelToken? _submitToken;

  @override
  FutureOr<void> build(ConditionReportSubmitArgs args) async {
    ref.onDispose(() {
      _submitToken?.cancel('conditionReportSubmitProvider disposed');
    });
  }

  /// Posts [message]; returns submit result or null on failure/cancel.
  Future<ConditionReportSubmitResult?> submit(String message) async {
    final trimmed = message.trim();
    if (trimmed.isEmpty) {
      return null;
    }

    _submitToken?.cancel('superseded');
    final cancelToken = CancelToken();
    _submitToken = cancelToken;

    state = const AsyncLoading();
    final result = await ref
        .read(conditionReportSubmitRepositoryProvider)
        .submit(
          launchId: args.launchId,
          message: trimmed,
          clientConditionsFetchedAt: args.clientConditionsFetchedAt,
          cancelToken: cancelToken,
        );

    if (cancelToken.isCancelled) {
      return null;
    }

    return result.when(
      success: (value) {
        if (value.isPubliclyVisible) {
          ref.read(conditionReportsRefreshTokenProvider.notifier).increment();
        }
        state = const AsyncData(null);
        return value;
      },
      failure: (error) {
        state = AsyncError(error, error.stackTrace ?? StackTrace.current);
        return null;
      },
    );
  }
}

/// User-facing message when [conditionReportSubmitProvider] is in error.
String? conditionReportSubmitErrorMessage(AsyncValue<void> state) {
  final err = state.error;
  if (err == null) {
    return null;
  }
  if (err is AppFailure) {
    return err.message;
  }
  return err.toString();
}
