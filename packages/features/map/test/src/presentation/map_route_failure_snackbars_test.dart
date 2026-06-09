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

  Future<ProviderContainer> pumpMap(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          mapInteractiveProvider.overrideWithValue(true),
          hydroGeoJsonLoaderProvider.overrideWithValue(
            () async => '{"type":"FeatureCollection","features":[]}',
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
    final container = await pumpMap(tester);
    final map = container.read(mapboxMapControllerProvider.notifier);

    container.read(routePlanningProvider.notifier).togglePlanningMode();
    await tester.pump();

    map.onLaunchCircleTap(_launchAnnotation('cathedral_park'));
    await tester.pump();
    map.onLaunchCircleTap(_launchAnnotation('cathedral_park'));
    await tester.pump();

    expect(
      find.text('Pick a different launch for take-out.'),
      findsOneWidget,
    );
  });

  testWidgets('shows snackbar for different river systems', (tester) async {
    final container = await pumpMap(tester);
    final map = container.read(mapboxMapControllerProvider.notifier);

    container.read(routePlanningProvider.notifier).togglePlanningMode();
    await tester.pump();

    map.onLaunchCircleTap(_launchAnnotation('cathedral_park'));
    await tester.pump();
    map.onLaunchCircleTap(_launchAnnotation('kelley_point'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(
      find.textContaining('same river system'),
      findsOneWidget,
    );
  });

  testWidgets('shows snackbar when bundled hydro line is missing', (
    tester,
  ) async {
    final container = await pumpMap(tester);
    final map = container.read(mapboxMapControllerProvider.notifier);

    container.read(routePlanningProvider.notifier).togglePlanningMode();
    await tester.pump();

    map.onLaunchCircleTap(_launchAnnotation('cathedral_park'));
    await tester.pump();
    map.onLaunchCircleTap(_launchAnnotation('sellwood_riverfront'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(
      find.textContaining('No bundled river line'),
      findsOneWidget,
    );
  });

  testWidgets('closes route planning sheet and exits planning mode', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          mapInteractiveProvider.overrideWithValue(true),
          routePlanningProvider.overrideWith(_PlanningWithRoute.new),
          mapSheetVisibilityStateProvider.overrideWith(_ExpandedSheet.new),
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

    expect(find.text('Plan paddle'), findsWidgets);

    await tester.tap(find.byTooltip('Close'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Plan paddle'), findsNothing);
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
      waypoints: [putIn],
    );
  }
}

class _ExpandedSheet extends MapSheetVisibilityState {
  @override
  MapSheetVisibility build() => MapSheetVisibility.planningExpanded;
}
