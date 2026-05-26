import 'package:dio/dio.dart';
import 'package:eddyscout_conditions/src/domain/conditions_models.dart';
import 'package:eddyscout_conditions/src/domain/go_no_go.dart';
import 'package:eddyscout_core/eddyscout_core.dart';

/// AI summary of launch conditions via Firebase Callable.
// ignore: one_member_abstracts -- repository port for tests and overrides
abstract interface class ConditionsAiSummaryRepository {
  /// Returns summary text for [launch] and current [snapshot] / go-no-go state.
  FutureResult<String, AppFailure> summarize({
    required LaunchPoint launch,
    required ConditionsSnapshot snapshot,
    required GoNoGoResult goNoGo,
    required GoNoGoProfile skillProfile,
    CancelToken? cancelToken,
  });
}
