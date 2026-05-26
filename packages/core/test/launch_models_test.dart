import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Launch models', () {
    test('WindExposure.label returns expected UI labels', () {
      expect(WindExposure.sheltered.label, 'Sheltered');
      expect(WindExposure.moderate.label, 'Moderate exposure');
      expect(WindExposure.exposed.label, 'Exposed');
    });

    test('TideRelevance.shortLabel returns expected UI labels', () {
      expect(TideRelevance.none.shortLabel, 'Tide: not shown');
      expect(TideRelevance.minor.shortLabel, 'Tide: reference only');
      expect(TideRelevance.major.shortLabel, 'Tide');
    });

    test('Flow band constants are coherent', () {
      expect(
        kFlowBandsUsgs14211720WillamettePortland.cfsMarginalBelow,
        lessThan(kFlowBandsUsgs14211720WillamettePortland.cfsComfortMax!),
      );
      expect(
        kFlowBandsUsgs14211720WillamettePortland.cfsComfortMax,
        lessThan(kFlowBandsUsgs14211720WillamettePortland.cfsNoGoAbove!),
      );

      expect(
        kFlowBandsUsgs14144700ColumbiaVancouver.cfsMarginalBelow,
        isNull,
      );
      expect(kFlowBandsUsgs14144700ColumbiaVancouver.cfsComfortMax, isNotNull);
      expect(kFlowBandsUsgs14144700ColumbiaVancouver.cfsNoGoAbove, isNotNull);
    });

    test('LaunchPoint can be constructed with required fields', () {
      const launch = LaunchPoint(
        id: 'id',
        name: 'Name',
        latitude: 1,
        longitude: 2,
        shortNote: 'note',
        riverSystem: RiverSystem.willamette,
        windExposure: WindExposure.sheltered,
        tideRelevance: TideRelevance.none,
      );
      expect(launch.id, 'id');
      expect(launch.riverSystem, RiverSystem.willamette);
    });

    test('LaunchPoint.fromJson and LaunchFlowBands.fromJson are callable', () {
      final bands = LaunchFlowBands.fromJson(
        <String, dynamic>{
          'cfsMarginalBelow': 1000,
          'cfsComfortMax': 2000,
          'cfsNoGoAbove': 3000,
        },
      );
      expect(bands.cfsComfortMax, 2000);

      final launch = LaunchPoint.fromJson(
        <String, dynamic>{
          'id': 'id',
          'name': 'Name',
          'latitude': 1,
          'longitude': 2,
          'shortNote': 'note',
          'riverSystem': 'willamette',
          'windExposure': 'sheltered',
          'tideRelevance': 'none',
          'flowBands': <String, dynamic>{
            'cfsMarginalBelow': 1000,
            'cfsComfortMax': 2000,
            'cfsNoGoAbove': 3000,
          },
        },
      );
      expect(launch.flowBands?.cfsNoGoAbove, 3000);
    });
  });
}
