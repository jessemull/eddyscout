import 'dart:convert';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

/// Same default app as [Firebase.initializeApp] + region from deployed functions.
FirebaseFunctions get _functions => FirebaseFunctions.instanceFor(
      app: Firebase.app(),
      region: 'us-west2',
    );

Map<String, dynamic> _jsonSafePayload(Map<String, Object?> payload) {
  return Map<String, dynamic>.from(
    jsonDecode(jsonEncode(payload)) as Map<String, dynamic>,
  );
}

/// Ensures a fresh ID token is attached to the next Callable request (avoids
/// `firebase_functions/unauthenticated` after restore / stale sessions).
Future<void> _ensureIdTokenForCallables() async {
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
    return await invokeCallable();
  }
}

/// Calls `summarizeConditions` with a JSON-safe map from [conditionsSummaryPayload].
Future<String> callSummarizeConditions(Map<String, Object?> payload) async {
  return _callWithAuthRetry(() async {
    final callable = _functions.httpsCallable('summarizeConditions');
    final result = await callable.call(_jsonSafePayload(payload));
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
    await callable.call(
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
  const ConditionReportListItem({
    required this.message,
    required this.createdAt,
    required this.isMine,
  });

  final String message;
  final DateTime createdAt;
  final bool isMine;

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
}

/// Calls `listConditionReports`.
Future<List<ConditionReportListItem>> callListConditionReports({
  required String launchId,
  int limit = 20,
}) async {
  return _callWithAuthRetry(() async {
    final callable = _functions.httpsCallable('listConditionReports');
    final result = await callable.call(
      _jsonSafePayload(<String, Object?>{
        'launchId': launchId,
        'limit': limit,
      }),
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
