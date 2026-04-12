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

/// Calls `summarizeConditions` with a JSON-safe map from [conditionsSummaryPayload].
Future<String> callSummarizeConditions(Map<String, Object?> payload) async {
  await _ensureIdTokenForCallables();
  final callable = _functions.httpsCallable('summarizeConditions');
  final result = await callable.call(_jsonSafePayload(payload));
  final data = Map<Object?, Object?>.from(result.data as Map);
  final text = data['summaryText'] ?? data['summary'];
  if (text is! String || text.isEmpty) {
    throw StateError('summarizeConditions: missing summaryText');
  }
  return text;
}

/// Calls `submitConditionReport`.
Future<void> callSubmitConditionReport({
  required String launchId,
  required String message,
  String? clientConditionsFetchedAt,
}) async {
  await _ensureIdTokenForCallables();
  final callable = _functions.httpsCallable('submitConditionReport');
  await callable.call(
    _jsonSafePayload(<String, Object?>{
      'launchId': launchId,
      'message': message,
      'clientConditionsFetchedAt': clientConditionsFetchedAt,
    }),
  );
}
