import 'dart:convert';

import 'package:cloud_functions/cloud_functions.dart';
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
Future<T> _callWithAuthRetry<T>(Future<T> Function() invokeCallable) async {
  await _ensureIdTokenForCallables();
  try {
    return await invokeCallable();
  } on FirebaseFunctionsException catch (e) {
    if (e.code.toLowerCase() != 'unauthenticated') {
      rethrow;
    }
    await Future<void>.delayed(const Duration(milliseconds: 400));
    await _ensureIdTokenForCallables();
    return invokeCallable();
  }
}

/// Calls `summarizeConditions` with a JSON-safe map from
/// `conditionsSummaryPayload`.
Future<String> callSummarizeConditions(Map<String, Object?> payload) async {
  return _callWithAuthRetry(() async {
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
  });
}

/// Calls `submitConditionReport`.
Future<void> callSubmitConditionReport({
  required String launchId,
  required String message,
  String? clientConditionsFetchedAt,
}) async {
  await _callWithAuthRetry(() async {
    final callable = _functions.httpsCallable('submitConditionReport');
    await callable.call<Map<String, dynamic>>(
      _jsonSafePayload(<String, Object?>{
        'launchId': launchId,
        'message': message,
        'clientConditionsFetchedAt': clientConditionsFetchedAt,
      }),
    );
  });
}

/// One row from `listConditionReports` (no raw UIDs; [isMine] for UI only).
class ConditionReportListItem {
  /// Creates a parsed community report row.
  const ConditionReportListItem({
    required this.message,
    required this.createdAt,
    required this.isMine,
  });

  /// Parses a Callable JSON map into a list item.
  factory ConditionReportListItem.fromJson(Map<Object?, Object?> json) {
    final message = json['message'];
    final createdAt = json['createdAt'];
    final isMine = json['isMine'];
    if (message is! String || createdAt is! String || isMine is! bool) {
      throw const FormatException('ConditionReportListItem');
    }
    return ConditionReportListItem(
      message: message,
      createdAt: DateTime.parse(createdAt),
      isMine: isMine,
    );
  }

  /// Paddler-submitted note text.
  final String message;

  /// Server timestamp for sort order and staleness cues.
  final DateTime createdAt;

  /// Whether the current signed-in user authored this report.
  final bool isMine;
}

/// Calls `listConditionReports`.
Future<List<ConditionReportListItem>> callListConditionReports({
  required String launchId,
  int limit = 20,
}) async {
  return _callWithAuthRetry(() async {
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
  });
}

/// Result from `summarizeLaunchReports`.
class LaunchReportsDigestResult {
  /// Creates a digest response from Callable JSON.
  const LaunchReportsDigestResult({
    required this.digestText,
    required this.cached,
    required this.noReports,
  });

  /// Parses a Callable JSON map into a digest result.
  factory LaunchReportsDigestResult.fromJson(Map<Object?, Object?> json) {
    final digestText = json['digestText'];
    final cached = json['cached'];
    final noReports = json['noReports'];
    if (digestText is! String || cached is! bool) {
      throw const FormatException('LaunchReportsDigestResult');
    }
    return LaunchReportsDigestResult(
      digestText: digestText,
      cached: cached,
      noReports: noReports is bool && noReports,
    );
  }

  /// AI-generated summary of recent community reports.
  final String digestText;

  /// Whether the server returned a cached digest.
  final bool cached;

  /// True when there were no reports to summarize.
  final bool noReports;
}

/// Calls `summarizeLaunchReports`.
Future<LaunchReportsDigestResult> callSummarizeLaunchReports({
  required String launchId,
  bool forceRefresh = false,
  int reportLimit = 20,
}) async {
  return _callWithAuthRetry(() async {
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
  });
}
