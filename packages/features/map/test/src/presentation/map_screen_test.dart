import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_map/eddyscout_map.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import '../../helpers/test_localized_app.dart';

CircleAnnotation _launchAnnotation(String launchId) {
  return CircleAnnotation(
    id: launchId,
    geometry: Point(coordinates: Position(0, 0)),
    customData: <String, Object>{'launchId': launchId},
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpMap(
    WidgetTester tester, {
    required List<Object?> overrides,
    bool forceZoomChrome = false,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: overrides.cast(),
        child: testLocalizedApp(
          child: MapScreen(
            mapSlot: const SizedBox(key: Key('map_test_stub')),
            forceZoomChromeForTest: forceZoomChrome,
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
  }

  testWidgets('shows floating search and map stub without app bar', (
    tester,
  ) async {
    await pumpMap(tester, overrides: []);

    expect(find.text('EddyScout'), findsNothing);
    expect(find.text('Search rivers, launches, places…'), findsOneWidget);
    expect(find.byKey(const Key('map_test_stub')), findsOneWidget);
  });

  testWidgets('shows zoom chrome in test mode with map stub', (tester) async {
    await pumpMap(
      tester,
      overrides: [
        mapInteractiveProvider.overrideWithValue(true),
      ],
      forceZoomChrome: true,
    );

    expect(find.byTooltip('Zoom in'), findsOneWidget);
    expect(find.byTooltip('Zoom out'), findsOneWidget);
    expect(find.byTooltip('Show all launches'), findsOneWidget);
  });

  testWidgets('hides zoom chrome when map stub replaces Mapbox', (
    tester,
  ) async {
    await pumpMap(
      tester,
      overrides: [
        mapInteractiveProvider.overrideWithValue(true),
      ],
    );

    expect(find.byTooltip('Zoom in'), findsNothing);
  });

  testWidgets('shows route planning sheet when planning expanded', (
    tester,
  ) async {
    await pumpMap(
      tester,
      overrides: [
        mapInteractiveProvider.overrideWithValue(true),
        routePlanningProvider.overrideWith(_FixedRoutePlanning.new),
        mapSheetVisibilityStateProvider.overrideWith(_ExpandedSheet.new),
      ],
    );

    expect(find.text('Plan paddle'), findsWidgets);
    expect(
      find.textContaining(kLaunchPoints.first.name),
      findsOneWidget,
    );
    expect(find.textContaining('12.5 km'), findsOneWidget);
  });

  testWidgets('shows place sheet when launch pin tapped', (tester) async {
    await pumpMap(
      tester,
      overrides: [
        mapInteractiveProvider.overrideWithValue(true),
      ],
    );

    final container = ProviderScope.containerOf(
      tester.element(find.byType(MapScreen)),
    );
    container
        .read(mapboxMapControllerProvider.notifier)
        .onLaunchCircleTap(_launchAnnotation('cathedral_park'));
    await tester.pump();

    expect(find.text('Plan paddle'), findsOneWidget);
    expect(find.text('View conditions'), findsOneWidget);
    expect(find.text('Cathedral Park Boat Ramp'), findsOneWidget);
  });
}

class _FixedRoutePlanning extends RoutePlanning {
  @override
  RoutePlanningState build() {
    final putIn = kLaunchPoints.first;
    final takeOut = kLaunchPoints[1];
    return RoutePlanningState(
      phase: MapPlanningPhase.routeReady,
      waypoints: [putIn, takeOut],
      routeLengthKm: 12.5,
      activeGeometry: RouteGeometrySnapshot(
        polylineLonLat: [
          [putIn.longitude, putIn.latitude],
          [takeOut.longitude, takeOut.latitude],
        ],
        lengthMeters: 12500,
        computedAt: DateTime.utc(2026),
      ),
      routeOrigin: RouteOrigin.planner,
    );
  }
}

class _ExpandedSheet extends MapSheetVisibilityState {
  @override
  MapSheetVisibility build() => MapSheetVisibility.planningExpanded;
}
