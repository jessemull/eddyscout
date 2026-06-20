import 'package:eddyscout/bootstrap/app_provider_overrides.dart';
import 'package:eddyscout/bootstrap/map_gpx_service_adapter.dart';
import 'package:eddyscout/bootstrap/map_route_planner_adapter.dart';
import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_map/eddyscout_map.dart';
import 'package:eddyscout_persistence/eddyscout_persistence.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _sampleGpx = '''
<?xml version="1.0" encoding="UTF-8"?>
<gpx version="1.1" creator="test">
  <trk><trkseg>
    <trkpt lat="45.5620" lon="-122.7320"/>
    <trkpt lat="45.4710" lon="-122.6610"/>
  </trkseg></trk>
</gpx>''';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late KeyValueStore store;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    store = await SharedPreferencesKeyValueStore.open();
  });

  group('HydroMapGpxService', () {
    const service = HydroMapGpxService();

    test('parse and serialize round-trip sample GPX', () {
      final parsed = service.parse(_sampleGpx);
      expect(parsed, isA<Success<PlannedRoute, GpxFailure>>());

      final route = (parsed as Success<PlannedRoute, GpxFailure>).value;
      final serialized = service.serialize(route);
      expect(serialized, isA<Success<String, GpxFailure>>());
    });

    test('snapLaunchEndpoints and PNW bounds delegate to hydro', () {
      final parsed = service.parse(_sampleGpx);
      final route = (parsed as Success<PlannedRoute, GpxFailure>).value;
      final snapped = service.snapLaunchEndpoints(
        route: route,
        catalog: kLaunchPoints,
      );
      expect(snapped.points, isNotEmpty);

      expect(
        service.isEntirelyOutsidePnw(const [
          GpxPoint(latitude: 40, longitude: -74),
          GpxPoint(latitude: 41, longitude: -75),
        ]),
        isTrue,
      );
      expect(
        service.isEntirelyOutsidePnw(route.points),
        isFalse,
      );
    });
  });

  group('HydroMapRoutePlanner', () {
    test('plans a multi-segment route via app overrides', () async {
      final container = ProviderContainer(
        overrides: buildAppProviderOverrides(keyValueStore: store),
      );
      addTearDown(container.dispose);

      final planner = await container.read(mapRoutePlannerProvider.future);
      expect(planner, isA<HydroMapRoutePlanner>());

      // Port of Camas marina is not on bundled Columbia mainstem (~2.2 km gap).
      final putIn = kLaunchPoints.firstWhere((l) => l.id == 'cathedral_park');
      final takeOut = kLaunchPoints.firstWhere(
        (l) => l.id == 'glenn_otto_troutdale',
      );
      final result = await planner.planMultiSegment([putIn, takeOut]);

      expect(
        result,
        isA<Success<RouteGeometrySnapshot?, RoutePlanningFailure>>(),
      );
    });

    test('maps same-launch failures to RoutePlanningFailure', () async {
      final container = ProviderContainer(
        overrides: buildAppProviderOverrides(keyValueStore: store),
      );
      addTearDown(container.dispose);

      final planner = await container.read(mapRoutePlannerProvider.future);
      final launch = kLaunchPoints.firstWhere((l) => l.id == 'cathedral_park');
      final result = await planner.planMultiSegment([launch, launch]);

      expect(
        result,
        isA<Failure<RouteGeometrySnapshot?, RoutePlanningFailure>>(),
      );
      final failure =
          (result as Failure<RouteGeometrySnapshot?, RoutePlanningFailure>)
              .error;
      expect(failure.code, RouteFailureCode.sameLaunch);
    });
  });
}
