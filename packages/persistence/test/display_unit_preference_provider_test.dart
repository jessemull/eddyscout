import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_persistence/eddyscout_persistence.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/memory_key_value_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('displayUnitPreferenceProvider', () {
    late MemoryKeyValueStore store;
    late ProviderContainer container;

    setUp(() {
      store = MemoryKeyValueStore();
      container = ProviderContainer(
        overrides: [
          userPreferencesKeyValueStoreProvider.overrideWith(
            (ref) async => store,
          ),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('returns metric when preference is absent', () async {
      final units = await container.read(displayUnitPreferenceProvider.future);
      expect(units, DisplayUnitSystem.metric);
    });

    test('persists and reloads imperial', () async {
      await container.read(displayUnitPreferenceProvider.future);
      await container
          .read(displayUnitPreferenceProvider.notifier)
          .setUnits(DisplayUnitSystem.imperial);

      expect(
        container.read(displayUnitPreferenceProvider).value,
        DisplayUnitSystem.imperial,
      );
      expect(
        await store.getString(kDisplayUnitSystemKey),
        encodeDisplayUnitSystem(DisplayUnitSystem.imperial),
      );

      final reloaded = ProviderContainer(
        overrides: [
          userPreferencesKeyValueStoreProvider.overrideWith(
            (ref) async => store,
          ),
        ],
      );
      addTearDown(reloaded.dispose);

      expect(
        await reloaded.read(displayUnitPreferenceProvider.future),
        DisplayUnitSystem.imperial,
      );
    });
  });

  test('effectiveDisplayUnitsProvider falls back to metric while loading', () {
    final container = ProviderContainer(
      overrides: [
        userPreferencesKeyValueStoreProvider.overrideWith(
          (ref) async => throw StateError('not ready'),
        ),
      ],
    );
    addTearDown(container.dispose);

    expect(
      container.read(effectiveDisplayUnitsProvider),
      DisplayUnitSystem.metric,
    );
  });
}
