import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_map/src/domain/launch_tap_hit_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

void main() {
  test(
    'nearestLaunchAtScreenPoint picks closest launch within radius',
    () async {
      const putIn = LaunchPoint(
        id: 'a',
        name: 'A',
        latitude: 45.5,
        longitude: -122.6,
        shortNote: 'note',
        riverSystem: RiverSystem.willamette,
        windExposure: WindExposure.moderate,
        tideRelevance: TideRelevance.none,
      );
      const far = LaunchPoint(
        id: 'b',
        name: 'B',
        latitude: 46.0,
        longitude: -123.0,
        shortNote: 'note',
        riverSystem: RiverSystem.willamette,
        windExposure: WindExposure.moderate,
        tideRelevance: TideRelevance.none,
      );

      final hit = await nearestLaunchAtScreenPoint(
        launches: const [putIn, far],
        tap: ScreenCoordinate(x: 100, y: 100),
        launchToPixel: (launch) async => ScreenCoordinate(
          x: launch.id == 'a' ? 110 : 400,
          y: launch.id == 'a' ? 105 : 400,
        ),
      );

      expect(hit, putIn);
    },
  );

  test(
    'nearestLaunchAtScreenPoint returns null when nothing is close enough',
    () async {
      const putIn = LaunchPoint(
        id: 'a',
        name: 'A',
        latitude: 45.5,
        longitude: -122.6,
        shortNote: 'note',
        riverSystem: RiverSystem.willamette,
        windExposure: WindExposure.moderate,
        tideRelevance: TideRelevance.none,
      );

      final hit = await nearestLaunchAtScreenPoint(
        launches: const [putIn],
        tap: ScreenCoordinate(x: 10, y: 10),
        launchToPixel: (_) async => ScreenCoordinate(x: 200, y: 200),
      );

      expect(hit, isNull);
    },
  );

  test('screenDistancePx returns euclidean distance', () {
    final distance = screenDistancePx(
      ScreenCoordinate(x: 0, y: 0),
      ScreenCoordinate(x: 3, y: 4),
    );

    expect(distance, 5);
  });
}
