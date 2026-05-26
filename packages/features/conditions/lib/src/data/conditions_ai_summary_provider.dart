import 'package:eddyscout_conditions/src/data/firebase/conditions_callables.dart';
import 'package:eddyscout_conditions/src/data/firebase/conditions_summary_payload.dart';
import 'package:eddyscout_conditions/src/domain/conditions_models.dart';
import 'package:eddyscout_conditions/src/domain/go_no_go.dart';
import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Calls Firebase `summarizeConditions` for a launch snapshot.
class ConditionsAiSummaryRepository {
  /// Creates a stateless repository for Callable wrappers.
  const ConditionsAiSummaryRepository();

  /// Returns AI summary text for the given launch and conditions state.
  Future<String> summarize({
    required LaunchPoint launch,
    required ConditionsSnapshot snapshot,
    required GoNoGoResult goNoGo,
    required GoNoGoProfile skillProfile,
  }) {
    final payload = conditionsSummaryPayload(
      launch: launch,
      snapshot: snapshot,
      goNoGo: goNoGo,
      skillProfile: skillProfile,
    );
    return callSummarizeConditions(payload);
  }
}

/// Injectable [ConditionsAiSummaryRepository] for tests and overrides.
final Provider<ConditionsAiSummaryRepository>
conditionsAiSummaryRepositoryProvider = Provider<ConditionsAiSummaryRepository>(
  (ref) => const ConditionsAiSummaryRepository(),
);

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
class ConditionsAiSummaryNotifier
    extends FamilyNotifier<ConditionsAiSummaryState, String> {
  @override
  ConditionsAiSummaryState build(String launchId) {
    return const ConditionsAiSummaryState();
  }

  /// Fetches an AI summary for the current launch conditions.
  Future<void> summarize({
    required LaunchPoint launch,
    required ConditionsSnapshot snapshot,
    required GoNoGoResult goNoGo,
    required GoNoGoProfile skillProfile,
  }) async {
    state = const ConditionsAiSummaryState(isLoading: true);
    try {
      final summary = await ref
          .read(conditionsAiSummaryRepositoryProvider)
          .summarize(
            launch: launch,
            snapshot: snapshot,
            goNoGo: goNoGo,
            skillProfile: skillProfile,
          );
      state = ConditionsAiSummaryState(summary: summary);
    } on Object catch (error) {
      state = ConditionsAiSummaryState(
        errorMessage: error is AppFailure
            ? error.message
            : 'Could not load AI summary. Try again.',
      );
    }
  }
}

/// Family notifier provider keyed by launch id.
final NotifierProviderFamily<
  ConditionsAiSummaryNotifier,
  ConditionsAiSummaryState,
  String
>
conditionsAiSummaryProvider =
    NotifierProvider.family<
      ConditionsAiSummaryNotifier,
      ConditionsAiSummaryState,
      String
    >(ConditionsAiSummaryNotifier.new);
