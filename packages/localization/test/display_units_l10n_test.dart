import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_localization/eddyscout_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppLocalizations l10n;

  setUpAll(() {
    l10n = lookupAppLocalizations(const Locale('en'));
  });

  group('localizedDistanceFromKm', () {
    test('returns null for invalid distance', () {
      expect(
        localizedDistanceFromKm(l10n, null, DisplayUnitSystem.metric),
        isNull,
      );
    });

    test('formats metric km', () {
      expect(
        localizedDistanceFromKm(l10n, 4.2, DisplayUnitSystem.metric),
        '4.2 km',
      );
    });

    test('formats imperial mi', () {
      expect(
        localizedDistanceFromKm(l10n, 4.2, DisplayUnitSystem.imperial),
        '2.6 mi',
      );
    });
  });

  group('localizedDistanceFromMeters', () {
    test('returns null for invalid distance', () {
      expect(
        localizedDistanceFromMeters(l10n, 0, DisplayUnitSystem.metric),
        isNull,
      );
    });

    test('formats metric distance from meters', () {
      expect(
        localizedDistanceFromMeters(l10n, 5200, DisplayUnitSystem.metric),
        '5.2 km',
      );
    });
  });

  group('localizedSpeedFromKmh', () {
    test('formats metric km/h', () {
      expect(
        localizedSpeedFromKmh(l10n, 4, DisplayUnitSystem.metric),
        '4.0 km/h',
      );
    });

    test('formats imperial mph', () {
      expect(
        localizedSpeedFromKmh(l10n, 4, DisplayUnitSystem.imperial),
        '2.5 mph',
      );
    });
  });

  group('localizedDistance and localizedSpeed', () {
    test('maps formatted distance units', () {
      expect(
        localizedDistance(
          l10n,
          const FormattedDistance(value: '10.0', unit: DistanceUnit.km),
        ),
        '10.0 km',
      );
      expect(
        localizedDistance(
          l10n,
          const FormattedDistance(value: '6.2', unit: DistanceUnit.mi),
        ),
        '6.2 mi',
      );
    });

    test('maps formatted speed units', () {
      expect(
        localizedSpeed(
          l10n,
          const FormattedSpeed(value: '4.0', unit: SpeedUnit.kmh),
        ),
        '4.0 km/h',
      );
      expect(
        localizedSpeed(
          l10n,
          const FormattedSpeed(value: '2.5', unit: SpeedUnit.mph),
        ),
        '2.5 mph',
      );
    });
  });
}
