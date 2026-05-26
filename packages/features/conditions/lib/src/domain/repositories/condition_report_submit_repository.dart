import 'package:dio/dio.dart';
import 'package:eddyscout_core/eddyscout_core.dart';

/// Submits a paddler condition report via Firebase Callable.
// ignore: one_member_abstracts -- repository port for tests and overrides
abstract interface class ConditionReportSubmitRepository {
  /// Posts [message] for [launchId].
  FutureResult<void, AppFailure> submit({
    required String launchId,
    required String message,
    String? clientConditionsFetchedAt,
    CancelToken? cancelToken,
  });
}
