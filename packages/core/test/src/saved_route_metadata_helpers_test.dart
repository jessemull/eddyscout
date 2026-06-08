import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:flutter_test/flutter_test.dart';

LaunchPoint _launch({
  required String id,
  String? name,
  WindExposure windExposure = WindExposure.sheltered,
  TideRelevance tideRelevance = TideRelevance.none,
}) => LaunchPoint(
  id: id,
  name: name ?? id,
  latitude: 45.5,
  longitude: -122.6,
  shortNote: 'note',
  riverSystem: RiverSystem.willamette,
  windExposure: windExposure,
  tideRelevance: tideRelevance,
);

void main() {
  group('suggestedSavedRouteName', () {
    test('returns null for empty waypoints', () {
      expect(suggestedSavedRouteName([]), isNull);
    });

    test('returns single launch name for one stop', () {
      expect(
        suggestedSavedRouteName([_launch(id: 'a', name: 'Put-in')]),
        'Put-in',
      );
    });

    test('joins two stops with arrow', () {
      expect(
        suggestedSavedRouteName([
          _launch(id: 'a', name: 'Cathedral Park'),
          _launch(id: 'b', name: 'Sellwood'),
        ]),
        'Cathedral Park → Sellwood',
      );
    });

    test('joins multi-stop routes in order', () {
      expect(
        suggestedSavedRouteName([
          _launch(id: 'a', name: 'A'),
          _launch(id: 'b', name: 'B'),
          _launch(id: 'c', name: 'C'),
        ]),
        'A → B → C',
      );
    });
  });

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
