import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Compile-time gate for Firebase (Callables + anonymous auth).
/// Pass `--dart-define=USE_FIREBASE=true` with `google-services.json` /
/// `GoogleService-Info.plist` in place. Default false keeps `flutter test`
/// and builds without Firebase config working.
const bool kUseFirebase = bool.fromEnvironment(
  'USE_FIREBASE',
  defaultValue: false,
);

/// True when Callables are likely to succeed ([main] initialized app + anonymous user).
bool get firebaseCallablesAvailable {
  if (!kUseFirebase || kIsWeb) return false;
  try {
    return Firebase.apps.isNotEmpty &&
        FirebaseAuth.instance.currentUser != null;
  } catch (_) {
    return false;
  }
}
