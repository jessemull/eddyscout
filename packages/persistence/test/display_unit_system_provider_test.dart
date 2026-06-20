import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_persistence/eddyscout_persistence.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockKeyValueStore extends Mock implements KeyValueStore {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _MockKeyValueStore store;

  setUp(() {
    store = _MockKeyValueStore();
    when(() => store.getString(any())).thenAnswer((_) async => null);
    when(
      () => store.setString(any(), any()),
    ).thenAnswer((_) async => true);
  });

  ProviderContainer createContainer() => ProviderContainer(
    overrides: [
      userPreferencesKeyValueStoreProvider.overrideWith(
        (ref) async => store,
      ),
    ],
  );

  test('defaults to metric when preference is absent', () async {
    final container = createContainer();
    addTearDown(container.dispose);

    final system = await container.read(unitSystemProvider.future);
    expect(system, DisplayUnitSystem.metric);
    expect(
      container.read(effectiveDisplayUnitSystemProvider),
      DisplayUnitSystem.metric,
    );
  });

  test('loads stored imperial preference', () async {
    when(
      () => store.getString(kDisplayUnitSystemKey),
    ).thenAnswer((_) async => 'imperial');

    final container = createContainer();
    addTearDown(container.dispose);

    expect(
      await container.read(unitSystemProvider.future),
      DisplayUnitSystem.imperial,
    );
    expect(
      container.read(effectiveDisplayUnitSystemProvider),
      DisplayUnitSystem.imperial,
    );
  });

  test('falls back to metric for unrecognized stored preference', () async {
    when(
      () => store.getString(kDisplayUnitSystemKey),
    ).thenAnswer((_) async => 'nautical');

    final container = createContainer();
    addTearDown(container.dispose);

    expect(
      await container.read(unitSystemProvider.future),
      DisplayUnitSystem.metric,
    );
  });

  test('persists metric after imperial was stored', () async {
    when(
      () => store.getString(kDisplayUnitSystemKey),
    ).thenAnswer((_) async => 'imperial');

    final container = createContainer();
    addTearDown(container.dispose);

    await container.read(unitSystemProvider.future);

    await container
        .read(unitSystemProvider.notifier)
        .setSystem(DisplayUnitSystem.metric);

    verify(
      () => store.setString(kDisplayUnitSystemKey, 'metric'),
    ).called(1);
    expect(
      container.read(unitSystemProvider).value,
      DisplayUnitSystem.metric,
    );
    expect(
      container.read(effectiveDisplayUnitSystemProvider),
      DisplayUnitSystem.metric,
    );
  });

  test('persists imperial preference from setSystem', () async {
    final container = createContainer();
    addTearDown(container.dispose);

    await container.read(unitSystemProvider.future);

    await container
        .read(unitSystemProvider.notifier)
        .setSystem(DisplayUnitSystem.imperial);

    verify(
      () => store.setString(kDisplayUnitSystemKey, 'imperial'),
    ).called(1);
    expect(
      container.read(unitSystemProvider).value,
      DisplayUnitSystem.imperial,
    );
    expect(
      container.read(effectiveDisplayUnitSystemProvider),
      DisplayUnitSystem.imperial,
    );
  });

  test(
    'effectiveDisplayUnitSystem falls back to metric while preference loads',
    () async {
      final container = ProviderContainer(
        overrides: [
          userPreferencesKeyValueStoreProvider.overrideWith(
            (ref) async {
              await Future<void>.delayed(const Duration(milliseconds: 100));
              return store;
            },
          ),
        ],
      );
      addTearDown(container.dispose);

      expect(
        container.read(effectiveDisplayUnitSystemProvider),
        DisplayUnitSystem.metric,
      );

      await container.read(unitSystemProvider.future);
      container.dispose();
    },
  );

  test(
    'userPreferencesKeyValueStoreProvider throws when not overridden',
    () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await expectLater(
        container.read(userPreferencesKeyValueStoreProvider.future),
        throwsA(isA<UnimplementedError>()),
      );
    },
  );
}
