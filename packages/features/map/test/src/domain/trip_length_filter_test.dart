import 'package:eddyscout_map/src/domain/trip_length_filter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('tripLengthFilterMatches', () {
    const kmPerMi = 1.609344;

    double milesToKm(double miles) => miles * kmPerMi;

    test('short includes distances under 5 mi', () {
      expect(
        tripLengthFilterMatches(
          filter: TripLengthFilter.short,
          distanceKm: milesToKm(4.9),
        ),
        isTrue,
      );
      expect(
        tripLengthFilterMatches(
          filter: TripLengthFilter.short,
          distanceKm: milesToKm(5.0),
        ),
        isFalse,
      );
    });

    test('medium includes 5.0 through 10.0 mi inclusive', () {
      expect(
        tripLengthFilterMatches(
          filter: TripLengthFilter.medium,
          distanceKm: milesToKm(4.9),
        ),
        isFalse,
      );
      expect(
        tripLengthFilterMatches(
          filter: TripLengthFilter.medium,
          distanceKm: milesToKm(5.0),
        ),
        isTrue,
      );
      expect(
        tripLengthFilterMatches(
          filter: TripLengthFilter.medium,
          distanceKm: milesToKm(10.0),
        ),
        isTrue,
      );
      expect(
        tripLengthFilterMatches(
          filter: TripLengthFilter.medium,
          distanceKm: milesToKm(10.1),
        ),
        isFalse,
      );
    });

    test('long includes distances over 10 mi', () {
      expect(
        tripLengthFilterMatches(
          filter: TripLengthFilter.long,
          distanceKm: milesToKm(10.0),
        ),
        isFalse,
      );
      expect(
        tripLengthFilterMatches(
          filter: TripLengthFilter.long,
          distanceKm: milesToKm(10.1),
        ),
        isTrue,
      );
    });

    test('all matches every distance', () {
      for (final miles in [0.0, 4.9, 5.0, 10.0, 10.1, 100.0]) {
        expect(
          tripLengthFilterMatches(
            filter: TripLengthFilter.all,
            distanceKm: milesToKm(miles),
          ),
          isTrue,
        );
      }
    });
  });
}
