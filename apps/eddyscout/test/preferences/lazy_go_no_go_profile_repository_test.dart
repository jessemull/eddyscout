import 'package:eddyscout/preferences/key_value_store_provider.dart';
import 'package:eddyscout/preferences/lazy_go_no_go_profile_repository.dart';
import 'package:eddyscout_conditions/eddyscout_conditions.dart';
import 'package:eddyscout_conditions/eddyscout_conditions_data.dart';
import 'package:eddyscout_persistence/eddyscout_persistence.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockKeyValueStore extends Mock implements KeyValueStore {}

void main() {
  group('LazyGoNoGoProfileRepository', () {
    test('waits for keyValueStore before reading profile', () async {
      final store = _MockKeyValueStore();
      when(
        () => store.getString(GoNoGoProfileRepositoryImpl.storageKey),
      ).thenAnswer((_) async => GoNoGoProfile.beginner.name);

      final container = ProviderContainer(
        overrides: [
          keyValueStoreProvider.overrideWith((ref) async {
            await Future<void>.delayed(const Duration(milliseconds: 50));
            return store;
          }),
          lazyGoNoGoProfileRepositoryOverride(),
        ],
      );
      addTearDown(container.dispose);

      final profile = await container.read(goNoGoProfileProvider.future);

      expect(profile, GoNoGoProfile.beginner);
      verify(
        () => store.getString(GoNoGoProfileRepositoryImpl.storageKey),
      ).called(1);
    });
  });
}
