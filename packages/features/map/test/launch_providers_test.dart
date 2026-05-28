import 'package:eddyscout_map/eddyscout_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('launchPointByIdProvider', () {
    test('returns curated launch for known id', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final launch = container.read(launchPointByIdProvider('cathedral_park'));

      expect(launch.name, 'Cathedral Park Boat Ramp');
    });

    test('throws for unknown id', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(
        () => container.read(launchPointByIdProvider('missing_launch')),
        throwsA(isA<Exception>()),
      );
    });
  });
}
