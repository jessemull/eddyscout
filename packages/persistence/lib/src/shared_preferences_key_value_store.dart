import 'package:eddyscout_persistence/src/key_value_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// `KeyValueStore` backed by platform `SharedPreferences`.
class SharedPreferencesKeyValueStore implements KeyValueStore {
  /// Wraps an already-open `SharedPreferences` instance.
  SharedPreferencesKeyValueStore(this._prefs);

  final SharedPreferences _prefs;

  /// Opens the platform store and wraps it.
  static Future<SharedPreferencesKeyValueStore> open() async {
    final prefs = await SharedPreferences.getInstance();
    return SharedPreferencesKeyValueStore(prefs);
  }

  @override
  Future<String?> getString(String key) async => _prefs.getString(key);

  @override
  Future<bool> setString(String key, String value) async =>
      _prefs.setString(key, value);

  @override
  Future<bool?> getBool(String key) async => _prefs.getBool(key);

  @override
  Future<bool> setBool(String key, {required bool value}) async =>
      _prefs.setBool(key, value);

  @override
  Future<int?> getInt(String key) async => _prefs.getInt(key);

  @override
  Future<bool> setInt(String key, int value) async => _prefs.setInt(key, value);

  @override
  Future<double?> getDouble(String key) async => _prefs.getDouble(key);

  @override
  Future<bool> setDouble(String key, double value) async =>
      _prefs.setDouble(key, value);

  @override
  Future<bool> remove(String key) async => _prefs.remove(key);

  @override
  Future<bool> clear() async => _prefs.clear();
}
