import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('formatDistanceFromKm', () {
    test('returns null for null or non-positive distance', () {
      expect(formatDistanceFromKm(null, DisplayUnitSystem.metric), isNull);
      expect(formatDistanceFromKm(0, DisplayUnitSystem.metric), isNull);
      expect(formatDistanceFromKm(-1, DisplayUnitSystem.imperial), isNull);
    });

    test('formats metric km with one decimal', () {
      final result = formatDistanceFromKm(4.25, DisplayUnitSystem.metric);
      expect(result?.value, '4.3');
      expect(result?.unit, DistanceUnit.km);
    });

    test('formats imperial mi with one decimal', () {
      final result = formatDistanceFromKm(4.2, DisplayUnitSystem.imperial);
      expect(result?.value, '2.6');
      expect(result?.unit, DistanceUnit.mi);
    });
  });

  group('formatDistanceFromMeters', () {
    test('delegates to km conversion', () {
      final result = formatDistanceFromMeters(5200, DisplayUnitSystem.metric);
      expect(result?.value, '5.2');
      expect(result?.unit, DistanceUnit.km);
    });
  });

  group('formatSpeedFromKmh', () {
    test('formats metric km/h', () {
      final result = formatSpeedFromKmh(4, DisplayUnitSystem.metric);
      expect(result.value, '4.0');
      expect(result.unit, SpeedUnit.kmh);
    });

    test('formats imperial mph', () {
      final result = formatSpeedFromKmh(4, DisplayUnitSystem.imperial);
      expect(result.value, '2.5');
      expect(result.unit, SpeedUnit.mph);
    });
  });
}
