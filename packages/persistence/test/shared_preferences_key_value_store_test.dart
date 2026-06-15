import 'package:eddyscout_persistence/eddyscout_persistence.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SharedPreferencesKeyValueStore', () {
    late SharedPreferencesKeyValueStore store;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      store = await SharedPreferencesKeyValueStore.open();
    });

    test('setString and getString round-trip', () async {
      await store.setString('k', 'v');
      expect(await store.getString('k'), 'v');
    });

    test('getString returns null when absent', () async {
      expect(await store.getString('missing'), isNull);
    });

    test('remove deletes key', () async {
      await store.setString('k', 'v');
      await store.remove('k');
      expect(await store.getString('k'), isNull);
    });

    test('setBool and getBool round-trip', () async {
      await store.setBool('b', value: true);
      expect(await store.getBool('b'), isTrue);
    });

    test('getBool returns null when absent', () async {
      expect(await store.getBool('missing'), isNull);
    });

    test('setInt and getInt round-trip', () async {
      await store.setInt('i', 123);
      expect(await store.getInt('i'), 123);
    });

    test('getInt returns null when absent', () async {
      expect(await store.getInt('missing'), isNull);
    });

    test('setDouble and getDouble round-trip', () async {
      await store.setDouble('d', 4.5);
      expect(await store.getDouble('d'), 4.5);
    });

    test('getDouble returns null when absent', () async {
      expect(await store.getDouble('missing'), isNull);
    });

    test('clear removes all keys', () async {
      await store.setString('k', 'v');
      await store.setBool('b', value: true);
      await store.setInt('i', 1);
      await store.setDouble('d', 2.5);
      await store.clear();
      expect(await store.getString('k'), isNull);
      expect(await store.getBool('b'), isNull);
      expect(await store.getInt('i'), isNull);
      expect(await store.getDouble('d'), isNull);
    });

    test('wraps an already-open SharedPreferences instance', () async {
      final prefs = await SharedPreferences.getInstance();
      final wrapped = SharedPreferencesKeyValueStore(prefs);
      await wrapped.setString('k', 'v');
      expect(await store.getString('k'), 'v');
    });
  });
}
