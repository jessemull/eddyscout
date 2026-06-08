import 'package:eddyscout_hydro_routing/eddyscout_hydro_routing.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GpxBounds', () {
    test('isEntirelyOutsidePnw is false for Portland-area points', () {
      const points = [
        GpxPoint(latitude: 45.56, longitude: -122.73),
        GpxPoint(latitude: 45.47, longitude: -122.66),
      ];
      expect(GpxBounds.isEntirelyOutsidePnw(points), isFalse);
    });

    test('isEntirelyOutsidePnw is true when all points are outside PNW', () {
      const points = [
        GpxPoint(latitude: 40.0, longitude: -74.0),
        GpxPoint(latitude: 41.0, longitude: -75.0),
      ];
      expect(GpxBounds.isEntirelyOutsidePnw(points), isTrue);
    });

    test('isEntirelyOutsidePnw is false when mixed inside and outside', () {
      const points = [
        GpxPoint(latitude: 45.56, longitude: -122.73),
        GpxPoint(latitude: 40.0, longitude: -74.0),
      ];
      expect(GpxBounds.isEntirelyOutsidePnw(points), isFalse);
    });
  });
}
