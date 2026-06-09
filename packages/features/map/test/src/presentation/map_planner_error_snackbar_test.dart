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

  testWidgets('shows localized snackbar when river planner failed to load', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          hydroGeoJsonLoaderProvider.overrideWithValue(
            () async => throw Exception('asset missing'),
          ),
          mapInteractiveProvider.overrideWithValue(true),
        ],
        child: testLocalizedApp(
          child: Builder(
            builder: (context) => Theme(
              data: Theme.of(context).copyWith(
                splashFactory: NoSplash.splashFactory,
              ),
              child: const MapScreen(
                mapSlot: SizedBox(key: Key('map_test_stub')),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    final container = ProviderScope.containerOf(
      tester.element(find.byType(MapScreen)),
    );

    await expectLater(
      container.read(riverRoutePlannerProvider.future),
      throwsA(isA<HydroAppFailureException>()),
    );
    expect(
      hydroAppFailureFrom(container.read(riverRoutePlannerProvider).error),
      isA<AssetLoadFailure>(),
    );

    container.read(routePlanningProvider.notifier).togglePlanningMode();
    await tester.pump();

    final map = container.read(mapboxMapControllerProvider.notifier);
    map.onLaunchCircleTap(_launchAnnotation('cathedral_park'));
    await tester.pump();
    map.onLaunchCircleTap(_launchAnnotation('sellwood_riverfront'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('River route data is unavailable.'), findsOneWidget);
  });
}
