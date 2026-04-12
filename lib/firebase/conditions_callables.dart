import 'dart:convert';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

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

void _logCallableContext(String phase) {
  if (!kDebugMode) return;
  final opts = Firebase.app().options;
  final uid = FirebaseAuth.instance.currentUser?.uid;
  debugPrint(
    '[Callable] $phase projectId=${opts.projectId} appId=${opts.appId} uid=$uid',
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
  if (kDebugMode) {
    final n = token.length;
    final head = n <= 16 ? token : '${token.substring(0, 16)}…';
    debugPrint('[Callable] idToken chars=$n prefix=$head');
  }
}

void _logFunctionsException(String name, FirebaseFunctionsException e) {
  if (!kDebugMode) return;
  debugPrint(
    '[Callable] $name failed code=${e.code} message=${e.message} '
    'details=${e.details}',
  );
}

/// Calls `summarizeConditions` with a JSON-safe map from [conditionsSummaryPayload].
Future<String> callSummarizeConditions(Map<String, Object?> payload) async {
  _logCallableContext('summarizeConditions start');
  await _ensureIdTokenForCallables();
  final callable = _functions.httpsCallable('summarizeConditions');
  final safe = _jsonSafePayload(payload);
  try {
    final result = await callable.call(safe);
    final data = Map<Object?, Object?>.from(result.data as Map);
    final text = data['summaryText'] ?? data['summary'];
    if (text is! String || text.isEmpty) {
      throw StateError('summarizeConditions: missing summaryText');
    }
    return text;
  } on FirebaseFunctionsException catch (e, st) {
    _logFunctionsException('summarizeConditions', e);
    debugPrint('$st');
    rethrow;
  }
}

/// Calls `submitConditionReport`.
Future<void> callSubmitConditionReport({
  required String launchId,
  required String message,
  String? clientConditionsFetchedAt,
}) async {
  _logCallableContext('submitConditionReport start');
  await _ensureIdTokenForCallables();
  final callable = _functions.httpsCallable('submitConditionReport');
  final safe = _jsonSafePayload(<String, Object?>{
    'launchId': launchId,
    'message': message,
    'clientConditionsFetchedAt': clientConditionsFetchedAt,
  });
  try {
    await callable.call(safe);
  } on FirebaseFunctionsException catch (e, st) {
    _logFunctionsException('submitConditionReport', e);
    debugPrint('$st');
    rethrow;
  }
}
