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

  test('persists imperial preference', () async {
    when(
      () => store.getString(kDisplayUnitSystemKey),
    ).thenAnswer((_) async => 'imperial');

    final container = createContainer();
    addTearDown(container.dispose);

    expect(
      await container.read(unitSystemProvider.future),
      DisplayUnitSystem.imperial,
    );

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
  });
}
