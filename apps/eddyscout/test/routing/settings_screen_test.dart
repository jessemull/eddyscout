import 'package:eddyscout/bootstrap/app_provider_overrides.dart';
import 'package:eddyscout/routing/settings_screen.dart';
import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_persistence/eddyscout_persistence.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
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

  Future<void> pumpSettings(
    WidgetTester tester, {
    List<Override> extraOverrides = const [],
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ...buildAppProviderOverrides(keyValueStore: store),
          ...extraOverrides,
        ],
        child: testLocalizedApp(child: const SettingsScreen()),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows default paddling speed in metric units', (tester) async {
    await pumpSettings(tester);

    expect(find.text('Units'), findsOneWidget);
    expect(find.text('Paddling speed'), findsOneWidget);
    expect(
      find.byKey(const Key('settings_paddle_speed_value')),
      findsOneWidget,
    );
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
    expect(
      find.byKey(const Key('settings_paddle_speed_value')),
      findsOneWidget,
    );
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

  testWidgets('shows mph when imperial units are selected', (tester) async {
    SharedPreferences.setMockInitialValues({
      kDisplayUnitSystemKey: 'imperial',
    });
    store = await SharedPreferencesKeyValueStore.open();

    await pumpSettings(tester);

    expect(find.text('2.5 mph'), findsOneWidget);
  });

  testWidgets('persists imperial selection from segmented button', (
    tester,
  ) async {
    await pumpSettings(tester);

    await tester.tap(find.text('Imperial (mi, mph)'));
    await tester.pumpAndSettle();

    expect(find.text('2.5 mph'), findsOneWidget);
    expect(
      await store.getString(kDisplayUnitSystemKey),
      displayUnitSystemToStored(DisplayUnitSystem.imperial),
    );
  });
}
