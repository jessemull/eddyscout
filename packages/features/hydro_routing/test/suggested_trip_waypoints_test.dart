import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_hydro_routing/src/domain/suggested_trip_waypoints.dart';
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
  group('suggestedTripWaypoints', () {
    test('orders intermediate launches along the polyline', () {
      final source = _launch(id: 'a', lat: 0, lon: 0);
      final middle = _launch(id: 'b', lat: 0.01, lon: 0);
      final destination = _launch(id: 'c', lat: 0.02, lon: 0);
      const polyline = [
        [0.0, 0.0],
        [0.0, 0.01],
        [0.0, 0.02],
      ];

      final waypoints = suggestedTripWaypoints(
        polylineLonLat: polyline,
        source: source,
        destination: destination,
        catalog: [source, middle, destination],
        snapMaxMeters: 900,
      );

      expect(waypoints, ['a', 'b', 'c']);
    });

    test('returns source and destination when polyline is too short', () {
      final source = _launch(id: 'a', lat: 0, lon: 0);
      final destination = _launch(id: 'b', lat: 0.01, lon: 0);

      final waypoints = suggestedTripWaypoints(
        polylineLonLat: const [
          [0.0, 0.0],
        ],
        source: source,
        destination: destination,
        catalog: [source, destination],
      );

      expect(waypoints, ['a', 'b']);
    });
  });
}
