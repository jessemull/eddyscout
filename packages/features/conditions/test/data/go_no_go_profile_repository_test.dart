import 'package:eddyscout_conditions/eddyscout_conditions.dart';
import 'package:eddyscout_persistence/eddyscout_persistence.dart';
import 'package:flutter_test/flutter_test.dart';

/// In-memory [KeyValueStore] for repository unit tests.
class _MemoryKeyValueStore implements KeyValueStore {
  final _strings = <String, String>{};

  @override
  Future<String?> getString(String key) async => _strings[key];

  @override
  Future<bool> setString(String key, String value) async {
    _strings[key] = value;
    return true;
  }

  @override
  Future<bool?> getBool(String key) async => null;

  @override
  Future<bool> setBool(String key, {required bool value}) async => true;

  @override
  Future<int?> getInt(String key) async => null;

  @override
  Future<bool> setInt(String key, int value) async => true;

  @override
  Future<bool> remove(String key) async => _strings.remove(key) != null;

  @override
  Future<bool> clear() async {
    _strings.clear();
    return true;
  }
}

void main() {
  group('GoNoGoProfileRepository', () {
    late GoNoGoProfileRepository repository;

    setUp(() {
      repository = GoNoGoProfileRepository(_MemoryKeyValueStore());
    });

    test('read returns intermediate when storage is empty', () async {
      expect(await repository.read(), GoNoGoProfile.intermediate);
    });

    test('write persists profile and read returns stored value', () async {
      await repository.write(GoNoGoProfile.advanced);
      expect(await repository.read(), GoNoGoProfile.advanced);
    });

    test('read returns intermediate for unrecognized stored value', () async {
      final store = _MemoryKeyValueStore();
      await store.setString(GoNoGoProfileRepository.storageKey, 'expert');
      final repo = GoNoGoProfileRepository(store);
      expect(await repo.read(), GoNoGoProfile.intermediate);
    });
  });

  group('GoNoGoProfileRepository.parseStoredProfile', () {
    test('returns null for null input', () {
      expect(GoNoGoProfileRepository.parseStoredProfile(null), isNull);
    });

    test('returns matching profile for valid stored name', () {
      expect(
        GoNoGoProfileRepository.parseStoredProfile('beginner'),
        GoNoGoProfile.beginner,
      );
    });

    test('returns null for unknown stored name', () {
      expect(GoNoGoProfileRepository.parseStoredProfile('expert'), isNull);
    });
  });
}
