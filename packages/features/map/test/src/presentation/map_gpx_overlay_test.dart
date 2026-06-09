import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_map/eddyscout_map.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_localized_app.dart';

void main() {
  testWidgets('shows route planning sheet with save when route ready', (
    tester,
  ) async {
    await pumpMapWithPlanning(tester);
    expect(find.text('Plan paddle'), findsWidgets);
    expect(find.text('Save route'), findsOneWidget);
  });

  testWidgets('shows place sheet actions when launch selected', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          mapInteractiveProvider.overrideWithValue(true),
          mapSheetVisibilityStateProvider.overrideWith(_PlacePeekSheet.new),
        ],
        child: testLocalizedApp(
          child: MapScreen(
            mapSlot: const SizedBox(key: Key('map_test_stub')),
          ),
        ),
      ),
    );
    await tester.pump();
    final container = ProviderScope.containerOf(
      tester.element(find.byType(MapScreen)),
    );
    container
        .read(mapPlaceSelectionProvider.notifier)
        .pickLaunch(
          kLaunchPoints.first,
        );
    container.read(mapSheetVisibilityStateProvider.notifier).showPlacePeek();
    await tester.pump();

    expect(find.text('Plan paddle'), findsOneWidget);
    expect(find.text('View conditions'), findsOneWidget);
  });
}

Future<void> pumpMapWithPlanning(WidgetTester tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        mapInteractiveProvider.overrideWithValue(true),
        routePlanningProvider.overrideWith(_FixedRoutePlanning.new),
        mapSheetVisibilityStateProvider.overrideWith(
          _ExpandedSheet.new,
        ),
      ],
      child: testLocalizedApp(
        child: MapScreen(
          mapSlot: const SizedBox(key: Key('map_test_stub')),
          forceZoomChromeForTest: true,
        ),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
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

class _PlacePeekSheet extends MapSheetVisibilityState {
  @override
  MapSheetVisibility build() => MapSheetVisibility.placePeek;
}
