import 'package:eddyscout_map/src/domain/map_trip_duration.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('estimateTripDurationMinutes', () {
    test('returns null for null or non-positive distance', () {
      expect(estimateTripDurationMinutes(distanceKm: null), isNull);
      expect(estimateTripDurationMinutes(distanceKm: 0), isNull);
      expect(estimateTripDurationMinutes(distanceKm: -1), isNull);
    });

    test('computes minutes at default kayak speed', () {
      expect(estimateTripDurationMinutes(distanceKm: 4), 60);
      expect(estimateTripDurationMinutes(distanceKm: 8), 120);
    });

    test('respects custom speed', () {
      expect(
        estimateTripDurationMinutes(distanceKm: 10, speedKmh: 5),
        120,
      );
    });
  });

  group('formatDistanceMiles', () {
    test('returns null for null or non-positive distance', () {
      expect(formatDistanceMiles(null), isNull);
      expect(formatDistanceMiles(0), isNull);
      expect(formatDistanceMiles(-1), isNull);
    });

    test('converts km to miles with one decimal', () {
      expect(formatDistanceMiles(4.2), '2.6');
      expect(formatDistanceMiles(10), '6.2');
    });
  });
}
