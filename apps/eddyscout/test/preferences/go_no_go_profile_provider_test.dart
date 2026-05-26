import 'package:eddyscout/preferences/go_no_go_profile_provider.dart';
import 'package:eddyscout/preferences/key_value_store_provider.dart';
import 'package:eddyscout_conditions/eddyscout_conditions.dart';
import 'package:eddyscout_persistence/eddyscout_persistence.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('goNoGoProfileProvider', () {
    test('reads stored profile from repository', () async {
      SharedPreferences.setMockInitialValues({
        GoNoGoProfileRepositoryImpl.storageKey: GoNoGoProfile.beginner.name,
      });
      final store = await SharedPreferencesKeyValueStore.open();
      final container = ProviderContainer(
        overrides: [keyValueStoreProvider.overrideWith((ref) async => store)],
      );
      addTearDown(container.dispose);

      final profile = await container.read(goNoGoProfileProvider.future);
      expect(profile, GoNoGoProfile.beginner);
    });

    test('setProfile updates state and persists', () async {
      SharedPreferences.setMockInitialValues({});
      final store = await SharedPreferencesKeyValueStore.open();
      final container = ProviderContainer(
        overrides: [keyValueStoreProvider.overrideWith((ref) async => store)],
      );
      addTearDown(container.dispose);

      await container.read(goNoGoProfileProvider.future);
      await container
          .read(goNoGoProfileProvider.notifier)
          .setProfile(GoNoGoProfile.advanced);

      expect(
        container.read(goNoGoProfileProvider).value,
        GoNoGoProfile.advanced,
      );
      expect(
        await store.getString(GoNoGoProfileRepositoryImpl.storageKey),
        GoNoGoProfile.advanced.name,
      );
    });
  });
}
