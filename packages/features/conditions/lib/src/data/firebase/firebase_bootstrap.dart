import 'package:flutter/services.dart';

/// Known Firebase startup failure categories for localized UI hints.
enum FirebaseBootstrapHintKind {
  /// No extra hint for the current last error.
  none,

  /// Missing `google-services.json` / native Firebase options.
  missingNativeConfig,

  /// Anonymous sign-in disabled or restricted in Firebase Console.
  anonymousAuthDisabled,
}

/// Set from app startup when Firebase init runs.
///
/// Used for debug messaging on launch detail.
class FirebaseBootstrap {
  FirebaseBootstrap._();

  /// Whether Firebase initialization was attempted this session.
  static bool attempted = false;

  /// Last initialization error message, if any.
  static String? lastError;

  /// Records a startup failure without dumping full platform stack traces
  /// in the UI.
  static void recordInitError(Object error) {
    attempted = true;
    lastError = _formatInitError(error);
  }

  static String _formatInitError(Object error) {
    if (error is PlatformException) {
      final message = error.message?.trim();
      if (message != null && message.isNotEmpty) {
        return message;
      }
    }
    final firstLine = error.toString().split('\n').first.trim();
    return firstLine;
  }

  /// Hint category derived from [lastError] for presentation-layer l10n.
  static FirebaseBootstrapHintKind get hintKind {
    final e = lastError;
    if (e == null) {
      return FirebaseBootstrapHintKind.none;
    }
    if (e.contains('Failed to load FirebaseOptions') ||
        e.contains('values.xml') ||
        e.contains('google-services.json')) {
      return FirebaseBootstrapHintKind.missingNativeConfig;
    }
    if (e.contains('admin-restricted-operation') ||
        e.contains('operation-not-allowed')) {
      return FirebaseBootstrapHintKind.anonymousAuthDisabled;
    }
    return FirebaseBootstrapHintKind.none;
  }
}
