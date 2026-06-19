import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_map/eddyscout_map.dart';
import 'package:eddyscout_map/src/presentation/map_route_planning_chrome.dart';
import 'package:eddyscout_persistence/eddyscout_persistence.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/test_localized_app.dart';

class _MockKeyValueStore extends Mock implements KeyValueStore {}

const _origin = LaunchPoint(
  id: 'launch-a',
  name: 'Put-in Launch',
  latitude: 45.5,
  longitude: -122.6,
  shortNote: 'Test put-in',
  riverSystem: RiverSystem.willamette,
  windExposure: WindExposure.sheltered,
  tideRelevance: TideRelevance.none,
);

const _destination = LaunchPoint(
  id: 'launch-b',
  name: 'Take-out Launch',
  latitude: 45.6,
  longitude: -122.5,
  shortNote: 'Test take-out',
  riverSystem: RiverSystem.willamette,
  windExposure: WindExposure.moderate,
  tideRelevance: TideRelevance.none,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _MockKeyValueStore store;

  setUp(() {
    store = _MockKeyValueStore();
    when(() => store.getDouble(any())).thenAnswer((_) async => null);
  });

  Future<void> pumpChrome(
    WidgetTester tester, {
    required DisplayUnitSystem units,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          mapKeyValueStoreProvider.overrideWith((ref) async => store),
          effectiveDisplayUnitSystemProvider.overrideWithValue(units),
        ],
        child: testLocalizedApp(
          child: Scaffold(
            body: MapRoutePlanningChrome(
              waypoints: const [_origin, _destination],
              routeLengthKm: 10,
              onBack: () {},
              onDone: () {},
              onRemoveStop: (_) {},
              onReorderStop: (_, _) {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows metric distance in planning footer', (tester) async {
    await pumpChrome(tester, units: DisplayUnitSystem.metric);

    expect(find.text('Total trip: 150 min (10.0 km)'), findsOneWidget);
  });

  testWidgets('shows imperial distance in planning footer', (tester) async {
    await pumpChrome(tester, units: DisplayUnitSystem.imperial);

    expect(find.text('Total trip: 150 min (6.2 mi)'), findsOneWidget);
  });
}
