import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('parseDisplayUnitSystem', () {
    test('parses metric and imperial', () {
      expect(parseDisplayUnitSystem('metric'), DisplayUnitSystem.metric);
      expect(parseDisplayUnitSystem('imperial'), DisplayUnitSystem.imperial);
    });

    test('returns null for missing or unknown values', () {
      expect(parseDisplayUnitSystem(null), isNull);
      expect(parseDisplayUnitSystem(''), isNull);
      expect(parseDisplayUnitSystem('nautical'), isNull);
    });
  });

  group('displayUnitSystemToStored', () {
    test('round-trips with parseDisplayUnitSystem', () {
      for (final system in DisplayUnitSystem.values) {
        expect(
          parseDisplayUnitSystem(displayUnitSystemToStored(system)),
          system,
        );
      }
    });
  });
}
