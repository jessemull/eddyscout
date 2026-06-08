import 'package:eddyscout/bootstrap/app_bootstrap.dart';
import 'package:eddyscout_persistence/eddyscout_persistence.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test(
    'bootstrapApp opens key-value store and skips Firebase by default',
    () async {
      final bootstrap = await bootstrapApp();

      expect(bootstrap.keyValueStore, isA<SharedPreferencesKeyValueStore>());
      expect(bootstrap.firebaseBootstrapState.attempted, isFalse);
      expect(bootstrap.firebaseBootstrapState.userFacingError, isNull);
    },
  );
}
