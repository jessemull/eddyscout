import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_design_system/eddyscout_design_system.dart';
import 'package:eddyscout_map/eddyscout_map.dart';
import 'package:eddyscout_map/src/presentation/map_route_planning_chrome.dart';
import 'package:eddyscout_persistence/eddyscout_persistence.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/memory_key_value_store.dart';
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
    required List<LaunchPoint> waypoints,
    required double? routeLengthKm,
    bool? canFinishPlanning,
    DisplayUnitSystem units = DisplayUnitSystem.metric,
    KeyValueStore? keyValueStore,
  }) async {
    final resolvedStore = keyValueStore ?? store;
    final resolvedCanFinish =
        canFinishPlanning ?? (waypoints.length >= 2 && routeLengthKm != null);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          mapKeyValueStoreProvider.overrideWith((ref) async => resolvedStore),
          effectiveDisplayUnitSystemProvider.overrideWithValue(units),
        ],
        child: testLocalizedApp(
          child: MapRoutePlanningChrome(
            waypoints: waypoints,
            routeLengthKm: routeLengthKm,
            canFinishPlanning: resolvedCanFinish,
            onBack: () {},
            onDone: () {},
            onRemoveStop: (_) {},
            onReorderStop: (_, _) {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('centers Done vertically in the footer band', (tester) async {
    await pumpChrome(
      tester,
      waypoints: [kLaunchPoints.first],
      routeLengthKm: null,
    );

    const footerHeight = 32 + (Spacing.sm * 2);
    final footerFinder = find.byKey(const Key('map_planning_footer'));
    expect(tester.getSize(footerFinder).height, footerHeight);

    final footerTop = tester.getTopLeft(footerFinder).dy;
    final doneTop = tester.getTopLeft(find.text('Done')).dy;
    final doneHeight = tester.getSize(find.text('Done')).height;
    final doneCenter = doneTop + (doneHeight / 2);
    final footerCenter = footerTop + (footerHeight / 2);

    expect(doneCenter, closeTo(footerCenter, 2));
  });

  testWidgets('aligns footer edges with chrome columns', (tester) async {
    await pumpChrome(
      tester,
      waypoints: [kLaunchPoints[0], kLaunchPoints[1]],
      routeLengthKm: 5.8,
    );

    final totalTripRect = tester.getRect(find.textContaining('Total trip'));
    final doneRect = tester.getRect(find.text('Done'));
    final closeRect = tester.getRect(find.byIcon(Icons.close).first);
    final backArrowRect = tester.getRect(find.byIcon(Icons.arrow_back));

    expect(
      totalTripRect.left,
      closeTo(backArrowRect.left, 2),
    );
    expect(doneRect.right, closeTo(closeRect.right, 2));
  });

  testWidgets('uses personalized paddling speed for trip estimate', (
    tester,
  ) async {
    final memoryStore = MemoryKeyValueStore();
    await memoryStore.setDouble(kPaddleSpeedKmhKey, 5);

    await pumpChrome(
      tester,
      waypoints: [kLaunchPoints[0], kLaunchPoints[1]],
      routeLengthKm: 5,
      keyValueStore: memoryStore,
    );

    expect(find.textContaining('Total trip: 60 min'), findsOneWidget);
  });

  testWidgets('shows metric distance in planning footer', (tester) async {
    await pumpChrome(
      tester,
      waypoints: const [_origin, _destination],
      routeLengthKm: 10,
      units: DisplayUnitSystem.metric,
    );

    expect(find.text('Total trip: 150 min (10.0 km)'), findsOneWidget);
  });

  testWidgets('shows imperial distance in planning footer', (tester) async {
    await pumpChrome(
      tester,
      waypoints: const [_origin, _destination],
      routeLengthKm: 10,
      units: DisplayUnitSystem.imperial,
    );

    expect(find.text('Total trip: 150 min (6.2 mi)'), findsOneWidget);
  });
}
