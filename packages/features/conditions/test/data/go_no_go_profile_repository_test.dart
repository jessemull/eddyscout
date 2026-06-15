import 'package:eddyscout_conditions/eddyscout_conditions.dart';
import 'package:eddyscout_conditions/eddyscout_conditions_data.dart';
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
  Future<double?> getDouble(String key) async => null;

  @override
  Future<bool> setDouble(String key, double value) async => true;

  @override
  Future<bool> remove(String key) async => _strings.remove(key) != null;

  @override
  Future<bool> clear() async {
    _strings.clear();
    return true;
  }
}

void main() {
  group('GoNoGoProfileRepositoryImpl', () {
    late GoNoGoProfileRepositoryImpl repository;

    setUp(() {
      repository = GoNoGoProfileRepositoryImpl(_MemoryKeyValueStore());
    });

    test('read returns intermediate when storage is empty', () async {
      final result = await repository.read();
      expect(result.valueOrNull, GoNoGoProfile.intermediate);
    });

    test('write persists profile and read returns stored value', () async {
      final writeResult = await repository.write(GoNoGoProfile.advanced);
      expect(writeResult.isSuccess, isTrue);
      final readResult = await repository.read();
      expect(readResult.valueOrNull, GoNoGoProfile.advanced);
    });

    test('read returns intermediate for unrecognized stored value', () async {
      final store = _MemoryKeyValueStore();
      await store.setString(GoNoGoProfileRepositoryImpl.storageKey, 'expert');
      final repo = GoNoGoProfileRepositoryImpl(store);
      final result = await repo.read();
      expect(result.valueOrNull, GoNoGoProfile.intermediate);
    });
  });

  group('GoNoGoProfileRepositoryImpl.parseStoredProfile', () {
    test('returns null for null input', () {
      expect(GoNoGoProfileRepositoryImpl.parseStoredProfile(null), isNull);
    });

    test('returns matching profile for valid stored name', () {
      expect(
        GoNoGoProfileRepositoryImpl.parseStoredProfile('beginner'),
        GoNoGoProfile.beginner,
      );
    });

    test('returns null for unknown stored name', () {
      expect(GoNoGoProfileRepositoryImpl.parseStoredProfile('expert'), isNull);
    });
  });
}
