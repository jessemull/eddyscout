import 'package:eddyscout_conditions/eddyscout_conditions.dart';
import 'package:eddyscout/preferences/go_no_go_profile_provider.dart';
import 'package:eddyscout/preferences/go_no_go_profile_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('goNoGoProfileProvider', () {
    late ProviderContainer container;

    setUp(() async {
      SharedPreferences.setMockInitialValues({
        GoNoGoProfileRepository.storageKey: GoNoGoProfile.beginner.name,
      });
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('loads stored profile on build', () async {
      final profile = await container.read(goNoGoProfileProvider.future);

      expect(profile, GoNoGoProfile.beginner);
    });

    test('setProfile updates state and persists', () async {
      await container.read(goNoGoProfileProvider.future);

      await container
          .read(goNoGoProfileProvider.notifier)
          .setProfile(GoNoGoProfile.advanced);

      expect(
        container.read(goNoGoProfileProvider).value,
        GoNoGoProfile.advanced,
      );

      final prefs = await SharedPreferences.getInstance();
      expect(
        prefs.getString(GoNoGoProfileRepository.storageKey),
        GoNoGoProfile.advanced.name,
      );
    });
  });
}
