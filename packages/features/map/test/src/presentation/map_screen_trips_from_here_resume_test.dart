import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_hydro_routing/eddyscout_hydro_routing.dart';
import 'package:eddyscout_map/eddyscout_map.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_hydro_map_providers.dart';
import '../../helpers/test_localized_app.dart';

class _RecordingMapRoutePlanner implements MapRoutePlanner {
  _RecordingMapRoutePlanner(this.planCalls);

  final ValueNotifier<int> planCalls;

  @override
  Future<Result<RouteGeometrySnapshot?, RoutePlanningFailure>> planMultiSegment(
    List<LaunchPoint> waypoints,
  ) async {
    planCalls.value++;
    return const Result.success(null);
  }

  @override
  Future<Result<void, RoutePlanningFailure>> validateLaunch(
    LaunchPoint launch,
  ) async => const Result.success(null);

  @override
  Future<Result<void, RoutePlanningFailure>> validateSegment(
    LaunchPoint from,
    LaunchPoint to,
  ) async => const Result.success(null);
}

LaunchPoint _launch(String id, String name) {
  return LaunchPoint(
    id: id,
    name: name,
    latitude: 45.5,
    longitude: -122.6,
    shortNote: 'Test',
    riverSystem: RiverSystem.willamette,
    windExposure: WindExposure.moderate,
    tideRelevance: TideRelevance.none,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'resumes planning edit and reruns route when pending flag is set',
    (tester) async {
      final planCalls = ValueNotifier<int>(0);
      final putIn = _launch('cathedral_park', 'Cathedral Park Boat Ramp');
      final takeOut = _launch(
        'sellwood_riverfront',
        'Sellwood Riverfront Park',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            mapInteractiveProvider.overrideWithValue(true),
            hydroGeoJsonLoaderProvider.overrideWithValue(
              () async => [
                '{"type":"FeatureCollection","features":[]}',
              ],
            ),
            mapRoutePlannerProvider.overrideWith(
              (ref) async => _RecordingMapRoutePlanner(planCalls),
            ),
            testHydroMapGpxServiceOverride(),
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

      final container = ProviderScope.containerOf(
        tester.element(find.byType(MapScreen)),
      );

      container
          .read(routePlanningProvider.notifier)
          .startPlanFromHereTo(putIn: putIn, takeOut: takeOut);
      container.read(tripsFromHereRoutePendingProvider.notifier).markPending();

      await tester.pump();
      await tester.pump();

      expect(find.text('Done'), findsOneWidget);
      expect(find.text(putIn.name), findsOneWidget);
      expect(find.text(takeOut.name), findsOneWidget);
      expect(
        container.read(mapSheetVisibilityStateProvider),
        MapSheetVisibility.planningEdit,
      );
      expect(planCalls.value, greaterThanOrEqualTo(1));
    },
  );
}
