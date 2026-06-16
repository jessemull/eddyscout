import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('parseDisplayUnitSystem', () {
    test('parses known values', () {
      expect(parseDisplayUnitSystem('metric'), DisplayUnitSystem.metric);
      expect(parseDisplayUnitSystem('imperial'), DisplayUnitSystem.imperial);
    });

    test('defaults to metric for unknown or null', () {
      expect(parseDisplayUnitSystem(null), DisplayUnitSystem.metric);
      expect(parseDisplayUnitSystem(''), DisplayUnitSystem.metric);
      expect(parseDisplayUnitSystem('nonsense'), DisplayUnitSystem.metric);
    });
  });

  group('encodeDisplayUnitSystem', () {
    test('round-trips with parse', () {
      for (final units in DisplayUnitSystem.values) {
        expect(
          parseDisplayUnitSystem(encodeDisplayUnitSystem(units)),
          units,
        );
      }
    });
  });

  group('formatDistanceNumeric', () {
    test('returns null for invalid distances', () {
      expect(formatDistanceNumeric(null, DisplayUnitSystem.metric), isNull);
      expect(formatDistanceNumeric(0, DisplayUnitSystem.metric), isNull);
      expect(formatDistanceNumeric(-1, DisplayUnitSystem.imperial), isNull);
    });

    test('formats metric km', () {
      expect(formatDistanceNumeric(4.2, DisplayUnitSystem.metric), '4.2');
      expect(formatDistanceNumeric(10, DisplayUnitSystem.metric), '10.0');
    });

    test('formats imperial mi', () {
      expect(formatDistanceNumeric(4.2, DisplayUnitSystem.imperial), '2.6');
      expect(formatDistanceNumeric(10, DisplayUnitSystem.imperial), '6.2');
    });
  });

  group('formatSpeedNumeric', () {
    test('formats metric km/h', () {
      expect(formatSpeedNumeric(4, DisplayUnitSystem.metric), '4.0');
    });

    test('formats imperial mph', () {
      expect(formatSpeedNumeric(4, DisplayUnitSystem.imperial), '2.5');
    });
  });

  test('kmhToMph uses conversion factor', () {
    expect(kmhToMph(10), closeTo(6.21371, 0.0001));
  });
}
