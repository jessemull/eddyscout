import 'package:eddyscout_conditions/src/domain/go_no_go.dart';
import 'package:eddyscout_persistence/eddyscout_persistence.dart';

/// Persists [GoNoGoProfile] for wind tier scaling in [GoNoGoEvaluator].
class GoNoGoProfileRepository {
  /// Creates a repository backed by the given key-value store.
  const GoNoGoProfileRepository(this._store);

  /// Key-value key for the stored profile name.
  static const storageKey = 'go_no_go_profile';

  final KeyValueStore _store;

  /// Reads the saved profile or [GoNoGoProfile.intermediate] when unset.
  Future<GoNoGoProfile> read() async {
    final raw = await _store.getString(storageKey);
    return parseStoredProfile(raw) ?? GoNoGoProfile.intermediate;
  }

  /// Persists [profile] as its enum name string.
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
