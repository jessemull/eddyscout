import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_hydro_routing/eddyscout_hydro_routing.dart';
import 'package:flutter_test/flutter_test.dart';

LaunchPoint _launch({
  required String id,
  required double lat,
  required double lon,
}) {
  return LaunchPoint(
    id: id,
    name: id,
    latitude: lat,
    longitude: lon,
    shortNote: 'Test',
    riverSystem: RiverSystem.willamette,
    windExposure: WindExposure.moderate,
    tideRelevance: TideRelevance.none,
  );
}

void main() {
  group('LaunchEndpointSnapper', () {
    final catalog = [
      _launch(id: 'cathedral', lat: 45.5621, lon: -122.7328),
      _launch(id: 'sellwood', lat: 45.4709, lon: -122.6617),
    ];

    test('snaps endpoints within 2 km', () {
      final route = PlannedRoute(
        points: const [
          GpxPoint(latitude: 45.5620, longitude: -122.7320),
          GpxPoint(latitude: 45.4710, longitude: -122.6610),
        ],
        origin: RouteOrigin.imported,
      );

      final snapped = LaunchEndpointSnapper.snapEndpoints(
        route: route,
        catalog: catalog,
      );

      expect(snapped.putIn?.id, 'cathedral');
      expect(snapped.takeOut?.id, 'sellwood');
    });

    test('leaves endpoints null when no launch within threshold', () {
      final route = PlannedRoute(
        points: const [
          GpxPoint(latitude: 44.0, longitude: -121.0),
          GpxPoint(latitude: 44.1, longitude: -121.1),
        ],
        origin: RouteOrigin.imported,
      );

      final snapped = LaunchEndpointSnapper.snapEndpoints(
        route: route,
        catalog: catalog,
      );

      expect(snapped.putIn, isNull);
      expect(snapped.takeOut, isNull);
    });
  });
}
