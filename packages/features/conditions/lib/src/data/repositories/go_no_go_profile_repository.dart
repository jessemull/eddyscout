import 'package:eddyscout_conditions/src/domain/go_no_go.dart'
    show GoNoGoProfile;
import 'package:eddyscout_persistence/eddyscout_persistence.dart';

/// Persists `GoNoGoProfile` for wind tier scaling in `GoNoGoEvaluator`.
class GoNoGoProfileRepository {
  const GoNoGoProfileRepository(this._store);

  static const storageKey = 'go_no_go_profile';

  final KeyValueStore _store;

  Future<GoNoGoProfile> read() async {
    final raw = await _store.getString(storageKey);
    return parseStoredProfile(raw) ?? GoNoGoProfile.intermediate;
  }

  Future<void> write(GoNoGoProfile profile) async {
    await _store.setString(storageKey, profile.name);
  }

  /// Parses a stored enum name, or null when missing or unrecognized.
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
