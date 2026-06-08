import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:flutter_test/flutter_test.dart';

LaunchPoint _launch({
  required String id,
  WindExposure windExposure = WindExposure.sheltered,
  TideRelevance tideRelevance = TideRelevance.none,
}) => LaunchPoint(
  id: id,
  name: id,
  latitude: 45.5,
  longitude: -122.6,
  shortNote: 'note',
  riverSystem: RiverSystem.willamette,
  windExposure: windExposure,
  tideRelevance: tideRelevance,
);

void main() {
  group('computeSavedRouteMetadata', () {
    test('picks max exposure and tide across launches', () {
      final metadata = computeSavedRouteMetadata(
        launches: [
          _launch(id: 'a'),
          _launch(
            id: 'b',
            windExposure: WindExposure.exposed,
            tideRelevance: TideRelevance.major,
          ),
        ],
        distanceMeters: 12000,
      );

      expect(metadata.exposure, WindExposure.exposed);
      expect(metadata.tideDependency, TideRelevance.major);
      expect(metadata.distanceMeters, 12000);
    });
  });
}
