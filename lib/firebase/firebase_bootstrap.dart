/// Set from [main] when Firebase init runs; used for user-visible debug on launch detail.
class FirebaseBootstrap {
  FirebaseBootstrap._();

  static bool attempted = false;
  static String? lastError;

  /// Extra guidance when [lastError] matches a known Firebase Auth code.
  static String? hintForLastError() {
    final e = lastError;
    if (e == null) return null;
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
