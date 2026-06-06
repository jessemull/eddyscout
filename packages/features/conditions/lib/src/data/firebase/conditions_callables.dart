import 'dart:convert';

import 'package:cloud_functions/cloud_functions.dart' hide Result;
import 'package:dio/dio.dart';
import 'package:eddyscout_conditions/src/data/app_failure_mapper.dart';
import 'package:eddyscout_conditions/src/data/firebase/callable_cancel.dart';
import 'package:eddyscout_conditions/src/domain/condition_report_models.dart';
import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;

/// Test overrides for Callable unit tests (never set in production).
@visibleForTesting
class ConditionsCallablesTestHooks {
  ConditionsCallablesTestHooks._();

  /// Skips [FirebaseAuth] when set (tests only).
  @visibleForTesting
  static Future<void> Function()? ensureIdToken;

  /// Replaces [_functions] when set (tests only).
  @visibleForTesting
  static FirebaseFunctions? functions;

  /// Clears overrides between tests.
  @visibleForTesting
  static void reset() {
    ensureIdToken = null;
    functions = null;
  }
}

/// Default [Firebase] app and region (`us-west2`) for deployed Callables.
FirebaseFunctions get _functions =>
    ConditionsCallablesTestHooks.functions ??
    FirebaseFunctions.instanceFor(app: Firebase.app(), region: 'us-west2');

Map<String, dynamic> _jsonSafePayload(Map<String, Object?> payload) {
  return Map<String, dynamic>.from(
    jsonDecode(jsonEncode(payload)) as Map<String, dynamic>,
  );
}

/// Ensures a fresh ID token is attached to the next Callable request (avoids
/// `firebase_functions/unauthenticated` after restore / stale sessions).
Future<void> _ensureIdTokenForCallables() async {
  final override = ConditionsCallablesTestHooks.ensureIdToken;
  if (override != null) {
    return override();
  }
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    throw FirebaseAuthException(
      code: 'no-current-user',
      message: 'Not signed in; restart the app after enabling Firebase auth.',
    );
  }
  final token = await user.getIdToken(true);
  if (token == null || token.isEmpty) {
    throw FirebaseAuthException(
      code: 'no-id-token',
      message: 'getIdToken returned empty; sign out and sign in again.',
    );
  }
}

/// Android / emulators sometimes return [FirebaseFunctionsException] with code
/// `unauthenticated` on the first Callable right after sign-in; a short delay
/// plus a second token refresh usually succeeds. Also helps if Cloud Run IAM
/// briefly rejects before the client retries.
Future<T> _callWithAuthRetry<T>(
  Future<T> Function() invokeCallable, {
  CancelToken? cancelToken,
}) async {
  ensureCallableNotCancelled(cancelToken);
  await _ensureIdTokenForCallables();
  try {
    ensureCallableNotCancelled(cancelToken);
    return await invokeCallable();
  } on FirebaseFunctionsException catch (e) {
    if (e.code.toLowerCase() != 'unauthenticated') {
      rethrow;
    }
    ensureCallableNotCancelled(cancelToken);
    await Future<void>.delayed(const Duration(milliseconds: 400));
    ensureCallableNotCancelled(cancelToken);
    await _ensureIdTokenForCallables();
    return invokeCallable();
  }
}

FutureResult<T, AppFailure> _runCallable<T>(
  Future<T> Function() invoke, {
  CancelToken? cancelToken,
}) async {
  try {
    final value = await _callWithAuthRetry(invoke, cancelToken: cancelToken);
    return Result.success(value);
  } on Object catch (e, st) {
    return Result.failure(mapToAppFailure(e, st));
  }
}

/// Calls `summarizeConditions` with a JSON-safe map from
/// `conditionsSummaryPayload`.
FutureResult<String, AppFailure> callSummarizeConditions(
  Map<String, Object?> payload, {
  CancelToken? cancelToken,
}) {
  return _runCallable(() async {
    final callable = _functions.httpsCallable('summarizeConditions');
    final result = await callable.call<Map<String, dynamic>>(
      _jsonSafePayload(payload),
    );
    final data = Map<Object?, Object?>.from(result.data as Map);
    final text = data['summaryText'] ?? data['summary'];
    if (text is! String || text.isEmpty) {
      throw StateError('summarizeConditions: missing summaryText');
    }
    return text;
  }, cancelToken: cancelToken);
}

/// Calls `submitConditionReport`.
FutureResult<void, AppFailure> callSubmitConditionReport({
  required String launchId,
  required String message,
  String? clientConditionsFetchedAt,
  CancelToken? cancelToken,
}) {
  return _runCallable(() async {
    final callable = _functions.httpsCallable('submitConditionReport');
    await callable.call<Map<String, dynamic>>(
      _jsonSafePayload(<String, Object?>{
        'launchId': launchId,
        'message': message,
        'clientConditionsFetchedAt': clientConditionsFetchedAt,
      }),
    );
  }, cancelToken: cancelToken);
}

/// Calls `listConditionReports`.
FutureResult<List<ConditionReportListItem>, AppFailure>
callListConditionReports({
  required String launchId,
  int limit = 20,
  CancelToken? cancelToken,
}) {
  return _runCallable(() async {
    final callable = _functions.httpsCallable('listConditionReports');
    final result = await callable.call<Map<String, dynamic>>(
      _jsonSafePayload(<String, Object?>{'launchId': launchId, 'limit': limit}),
    );
    final data = Map<Object?, Object?>.from(result.data as Map);
    final raw = data['reports'];
    if (raw is! List) {
      throw StateError('listConditionReports: missing reports');
    }
    return raw
        .map(
          (e) => ConditionReportListItem.fromJson(
            Map<Object?, Object?>.from(e as Map),
          ),
        )
        .toList();
  }, cancelToken: cancelToken);
}

/// Calls `summarizeLaunchReports`.
FutureResult<LaunchReportsDigestResult, AppFailure> callSummarizeLaunchReports({
  required String launchId,
  bool forceRefresh = false,
  int reportLimit = 20,
  CancelToken? cancelToken,
}) {
  return _runCallable(() async {
    final callable = _functions.httpsCallable('summarizeLaunchReports');
    final result = await callable.call<Map<String, dynamic>>(
      _jsonSafePayload(<String, Object?>{
        'launchId': launchId,
        'forceRefresh': forceRefresh,
        'reportLimit': reportLimit,
      }),
    );
    final data = Map<Object?, Object?>.from(result.data as Map);
    return LaunchReportsDigestResult.fromJson(data);
  }, cancelToken: cancelToken);
}
