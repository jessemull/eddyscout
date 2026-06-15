import 'package:eddyscout/bootstrap/app_provider_overrides.dart';
import 'package:eddyscout/routing/settings_screen.dart';
import 'package:eddyscout_persistence/eddyscout_persistence.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../test_localized_app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late KeyValueStore store;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    store = await SharedPreferencesKeyValueStore.open();
  });

  Future<void> pumpSettings(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: buildAppProviderOverrides(keyValueStore: store),
        child: testLocalizedApp(child: const SettingsScreen()),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows default paddling speed', (tester) async {
    await pumpSettings(tester);

    expect(find.text('Paddling speed'), findsOneWidget);
    expect(find.text('4.0 km/h'), findsOneWidget);
  });

  testWidgets('updates displayed speed when slider changes', (tester) async {
    await pumpSettings(tester);

    await tester.drag(
      find.byKey(const Key('settings_paddle_speed_slider')),
      const Offset(120, 0),
    );
    await tester.pumpAndSettle();

    expect(find.text('4.0 km/h'), findsNothing);
    expect(find.textContaining('km/h'), findsOneWidget);
  });

  testWidgets('reset button restores default speed', (tester) async {
    await pumpSettings(tester);

    await tester.drag(
      find.byKey(const Key('settings_paddle_speed_slider')),
      const Offset(120, 0),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('settings_paddle_speed_reset')));
    await tester.pumpAndSettle();

    expect(find.text('4.0 km/h'), findsOneWidget);
  });
}
