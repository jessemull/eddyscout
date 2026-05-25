import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/firebase/conditions_callables.dart';
import '../data/firebase/conditions_summary_payload.dart';
import '../domain/conditions_models.dart';
import '../domain/go_no_go.dart';

/// Calls Firebase `summarizeConditions` for a launch snapshot.
class ConditionsAiSummaryRepository {
  const ConditionsAiSummaryRepository();

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

final Provider<ConditionsAiSummaryRepository>
conditionsAiSummaryRepositoryProvider = Provider<ConditionsAiSummaryRepository>(
  (ref) => const ConditionsAiSummaryRepository(),
);

/// UI state for the on-demand conditions AI summary card.
class ConditionsAiSummaryState {
  const ConditionsAiSummaryState({
    this.isLoading = false,
    this.summary,
    this.errorMessage,
  });

  final bool isLoading;
  final String? summary;
  final String? errorMessage;

  bool get isIdle => !isLoading && summary == null && errorMessage == null;
}

class ConditionsAiSummaryNotifier
    extends FamilyNotifier<ConditionsAiSummaryState, String> {
  @override
  ConditionsAiSummaryState build(String launchId) {
    return const ConditionsAiSummaryState();
  }

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
      state = ConditionsAiSummaryState(errorMessage: '$error');
    }
  }
}

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
