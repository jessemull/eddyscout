import 'package:eddyscout_persistence/eddyscout_persistence.dart';

/// In-memory [KeyValueStore] for persistence package tests.
final class MemoryKeyValueStore implements KeyValueStore {
  final Map<String, Object> _values = {};

  @override
  Future<bool> clear() async {
    _values.clear();
    return true;
  }

  @override
  Future<bool?> getBool(String key) async => _values[key] as bool?;

  @override
  Future<double?> getDouble(String key) async => _values[key] as double?;

  @override
  Future<int?> getInt(String key) async => _values[key] as int?;

  @override
  Future<String?> getString(String key) async => _values[key] as String?;

  @override
  Future<bool> remove(String key) async => _values.remove(key) != null;

  @override
  Future<bool> setBool(String key, {required bool value}) async {
    _values[key] = value;
    return true;
  }

  @override
  Future<bool> setDouble(String key, double value) async {
    _values[key] = value;
    return true;
  }

  @override
  Future<bool> setInt(String key, int value) async {
    _values[key] = value;
    return true;
  }

  @override
  Future<bool> setString(String key, String value) async {
    _values[key] = value;
    return true;
  }
}
