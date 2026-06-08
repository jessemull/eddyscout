import 'package:eddyscout_persistence/eddyscout_persistence.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    const channel = MethodChannel('plugins.flutter.io/path_provider');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          if (call.method == 'getApplicationDocumentsDirectory') {
            return '/tmp/eddyscout_saved_routes_test';
          }
          return null;
        });
  });

  test('savedRoutesDatabase provider opens and closes database', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final db = await container.read(savedRoutesDatabaseProvider.future);
    expect(db, isA<SavedRoutesDatabase>());
    await db.close();
  });

  test('openSavedRoutesDatabase returns file-backed database', () async {
    final db = await openSavedRoutesDatabase();
    addTearDown(db.close);

    expect(db, isA<SavedRoutesDatabase>());
  });
}
