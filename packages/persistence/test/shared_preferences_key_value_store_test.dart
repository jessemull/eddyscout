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
  });
}
