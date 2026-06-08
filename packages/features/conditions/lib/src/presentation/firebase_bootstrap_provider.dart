import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'firebase_bootstrap_provider.g.dart';

/// User-facing Firebase bootstrap state for launch detail messaging.
class FirebaseBootstrapState {
  /// Creates bootstrap state.
  const FirebaseBootstrapState({
    this.attempted = false,
    this.userFacingError,
  });

  /// Whether Firebase initialization was attempted this session.
  final bool attempted;

  /// Sanitized error message safe to show in UI, if any.
  final String? userFacingError;

  /// Extra guidance when [userFacingError] matches a known Firebase Auth code.
  String? hintForError() {
    final error = userFacingError;
    if (error == null) {
      return null;
    }
    if (error.contains('admin-restricted-operation') ||
        error.contains('operation-not-allowed')) {
      return 'Firebase is blocking anonymous sign-in. In Firebase Console open '
          'Authentication → Sign-in method → enable **Anonymous** → Save. '
          'If it is already on, open Authentication → Settings and ensure user '
          'sign-up / account creation is not disabled. Then stop the app fully '
          'and run `make run` again (not hot reload).';
    }
    return null;
  }
}

/// Maps raw Firebase exceptions to user-safe messages.
String firebaseBootstrapUserFacingError(Object error) {
  final message = error.toString();
  if (message.contains('admin-restricted-operation') ||
      message.contains('operation-not-allowed')) {
    return 'Anonymous sign-in is disabled in Firebase Console.';
  }
  return 'Firebase could not be initialized. Check native config or set '
      'USE_FIREBASE=false for local development.';
}

/// Session Firebase bootstrap outcome (overridden from app composition root).
@Riverpod(keepAlive: true)
FirebaseBootstrapState firebaseBootstrap(Ref ref) =>
    const FirebaseBootstrapState();
