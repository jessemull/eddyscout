import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_hydro_routing/eddyscout_hydro_routing.dart';
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

  testWidgets('shows browse search field and map without app bar', (
    tester,
  ) async {
    await pumpMap(tester, overrides: []);

    expect(find.text('EddyScout'), findsNothing);
    expect(find.byKey(const Key('map_browse_search_field')), findsOneWidget);
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

  testWidgets('shows route preview bar when in planning preview', (
    tester,
  ) async {
    await pumpMap(
      tester,
      overrides: [
        mapInteractiveProvider.overrideWithValue(true),
        routePlanningProvider.overrideWith(_FixedRoutePlanning.new),
        mapSheetVisibilityStateProvider.overrideWith(_PreviewSheet.new),
      ],
    );

    expect(find.text('Save route'), findsOneWidget);
    expect(find.text('Start'), findsOneWidget);
    expect(find.text('Add stops'), findsNothing);
    expect(find.byTooltip('Back'), findsOneWidget);
    expect(find.byTooltip('Close'), findsOneWidget);
  });

  testWidgets(
    'shows localized named snackbar for disconnected reach failure',
    (tester) async {
      await pumpMap(tester, overrides: []);

      final container = ProviderScope.containerOf(
        tester.element(find.byType(MapScreen)),
      );
      container
          .read(mapboxMapControllerProvider.notifier)
          .showSnackBarForTest(
            const RouteFailure(
              code: RouteFailureCode.disconnectedReach,
              putInReachId: 'willamette_portland',
              takeOutReachId: 'columbia_gorge',
            ),
          );
      await tester.pump();

      expect(
        find.textContaining('willamette_portland'),
        findsOneWidget,
      );
      expect(
        find.textContaining('columbia_gorge'),
        findsOneWidget,
      );
      expect(
        find.textContaining('different bundled segments'),
        findsOneWidget,
      );
    },
  );

  testWidgets('back from route preview returns to planning edit', (
    tester,
  ) async {
    await pumpMap(
      tester,
      overrides: [
        mapInteractiveProvider.overrideWithValue(true),
        routePlanningProvider.overrideWith(_FixedRoutePlanning.new),
        mapSheetVisibilityStateProvider.overrideWith(_PreviewSheet.new),
      ],
    );

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    expect(find.text('Done'), findsOneWidget);
    expect(find.text('Start'), findsNothing);

    final container = ProviderScope.containerOf(
      tester.element(find.byType(MapScreen)),
    );
    expect(
      container.read(mapSheetVisibilityStateProvider),
      MapSheetVisibility.planningEdit,
    );
    final planning = container.read(routePlanningProvider);
    expect(planning.phase, MapPlanningPhase.routeReady);
    expect(planning.waypoints, hasLength(2));
    expect(planning.activeGeometry, isNotNull);
  });

  testWidgets('close from route preview resets to map browse', (tester) async {
    await pumpMap(
      tester,
      overrides: [
        mapInteractiveProvider.overrideWithValue(true),
        routePlanningProvider.overrideWith(_FixedRoutePlanning.new),
        mapSheetVisibilityStateProvider.overrideWith(_PreviewSheet.new),
      ],
    );

    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();

    expect(find.text('Start'), findsNothing);
    expect(find.byKey(const Key('map_browse_search_field')), findsOneWidget);

    final container = ProviderScope.containerOf(
      tester.element(find.byType(MapScreen)),
    );
    expect(
      container.read(routePlanningProvider).phase,
      MapPlanningPhase.browse,
    );
    expect(container.read(mapPlaceSelectionProvider), isNull);
  });

  testWidgets('shows place peek when launch pin tapped', (tester) async {
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

  testWidgets('focuses browse search without changing the map view', (
    tester,
  ) async {
    await pumpMap(
      tester,
      overrides: [
        mapInteractiveProvider.overrideWithValue(true),
      ],
    );

    await tester.tap(find.byKey(const Key('map_browse_search_field')));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('map_fullscreen_search_overlay')),
      findsNothing,
    );
    expect(find.byKey(const Key('map_compact_search_bar')), findsNothing);
    expect(find.byKey(const Key('map_test_stub')), findsOneWidget);
  });

  testWidgets('shows full-screen search once browse results are returned', (
    tester,
  ) async {
    await pumpMap(
      tester,
      overrides: [
        mapInteractiveProvider.overrideWithValue(true),
      ],
    );

    await tester.enterText(find.byType(TextField), 'cat');
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('map_fullscreen_search_overlay')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('map_browse_search_field')), findsNothing);
  });

  testWidgets('returns to planning chrome after destination search selection', (
    tester,
  ) async {
    final putIn = kLaunchPoints.first;
    final takeOut = kLaunchPoints[1];
    await pumpMap(
      tester,
      overrides: [
        mapInteractiveProvider.overrideWithValue(true),
        routePlanningProvider.overrideWith(_SingleStopPlanning.new),
        mapSheetVisibilityStateProvider.overrideWith(_PlanningEditSheet.new),
      ],
    );

    expect(find.text(putIn.name), findsOneWidget);
    expect(
      find.byKey(const Key('map_destination_search_field')),
      findsOneWidget,
    );

    await tester.enterText(
      find.byKey(const Key('map_destination_search_field')),
      takeOut.name.substring(0, 5),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text(takeOut.name).last);
    await tester.pumpAndSettle();

    expect(find.text(takeOut.name), findsOneWidget);
    expect(find.text('Done'), findsOneWidget);
    expect(
      find.byKey(const Key('map_fullscreen_search_overlay')),
      findsNothing,
    );
  });

  testWidgets('shows inline search row in edit panel without add stop button', (
    tester,
  ) async {
    final putIn = kLaunchPoints.first;
    final takeOut = kLaunchPoints[1];
    await pumpMap(
      tester,
      overrides: [
        mapInteractiveProvider.overrideWithValue(true),
        routePlanningProvider.overrideWith(_TwoStopPlanning.new),
        mapSheetVisibilityStateProvider.overrideWith(_PlanningEditSheet.new),
      ],
    );

    expect(find.text(putIn.name), findsOneWidget);
    expect(find.text(takeOut.name), findsOneWidget);
    expect(find.byKey(const Key('map_add_stop_search_field')), findsOneWidget);
    expect(find.text('Add stop'), findsNothing);
  });

  testWidgets('back from edit stops clears route and shows place peek', (
    tester,
  ) async {
    final putIn = kLaunchPoints.first;
    await pumpMap(
      tester,
      overrides: [
        mapInteractiveProvider.overrideWithValue(true),
        routePlanningProvider.overrideWith(_TwoStopPlanning.new),
        mapSheetVisibilityStateProvider.overrideWith(_PlanningEditSheet.new),
      ],
    );

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    expect(find.text('Plan paddle'), findsOneWidget);
    expect(find.text('View conditions'), findsOneWidget);
    expect(find.text(putIn.name), findsOneWidget);

    final container = ProviderScope.containerOf(
      tester.element(find.byType(MapScreen)),
    );
    final planning = container.read(routePlanningProvider);
    expect(planning.phase, MapPlanningPhase.placeSelected);
    expect(planning.waypoints, isEmpty);
    expect(planning.activeGeometry, isNull);
    expect(planning.routeLengthKm, isNull);
    expect(
      container.read(mapPlaceSelectionProvider)?.id,
      putIn.id,
    );
  });

  testWidgets('done from edit stops shows route preview bar', (tester) async {
    await pumpMap(
      tester,
      overrides: [
        mapInteractiveProvider.overrideWithValue(true),
        routePlanningProvider.overrideWith(_FixedRoutePlanning.new),
        mapSheetVisibilityStateProvider.overrideWith(_PlanningEditSheet.new),
      ],
    );

    await tester.tap(find.text('Done').last);
    await tester.pumpAndSettle();

    expect(find.text('Start'), findsOneWidget);
    expect(find.text('Save route'), findsOneWidget);
  });

  testWidgets('start from route preview resets to map browse', (tester) async {
    await pumpMap(
      tester,
      overrides: [
        mapInteractiveProvider.overrideWithValue(true),
        routePlanningProvider.overrideWith(_FixedRoutePlanning.new),
        mapSheetVisibilityStateProvider.overrideWith(_PreviewSheet.new),
      ],
    );

    expect(find.text('Start'), findsOneWidget);
    expect(find.text('Route conditions summary coming soon.'), findsNothing);

    await tester.tap(find.text('Start'));
    await tester.pumpAndSettle();

    expect(find.text('Start'), findsNothing);
    expect(find.byKey(const Key('map_browse_search_field')), findsOneWidget);

    final container = ProviderScope.containerOf(
      tester.element(find.byType(MapScreen)),
    );
    expect(
      container.read(routePlanningProvider).phase,
      MapPlanningPhase.browse,
    );
    expect(container.read(mapPlaceSelectionProvider), isNull);
  });

  testWidgets('shows total trip footer when route length is known', (
    tester,
  ) async {
    await pumpMap(
      tester,
      overrides: [
        mapInteractiveProvider.overrideWithValue(true),
        routePlanningProvider.overrideWith(_RoutedTwoStopPlanning.new),
        mapSheetVisibilityStateProvider.overrideWith(_PlanningEditSheet.new),
      ],
    );

    expect(find.textContaining('Total trip:'), findsOneWidget);
    expect(find.textContaining('mi)'), findsOneWidget);
  });
}

class _TwoStopPlanning extends RoutePlanning {
  @override
  RoutePlanningState build() => RoutePlanningState(
    phase: MapPlanningPhase.planning,
    waypoints: [kLaunchPoints.first, kLaunchPoints[1]],
  );
}

class _RoutedTwoStopPlanning extends RoutePlanning {
  @override
  RoutePlanningState build() {
    final putIn = kLaunchPoints.first;
    final takeOut = kLaunchPoints[1];
    return RoutePlanningState(
      phase: MapPlanningPhase.routeReady,
      waypoints: [putIn, takeOut],
      routeLengthKm: 4.2,
    );
  }
}

class _SingleStopPlanning extends RoutePlanning {
  @override
  RoutePlanningState build() => RoutePlanningState(
    phase: MapPlanningPhase.planning,
    waypoints: [kLaunchPoints.first],
  );
}

class _PlanningEditSheet extends MapSheetVisibilityState {
  @override
  MapSheetVisibility build() => MapSheetVisibility.planningEdit;
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

class _PreviewSheet extends MapSheetVisibilityState {
  @override
  MapSheetVisibility build() => MapSheetVisibility.planningPreview;
}
