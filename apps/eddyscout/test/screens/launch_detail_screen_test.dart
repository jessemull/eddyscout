import 'dart:async';

import 'package:eddyscout/preferences/key_value_store_provider.dart';
import 'package:eddyscout/screens/launch_detail_screen.dart';
import 'package:eddyscout_conditions/eddyscout_conditions.dart';
import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_map/eddyscout_map.dart';
import 'package:eddyscout_persistence/eddyscout_persistence.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../test_localized_app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final launch = kLaunchPoints.firstWhere((l) => l.id == 'cathedral_park');

  ConditionsSnapshot calmSnapshot({WeatherConditions? weather}) {
    return ConditionsSnapshot(
      fetchedAt: DateTime.utc(2026, 6, 15, 12),
      weather:
          weather ??
          const WeatherConditions(
            source: WeatherDataSource.nws,
            windSpeedMph: 5,
            windDirection: 'N',
            shortForecast: 'Light wind',
          ),
    );
  }

  Future<ProviderContainer> scopedContainer({
    required Future<ConditionsSnapshot> Function() loadConditions,
  }) async {
    SharedPreferences.setMockInitialValues({});
    final store = await SharedPreferencesKeyValueStore.open();
    return ProviderContainer(
      overrides: [
        keyValueStoreProvider.overrideWith((ref) async => store),
        conditionsSnapshotProvider(launch).overrideWith(
          (ref) => loadConditions(),
        ),
      ],
    );
  }

  Future<void> pumpLaunchDetail(
    WidgetTester tester, {
    required ProviderContainer container,
  }) async {
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: testLocalizedApp(
          child: LaunchDetailScreen(launch: launch),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('shows loading indicator while conditions load', (tester) async {
    final container = await scopedContainer(
      loadConditions: () => Completer<ConditionsSnapshot>().future,
    );
    await pumpLaunchDetail(tester, container: container);

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text(launch.name), findsOneWidget);
  });

  testWidgets('shows friendly error when conditions fail', (tester) async {
    final container = await scopedContainer(
      loadConditions: () async {
        throw const NetworkFailure(message: 'Could not reach the service.');
      },
    );
    await pumpLaunchDetail(tester, container: container);
    await tester.pump();
    await tester.pump();

    expect(
      find.textContaining('Could not load conditions. Check your connection'),
      findsOneWidget,
    );
  });

  testWidgets('shows go/no-go card and weather when data loads', (
    tester,
  ) async {
    final container = await scopedContainer(
      loadConditions: () => Future.value(calmSnapshot()),
    );
    await pumpLaunchDetail(tester, container: container);
    await tester.pump();

    expect(find.text('Go / No-go (informational)'), findsOneWidget);
    expect(find.text('Go (planning hint)'), findsOneWidget);
    expect(find.text('Weather'), findsOneWidget);
    expect(find.text('Conditions'), findsOneWidget);
    expect(find.text(launch.shortNote), findsOneWidget);
  });
}
