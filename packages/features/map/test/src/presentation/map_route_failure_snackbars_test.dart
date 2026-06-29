import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_map/eddyscout_map.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import '../../helpers/test_hydro_map_providers.dart';
import '../../helpers/test_localized_app.dart';

CircleAnnotation _launchAnnotation(String launchId) {
  return CircleAnnotation(
    id: launchId,
    geometry: Point(coordinates: Position(0, 0)),
    customData: <String, Object>{'launchId': launchId},
  );
}

const _emptyHydroGeoJson = '{"type":"FeatureCollection","features":[]}';

/// Willamette + slough segments with no graph connection (cross-system fail).
const _disconnectedCrossSystemHydroGeoJson = '''
{
  "type": "FeatureCollection",
  "features": [
    {
      "type": "Feature",
      "properties": {"river_system": "willamette", "reach_id": "w_reach"},
      "geometry": {
        "type": "LineString",
        "coordinates": [[-122.759, 45.588], [-122.758, 45.587]]
      }
    },
    {
      "type": "Feature",
      "properties": {"river_system": "slough", "reach_id": "s_reach"},
      "geometry": {
        "type": "LineString",
        "coordinates": [[-122.763, 45.646], [-122.762, 45.645]]
      }
    }
  ]
}
''';

void _enterPlanningEdit(ProviderContainer container) {
  container.read(routePlanningProvider.notifier).togglePlanningMode();
  container.read(mapSheetVisibilityStateProvider.notifier).showPlanningEdit();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<ProviderContainer> pumpMap(
    WidgetTester tester, {
    String hydroGeoJson = _emptyHydroGeoJson,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          mapInteractiveProvider.overrideWithValue(true),
          ...testHydroMapProviderOverrides(
            hydroLoader: () async => [hydroGeoJson],
          ),
        ],
        child: testLocalizedApp(
          child: const MapScreen(
            mapSlot: SizedBox(key: Key('map_test_stub')),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();
    return ProviderScope.containerOf(tester.element(find.byType(MapScreen)));
  }

  testWidgets('shows snackbar when take-out equals put-in', (tester) async {
    final container = await pumpMap(
      tester,
      hydroGeoJson: _disconnectedCrossSystemHydroGeoJson,
    );
    final map = container.read(mapboxMapControllerProvider.notifier);

    _enterPlanningEdit(container);
    await tester.pump();

    map.onLaunchCircleTap(_launchAnnotation('cathedral_park'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    map.onLaunchCircleTap(_launchAnnotation('cathedral_park'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(
      find.text('Pick a different launch for take-out.'),
      findsOneWidget,
    );
  });

  testWidgets('shows snackbar for different river systems', (tester) async {
    final snackbarMessages = <Object>[];
    final container = await pumpMap(
      tester,
      hydroGeoJson: _disconnectedCrossSystemHydroGeoJson,
    );
    final map = container.read(mapboxMapControllerProvider.notifier);

    _enterPlanningEdit(container);
    await tester.pumpAndSettle();

    map.bindUiCallbacks(
      MapUiCallbacks(
        pickDifferentTakeOutMessage: 'Pick a different launch for take-out.',
        pickStopLaunchBlockedMessage:
            'Tap the river to add a custom stop, not a launch pin.',
        riverDataLoadingMessage: 'Loading',
        riverDataLoadFailedMessage: 'Unavailable',
        showSnackBar: snackbarMessages.add,
      ),
    );

    final putIn = findLaunchPointById('cathedral_park')!;
    final takeOut = findLaunchPointById('kelley_point')!;
    await map.tryAddPlanningWaypoint(putIn);
    await map.tryAddPlanningWaypoint(takeOut);

    expect(container.read(routePlanningProvider).stops, hasLength(1));
    expect(
      snackbarMessages.whereType<RoutePlanningFailure>().map((e) => e.code),
      contains(
        anyOf(
          RouteFailureCode.differentSystem,
          RouteFailureCode.disconnectedReach,
          RouteFailureCode.noConnectedPath,
        ),
      ),
    );
  });

  testWidgets('shows snackbar when river geometry is missing', (
    tester,
  ) async {
    final container = await pumpMap(tester);
    final map = container.read(mapboxMapControllerProvider.notifier);

    _enterPlanningEdit(container);
    await tester.pump();

    map.onLaunchCircleTap(_launchAnnotation('cathedral_park'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(
      container.read(routePlanningProvider).stops,
      isEmpty,
    );
    expect(
      find.descendant(
        of: find.byType(SnackBar),
        matching: find.textContaining('River route data is not available yet'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('exits planning edit via back arrow', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          mapInteractiveProvider.overrideWithValue(true),
          routePlanningProvider.overrideWith(_PlanningWithRoute.new),
          mapSheetVisibilityStateProvider.overrideWith(_EditSheet.new),
        ],
        child: testLocalizedApp(
          child: const MapScreen(
            mapSlot: SizedBox(key: Key('map_test_stub')),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('Done'), findsOneWidget);
    expect(find.text(kLaunchPoints.first.name), findsOneWidget);

    await tester.tap(find.byTooltip('Back'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Done'), findsNothing);
    expect(
      ProviderScope.containerOf(
        tester.element(find.byType(MapScreen)),
      ).read(routePlanningProvider).planningMode,
      isFalse,
    );
  });
}

class _PlanningWithRoute extends RoutePlanning {
  @override
  RoutePlanningState build() {
    final putIn = kLaunchPoints.first;
    return RoutePlanningState(
      phase: MapPlanningPhase.planning,
      stops: [RoutePlanningStop.catalog(putIn)],
    );
  }
}

class _EditSheet extends MapSheetVisibilityState {
  @override
  MapSheetVisibility build() => MapSheetVisibility.planningEdit;
}
