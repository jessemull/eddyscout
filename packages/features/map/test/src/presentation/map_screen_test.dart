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
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: overrides.cast(),
        child: testLocalizedApp(
          child: const MapScreen(
            mapSlot: SizedBox(key: Key('map_test_stub')),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
  }

  testWidgets('shows app bar and map stub', (tester) async {
    await pumpMap(tester, overrides: []);

    expect(find.text('EddyScout'), findsOneWidget);
    expect(find.byKey(const Key('map_test_stub')), findsOneWidget);
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
    expect(find.byTooltip('Zoom out'), findsNothing);
    expect(find.byTooltip('Show all launches'), findsNothing);
  });

  testWidgets('hides zoom chrome while map is not interactive', (tester) async {
    await pumpMap(
      tester,
      overrides: [
        mapInteractiveProvider.overrideWithValue(false),
      ],
    );

    expect(find.byTooltip('Zoom in'), findsNothing);
  });

  testWidgets('shows route planning overlay when planning mode is on', (
    tester,
  ) async {
    await pumpMap(
      tester,
      overrides: [
        mapInteractiveProvider.overrideWithValue(true),
        routePlanningProvider.overrideWith(_FixedRoutePlanning.new),
      ],
    );

    expect(find.text('River route (beta)'), findsOneWidget);
    expect(
      find.textContaining('Put-in: ${kLaunchPoints.first.name}'),
      findsOneWidget,
    );
    expect(
      find.textContaining('Take-out: ${kLaunchPoints[1].name}'),
      findsOneWidget,
    );
    expect(find.textContaining('12.5 km'), findsOneWidget);
  });

  testWidgets(
    'invokes onOpenLaunchDetail when launch pin tapped outside planning',
    (tester) async {
      LaunchPoint? openedLaunch;

      await tester.pumpWidget(
        ProviderScope(
          child: testLocalizedApp(
            child: MapScreen(
              mapSlot: const SizedBox(key: Key('map_test_stub')),
              onOpenLaunchDetail: (launch) => openedLaunch = launch,
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump();

      final container = ProviderScope.containerOf(
        tester.element(find.byType(MapScreen)),
      );
      container
          .read(mapboxMapControllerProvider.notifier)
          .onLaunchCircleTap(_launchAnnotation('cathedral_park'));
      await tester.pump();

      expect(openedLaunch, isNotNull);
      expect(openedLaunch!.id, 'cathedral_park');
    },
  );
}

class _FixedRoutePlanning extends RoutePlanning {
  @override
  RoutePlanningState build() {
    final putIn = kLaunchPoints.first;
    final takeOut = kLaunchPoints[1];
    return RoutePlanningState(
      planningMode: true,
      putIn: putIn,
      takeOut: takeOut,
      routeLengthKm: 12.5,
    );
  }
}
