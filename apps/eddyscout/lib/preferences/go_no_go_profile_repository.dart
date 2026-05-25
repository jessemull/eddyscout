import 'package:shared_preferences/shared_preferences.dart';

import '../decision/go_no_go.dart';

/// Persists [GoNoGoProfile] for wind tier scaling in [GoNoGoEvaluator].
class GoNoGoProfileRepository {
  const GoNoGoProfileRepository(this._prefs);

  static const storageKey = 'go_no_go_profile';

  final SharedPreferences _prefs;

  GoNoGoProfile read() {
    return parseStoredProfile(_prefs.getString(storageKey)) ??
        GoNoGoProfile.intermediate;
  }

  Future<void> write(GoNoGoProfile profile) async {
    await _prefs.setString(storageKey, profile.name);
  }

  /// Parses a stored enum [name], or null when missing or unrecognized.
  static GoNoGoProfile? parseStoredProfile(String? raw) {
    if (raw == null) {
      return null;
    }
    for (final profile in GoNoGoProfile.values) {
      if (profile.name == raw) {
        return profile;
      }
    }
    return null;
  }
}
