import 'package:eddyscout_conditions/eddyscout_conditions.dart';
import 'package:eddyscout/preferences/go_no_go_profile_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('GoNoGoProfileRepository', () {
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
    });

    test('read returns intermediate when storage is empty', () {
      final repository = GoNoGoProfileRepository(prefs);

      expect(repository.read(), GoNoGoProfile.intermediate);
    });

    test('write persists profile and read returns stored value', () async {
      final repository = GoNoGoProfileRepository(prefs);

      await repository.write(GoNoGoProfile.advanced);

      expect(repository.read(), GoNoGoProfile.advanced);
    });

    test('read returns intermediate for unrecognized stored value', () async {
      SharedPreferences.setMockInitialValues({
        GoNoGoProfileRepository.storageKey: 'expert',
      });
      prefs = await SharedPreferences.getInstance();
      final repository = GoNoGoProfileRepository(prefs);

      expect(repository.read(), GoNoGoProfile.intermediate);
    });
  });

  group('GoNoGoProfileRepository.parseStoredProfile', () {
    test('returns null for null input', () {
      expect(GoNoGoProfileRepository.parseStoredProfile(null), isNull);
    });

    test('returns matching profile for valid stored name', () {
      expect(
        GoNoGoProfileRepository.parseStoredProfile('beginner'),
        GoNoGoProfile.beginner,
      );
    });

    test('returns null for unknown stored name', () {
      expect(GoNoGoProfileRepository.parseStoredProfile('expert'), isNull);
    });
  });
}
