/// Abstraction over key-value storage (e.g. SharedPreferences).
///
/// Use only for lightweight user preferences. For structured data,
/// use the structured store abstraction backed by drift.
abstract class KeyValueStore {
  /// Reads a string value for [key], or null if absent.
  Future<String?> getString(String key);

  /// Persists [value] under [key].
  Future<bool> setString(String key, String value);

  /// Reads a bool value for [key], or null if absent.
  Future<bool?> getBool(String key);

  /// Persists [value] under [key].
  Future<bool> setBool(String key, {required bool value});

  /// Reads an int value for [key], or null if absent.
  Future<int?> getInt(String key);

  /// Persists [value] under [key].
  Future<bool> setInt(String key, int value);

  /// Reads a double value for [key], or null if absent.
  Future<double?> getDouble(String key);

  /// Persists [value] under [key].
  Future<bool> setDouble(String key, double value);

  /// Removes the entry for [key].
  Future<bool> remove(String key);

  /// Clears all stored entries.
  Future<bool> clear();
}
