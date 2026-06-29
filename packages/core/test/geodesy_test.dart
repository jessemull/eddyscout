import 'package:eddyscout_core/src/geodesy.dart';
import 'package:eddyscout_core/src/planned_route.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('haversineMeters', () {
    test('returns zero for identical points', () {
      expect(haversineMeters(45.5, -122.6, 45.5, -122.6), 0);
    });

    test('returns positive distance for separated points', () {
      final distance = haversineMeters(45.5, -122.6, 45.51, -122.61);
      expect(distance, greaterThan(0));
      expect(distance, lessThan(2000));
    });
  });

  group('quantizeWgs84Degree', () {
    test('rounds to seven decimal places', () {
      expect(quantizeWgs84Degree(45.123456789), 45.1234568);
    });
  });

  group('polylinePathLengthMeters', () {
    test('returns zero for fewer than two points', () {
      expect(polylinePathLengthMeters(const []), 0);
      expect(
        polylinePathLengthMeters([
          const GpxPoint(latitude: 45.5, longitude: -122.6),
        ]),
        0,
      );
    });

    test('sums segment lengths', () {
      final length = polylinePathLengthMeters([
        const GpxPoint(latitude: 45.5, longitude: -122.6),
        const GpxPoint(latitude: 45.51, longitude: -122.61),
      ]);
      expect(length, greaterThan(0));
    });
  });
}
