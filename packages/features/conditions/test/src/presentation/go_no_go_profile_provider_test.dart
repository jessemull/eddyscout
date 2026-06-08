import 'package:eddyscout_conditions/eddyscout_conditions.dart';
import 'package:eddyscout_conditions/eddyscout_conditions_data.dart';
import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_persistence/eddyscout_persistence.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MockGoNoGoProfileRepository extends Mock
    implements GoNoGoProfileRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValue(GoNoGoProfile.intermediate);
  });

  group('goNoGoProfileProvider', () {
    test('reads stored profile from repository', () async {
      SharedPreferences.setMockInitialValues({
        GoNoGoProfileRepositoryImpl.storageKey: GoNoGoProfile.beginner.name,
      });
      final store = await SharedPreferencesKeyValueStore.open();
      final container = ProviderContainer(
        overrides: [
          goNoGoProfileRepositoryProvider.overrideWithValue(
            GoNoGoProfileRepositoryImpl(store),
          ),
        ],
      );
      addTearDown(container.dispose);

      final profile = await container.read(goNoGoProfileProvider.future);
      expect(profile, GoNoGoProfile.beginner);
    });

    test('setProfile updates state and persists', () async {
      SharedPreferences.setMockInitialValues({});
      final store = await SharedPreferencesKeyValueStore.open();
      final container = ProviderContainer(
        overrides: [
          goNoGoProfileRepositoryProvider.overrideWithValue(
            GoNoGoProfileRepositoryImpl(store),
          ),
        ],
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

    test('read failure surfaces as AsyncError', () async {
      final repo = _MockGoNoGoProfileRepository();
      when(repo.read).thenAnswer(
        (_) async => const Result<GoNoGoProfile, AppFailure>.failure(
          StorageFailure(message: 'disk'),
        ),
      );

      final container = ProviderContainer(
        overrides: [
          goNoGoProfileRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);

      final subscription = container.listen(
        goNoGoProfileProvider,
        (_, _) {},
      );
      addTearDown(subscription.close);

      await container
          .read(goNoGoProfileProvider.future)
          .onError((_, _) => GoNoGoProfile.intermediate);

      expect(container.read(goNoGoProfileProvider).hasError, isTrue);
    });

    test('setProfile write failure sets AsyncError', () async {
      final repo = _MockGoNoGoProfileRepository();
      when(repo.read).thenAnswer(
        (_) async => const Result<GoNoGoProfile, AppFailure>.success(
          GoNoGoProfile.intermediate,
        ),
      );
      when(() => repo.write(any())).thenAnswer(
        (_) async => const Result<void, AppFailure>.failure(
          StorageFailure(message: 'write failed'),
        ),
      );

      final container = ProviderContainer(
        overrides: [
          goNoGoProfileRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);

      await container.read(goNoGoProfileProvider.future);
      await container
          .read(goNoGoProfileProvider.notifier)
          .setProfile(GoNoGoProfile.beginner);

      expect(container.read(goNoGoProfileProvider).hasError, isTrue);
    });

    test('keeps profile after listeners are removed', () async {
      SharedPreferences.setMockInitialValues({});
      final store = await SharedPreferencesKeyValueStore.open();
      final container = ProviderContainer(
        overrides: [
          goNoGoProfileRepositoryProvider.overrideWithValue(
            GoNoGoProfileRepositoryImpl(store),
          ),
        ],
      );
      addTearDown(container.dispose);

      final sub = container.listen(goNoGoProfileProvider, (_, _) {});

      await container.read(goNoGoProfileProvider.future);
      await container
          .read(goNoGoProfileProvider.notifier)
          .setProfile(GoNoGoProfile.advanced);

      sub.close();

      expect(
        container.read(goNoGoProfileProvider).value,
        GoNoGoProfile.advanced,
      );
    });
  });
}
