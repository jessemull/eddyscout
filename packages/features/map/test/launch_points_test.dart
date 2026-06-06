import 'package:eddyscout_map/src/data/launch_points.dart';
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

    test('kPortlandLaunchPoints is an alias of kLaunchPoints', () {
      expect(identical(kPortlandLaunchPoints, kLaunchPoints), isTrue);
      expect(kPortlandLaunchPoints.length, kLaunchPoints.length);
    });
  });
}
