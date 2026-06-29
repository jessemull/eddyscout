import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_map/eddyscout_map.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_localized_app.dart';

void main() {
  testWidgets('shows route preview bar with save when route ready', (
    tester,
  ) async {
    await pumpMapWithPreview(tester);
    expect(find.text('Save route'), findsOneWidget);
    expect(find.text('Start'), findsOneWidget);
    expect(find.text('Add stops'), findsNothing);
    expect(find.byTooltip('Back'), findsOneWidget);
    expect(find.byTooltip('Close'), findsOneWidget);
    expect(find.text('188 min'), findsOneWidget);
  });

  testWidgets('shows planning edit chrome with edit stops title', (
    tester,
  ) async {
    await pumpMapWithPlanningEdit(tester);
    expect(find.text(kLaunchPoints.first.name), findsOneWidget);
    expect(find.text('Done'), findsOneWidget);
  });

  testWidgets('shows place peek actions when launch selected', (
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

Future<void> pumpMapWithPreview(WidgetTester tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        mapInteractiveProvider.overrideWithValue(true),
        routePlanningProvider.overrideWith(_FixedRoutePlanning.new),
        mapSheetVisibilityStateProvider.overrideWith(_PreviewSheet.new),
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

Future<void> pumpMapWithPlanningEdit(WidgetTester tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        mapInteractiveProvider.overrideWithValue(true),
        routePlanningProvider.overrideWith(_PlanningWithStart.new),
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
}

class _FixedRoutePlanning extends RoutePlanning {
  @override
  RoutePlanningState build() {
    final putIn = kLaunchPoints.first;
    final takeOut = kLaunchPoints[1];
    return RoutePlanningState(
      phase: MapPlanningPhase.routeReady,
      stops: [
        RoutePlanningStop.catalog(putIn),
        RoutePlanningStop.catalog(takeOut),
      ],
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

class _PlanningWithStart extends RoutePlanning {
  @override
  RoutePlanningState build() {
    return RoutePlanningState(
      phase: MapPlanningPhase.planning,
      stops: [RoutePlanningStop.catalog(kLaunchPoints.first)],
    );
  }
}

class _PreviewSheet extends MapSheetVisibilityState {
  @override
  MapSheetVisibility build() => MapSheetVisibility.planningPreview;
}

class _EditSheet extends MapSheetVisibilityState {
  @override
  MapSheetVisibility build() => MapSheetVisibility.planningEdit;
}

class _PlacePeekSheet extends MapSheetVisibilityState {
  @override
  MapSheetVisibility build() => MapSheetVisibility.placePeek;
}
