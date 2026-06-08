import 'package:eddyscout/preferences/key_value_store_provider.dart';
import 'package:eddyscout_persistence/eddyscout_persistence.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('keyValueStoreProvider opens SharedPreferences-backed store', () async {
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final store = await container.read(keyValueStoreProvider.future);
    expect(store, isA<SharedPreferencesKeyValueStore>());
    await store.setString('skill', 'intermediate');
    expect(await store.getString('skill'), 'intermediate');
  });
}
