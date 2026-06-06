import 'package:dio/dio.dart';
import 'package:eddyscout_conditions/src/data/firebase/conditions_callables.dart';
import 'package:eddyscout_conditions/src/data/firebase/conditions_summary_payload.dart';
import 'package:eddyscout_conditions/src/domain/conditions_models.dart';
import 'package:eddyscout_conditions/src/domain/go_no_go.dart';
import 'package:eddyscout_conditions/src/domain/repositories/conditions_ai_summary_repository.dart';
import 'package:eddyscout_core/eddyscout_core.dart';

/// Firebase Callable implementation of [ConditionsAiSummaryRepository].
class ConditionsAiSummaryRepositoryImpl
    implements ConditionsAiSummaryRepository {
  /// Creates a stateless repository.
  const ConditionsAiSummaryRepositoryImpl();

  @override
  FutureResult<String, AppFailure> summarize({
    required LaunchPoint launch,
    required ConditionsSnapshot snapshot,
    required GoNoGoResult goNoGo,
    required GoNoGoProfile skillProfile,
    CancelToken? cancelToken,
  }) {
    final payload = conditionsSummaryPayload(
      launch: launch,
      snapshot: snapshot,
      goNoGo: goNoGo,
      skillProfile: skillProfile,
    );
    return callSummarizeConditions(payload, cancelToken: cancelToken);
  }
}
