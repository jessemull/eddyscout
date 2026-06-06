import 'package:dio/dio.dart';
import 'package:eddyscout_conditions/src/data/repositories/conditions_ai_summary_repository_impl.dart';
import 'package:eddyscout_conditions/src/domain/conditions_models.dart';
import 'package:eddyscout_conditions/src/domain/go_no_go.dart';
import 'package:eddyscout_conditions/src/domain/repositories/conditions_ai_summary_repository.dart';
import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'conditions_ai_summary_provider.g.dart';

/// Injectable [ConditionsAiSummaryRepository] for tests and overrides.
@riverpod
ConditionsAiSummaryRepository conditionsAiSummaryRepository(Ref ref) {
  return const ConditionsAiSummaryRepositoryImpl();
}

/// UI state for the on-demand conditions AI summary card.
class ConditionsAiSummaryState {
  /// Creates summary card state.
  const ConditionsAiSummaryState({
    this.isLoading = false,
    this.summary,
    this.errorMessage,
  });

  /// True while the Callable request is in flight.
  final bool isLoading;

  /// Last successful summary text, if any.
  final String? summary;

  /// User-facing error when the request failed.
  final String? errorMessage;

  /// True before the user has requested a summary.
  bool get isIdle => !isLoading && summary == null && errorMessage == null;
}

/// Notifier for the conditions AI summary card.
@riverpod
class ConditionsAiSummary extends _$ConditionsAiSummary {
  CancelToken? _activeCancelToken;

  @override
  ConditionsAiSummaryState build(String launchId) {
    ref.onDispose(() {
      _activeCancelToken?.cancel('conditionsAiSummaryProvider disposed');
    });
    return const ConditionsAiSummaryState();
  }

  /// Fetches an AI summary for the current launch conditions.
  Future<void> summarize({
    required LaunchPoint launch,
    required ConditionsSnapshot snapshot,
    required GoNoGoResult goNoGo,
    required GoNoGoProfile skillProfile,
  }) async {
    _activeCancelToken?.cancel('superseded');
    final cancelToken = CancelToken();
    _activeCancelToken = cancelToken;

    state = const ConditionsAiSummaryState(isLoading: true);
    final result = await ref
        .read(conditionsAiSummaryRepositoryProvider)
        .summarize(
          launch: launch,
          snapshot: snapshot,
          goNoGo: goNoGo,
          skillProfile: skillProfile,
          cancelToken: cancelToken,
        );

    if (cancelToken.isCancelled) {
      return;
    }

    state = result.when(
      success: (summary) => ConditionsAiSummaryState(summary: summary),
      failure: (error) => ConditionsAiSummaryState(errorMessage: error.message),
    );
  }
}
