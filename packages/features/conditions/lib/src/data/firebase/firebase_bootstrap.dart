import 'package:flutter/services.dart';

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

  /// Extra guidance when [lastError] matches a known Firebase Auth code.
  static String? hintForLastError() {
    final e = lastError;
    if (e == null) return null;
    if (e.contains('Failed to load FirebaseOptions') ||
        e.contains('values.xml') ||
        e.contains('google-services.json')) {
      return 'Add apps/eddyscout/android/app/google-services.json from Firebase '
          'Console. In a git worktree, run make dev to symlink from your main '
          'clone. Then stop the app fully and rebuild (not hot reload).';
    }
    if (e.contains('admin-restricted-operation') ||
        e.contains('operation-not-allowed')) {
      return 'Firebase is blocking anonymous sign-in. In Firebase Console open '
          'Authentication → Sign-in method → enable **Anonymous** → Save. '
          'If it is already on, open Authentication → Settings and ensure user '
          'sign-up / account creation is not disabled. Then stop the app fully '
          'and run `make run` again (not hot reload).';
    }
    return null;
  }
}
