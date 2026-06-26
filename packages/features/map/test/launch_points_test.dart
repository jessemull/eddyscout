import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('launch points', () {
    test('kLaunchPoints is not empty and ids are unique', () {
      expect(kLaunchPoints, isNotEmpty);
      final ids = kLaunchPoints.map((p) => p.id).toList();
      expect(ids.toSet().length, ids.length);
    });

    test('findLaunchPointById returns launch when present', () {
      final first = kLaunchPoints.first;
      final found = findLaunchPointById(first.id);
      expect(found, isNotNull);
      expect(found?.id, first.id);
    });

    test('findLaunchPointById returns null when missing', () {
      expect(findLaunchPointById('not-a-launch'), isNull);
    });

    test('catalog launches have WGS84 coordinates in regional bounds', () {
      for (final launch in kLaunchPoints) {
        expect(launch.latitude, inInclusiveRange(45.3, 46.0));
        expect(launch.longitude, inInclusiveRange(-123.0, -122.3));
      }
    });
  });
}
