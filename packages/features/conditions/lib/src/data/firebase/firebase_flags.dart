import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb, visibleForTesting;

/// Test overrides for Firebase availability checks (never set in production).
@visibleForTesting
class FirebaseFlagsTestHooks {
  FirebaseFlagsTestHooks._();

  /// When non-null, replaces [firebaseCallablesAvailable] (tests only).
  @visibleForTesting
  static bool? firebaseCallablesAvailableOverride;

  /// Clears overrides between tests.
  @visibleForTesting
  static void reset() {
    firebaseCallablesAvailableOverride = null;
  }
}

/// Compile-time gate for Firebase (Callables + anonymous auth).
///
/// Pass `--dart-define=USE_FIREBASE=true` with `google-services.json` /
/// `GoogleService-Info.plist` in place. Default false keeps `flutter test`
/// and builds without Firebase config working.
const bool kUseFirebase = bool.fromEnvironment(
  'USE_FIREBASE',
);

/// True when Callables are likely to succeed.
///
/// Requires Firebase initialized and a signed-in user.
bool get firebaseCallablesAvailable {
  final override = FirebaseFlagsTestHooks.firebaseCallablesAvailableOverride;
  if (override != null) {
    return override;
  }
  if (!kUseFirebase || kIsWeb) return false;
  try {
    return Firebase.apps.isNotEmpty &&
        FirebaseAuth.instance.currentUser != null;
  } on Exception catch (_) {
    return false;
  }
}
