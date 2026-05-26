import 'package:eddyscout_conditions/src/domain/go_no_go.dart';
import 'package:eddyscout_conditions/src/domain/repositories/go_no_go_profile_repository.dart';
import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_persistence/eddyscout_persistence.dart';

/// SharedPreferences-backed [GoNoGoProfileRepository].
class GoNoGoProfileRepositoryImpl implements GoNoGoProfileRepository {
  /// Creates a repository backed by the given key-value store.
  const GoNoGoProfileRepositoryImpl(this._store);

  /// Key-value key for the stored profile name.
  static const storageKey = 'go_no_go_profile';

  final KeyValueStore _store;

  @override
  FutureResult<GoNoGoProfile, AppFailure> read() async {
    try {
      final raw = await _store.getString(storageKey);
      return Result.success(
        parseStoredProfile(raw) ?? GoNoGoProfile.intermediate,
      );
    } on Object catch (e, st) {
      return Result.failure(
        StorageFailure(
          message: 'Could not read skill profile.',
          stackTrace: st,
        ),
      );
    }
  }

  @override
  FutureResult<void, AppFailure> write(GoNoGoProfile profile) async {
    try {
      await _store.setString(storageKey, profile.name);
      return const Result.success(null);
    } on Object catch (e, st) {
      return Result.failure(
        StorageFailure(
          message: 'Could not save skill profile.',
          stackTrace: st,
        ),
      );
    }
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
