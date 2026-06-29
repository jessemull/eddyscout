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

List<RoutePlanningStop> _catalogStops(List<LaunchPoint> launches) {
  return [
    for (final launch in launches) RoutePlanningStop.catalog(launch),
  ];
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _MockKeyValueStore store;

  setUp(() {
    store = _MockKeyValueStore();
    when(() => store.getDouble(any())).thenAnswer((_) async => null);
  });

  Future<void> pumpChrome(
    WidgetTester tester, {
    required List<RoutePlanningStop> stops,
    required double? routeLengthKm,
    bool? canFinishPlanning,
    DisplayUnitSystem units = DisplayUnitSystem.metric,
    KeyValueStore? keyValueStore,
  }) async {
    final resolvedStore = keyValueStore ?? store;
    final resolvedCanFinish =
        canFinishPlanning ?? (stops.length >= 2 && routeLengthKm != null);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          mapKeyValueStoreProvider.overrideWith((ref) async => resolvedStore),
          effectiveDisplayUnitSystemProvider.overrideWithValue(units),
        ],
        child: testLocalizedApp(
          child: MapRoutePlanningChrome(
            stops: stops,
            routeLengthKm: routeLengthKm,
            canFinishPlanning: resolvedCanFinish,
            onBack: () {},
            onDone: () {},
            onRemoveStop: (_) {},
            onReorderStop: (_, _) {},
            onChooseOnMap: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('centers Done vertically in the footer band', (tester) async {
    await pumpChrome(
      tester,
      stops: _catalogStops([kLaunchPoints.first]),
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
      stops: _catalogStops([kLaunchPoints[0], kLaunchPoints[1]]),
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
      stops: _catalogStops([kLaunchPoints[0], kLaunchPoints[1]]),
      routeLengthKm: 5,
      keyValueStore: memoryStore,
    );

    expect(find.textContaining('Total trip: 60 min'), findsOneWidget);
  });

  testWidgets('shows metric distance in planning footer', (tester) async {
    await pumpChrome(
      tester,
      stops: _catalogStops(const [_origin, _destination]),
      routeLengthKm: 10,
      units: DisplayUnitSystem.metric,
    );

    expect(find.text('Total trip: 150 min (10.0 km)'), findsOneWidget);
  });

  testWidgets('shows imperial distance in planning footer', (tester) async {
    await pumpChrome(
      tester,
      stops: _catalogStops(const [_origin, _destination]),
      routeLengthKm: 10,
      units: DisplayUnitSystem.imperial,
    );

    expect(find.text('Total trip: 150 min (6.2 mi)'), findsOneWidget);
  });

  testWidgets('shows snap stop label with edit affordance', (tester) async {
    await pumpChrome(
      tester,
      stops: [
        const RoutePlanningStop.catalog(_origin),
        const RoutePlanningStop.snap(
          id: 'snap_1',
          latitude: 45.55,
          longitude: -122.55,
          label: 'Custom Stop 2',
        ),
      ],
      routeLengthKm: 8,
    );

    expect(find.text('Custom Stop 2'), findsOneWidget);
    expect(find.byIcon(Icons.edit_outlined), findsOneWidget);
    expect(find.byIcon(Icons.place_outlined), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('edit_stop_snap_1')),
        matching: find.byType(TextField),
      ),
      findsNothing,
    );
  });

  testWidgets('shows choose on map row below search', (tester) async {
    await pumpChrome(
      tester,
      stops: _catalogStops([kLaunchPoints.first]),
      routeLengthKm: null,
    );

    expect(find.text('Choose on map'), findsOneWidget);
    expect(find.byIcon(Icons.map_outlined), findsOneWidget);
  });

  testWidgets('commits snap stop rename after tapping edit icon', (
    tester,
  ) async {
    final container = ProviderContainer(
      overrides: [
        mapKeyValueStoreProvider.overrideWith((ref) async => store),
        effectiveDisplayUnitSystemProvider.overrideWithValue(
          DisplayUnitSystem.metric,
        ),
      ],
    );
    addTearDown(container.dispose);

    container.read(routePlanningProvider.notifier).togglePlanningMode();
    container.read(routePlanningProvider.notifier).handleLaunchTap(_origin);
    container
        .read(routePlanningProvider.notifier)
        .handleSnapStop(
          const WaterwaySnapPoint(
            latitude: 45.55,
            longitude: -122.55,
            distanceMeters: 12,
          ),
          label: 'Custom Stop 2',
        );
    container
        .read(routePlanningProvider.notifier)
        .handleLaunchTap(_destination);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: testLocalizedApp(
          child: Consumer(
            builder: (context, ref, _) {
              final stops = ref.watch(routePlanningProvider).stops;
              return MapRoutePlanningChrome(
                stops: stops,
                routeLengthKm: 8,
                canFinishPlanning: true,
                onBack: () {},
                onDone: () {},
                onRemoveStop: (_) {},
                onReorderStop: (_, _) {},
                onChooseOnMap: () {},
              );
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final snapStopId = container.read(routePlanningProvider).stops[1].stopId;
    await tester.tap(find.byIcon(Icons.edit_outlined));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.descendant(
        of: find.byKey(ValueKey('edit_stop_$snapStopId')),
        matching: find.byType(TextField),
      ),
      'Lunch spot',
    );
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();

    expect(
      container.read(routePlanningProvider).stops[1].displayLabel,
      'Lunch spot',
    );
  });

  testWidgets('auto enters edit mode when pending rename is scheduled', (
    tester,
  ) async {
    final container = ProviderContainer(
      overrides: [
        mapKeyValueStoreProvider.overrideWith((ref) async => store),
        effectiveDisplayUnitSystemProvider.overrideWithValue(
          DisplayUnitSystem.metric,
        ),
      ],
    );
    addTearDown(container.dispose);
    container
            .read(mapPlanningSnapStopPendingRenameProvider.notifier)
            .pendingStopId =
        'snap_1';

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: testLocalizedApp(
          child: MapRoutePlanningChrome(
            stops: [
              const RoutePlanningStop.catalog(_origin),
              const RoutePlanningStop.snap(
                id: 'snap_1',
                latitude: 45.55,
                longitude: -122.55,
                label: 'Custom Stop 2',
              ),
            ],
            routeLengthKm: 8,
            canFinishPlanning: true,
            onBack: () {},
            onDone: () {},
            onRemoveStop: (_) {},
            onReorderStop: (_, _) {},
            onChooseOnMap: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byKey(const ValueKey('edit_stop_snap_1')),
        matching: find.byType(TextField),
      ),
      findsOneWidget,
    );
  });

  testWidgets('disables Done when canFinishPlanning is false', (tester) async {
    var doneTapped = false;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          mapKeyValueStoreProvider.overrideWith((ref) async => store),
          effectiveDisplayUnitSystemProvider.overrideWithValue(
            DisplayUnitSystem.metric,
          ),
        ],
        child: testLocalizedApp(
          child: MapRoutePlanningChrome(
            stops: _catalogStops(const [_origin, _destination]),
            routeLengthKm: 10,
            canFinishPlanning: false,
            onBack: () {},
            onDone: () => doneTapped = true,
            onRemoveStop: (_) {},
            onReorderStop: (_, _) {},
            onChooseOnMap: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Done'));
    await tester.pump();
    expect(doneTapped, isFalse);
    expect(
      tester.widget<Text>(find.text('Done')).style?.color,
      isNot(
        equals(Theme.of(tester.element(find.text('Done'))).colorScheme.primary),
      ),
    );
  });
}
