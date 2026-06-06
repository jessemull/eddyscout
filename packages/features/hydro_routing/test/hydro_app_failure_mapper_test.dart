import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_hydro_routing/src/data/hydro_app_failure_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('mapHydroToAppFailure', () {
    test('passes through AppFailure', () {
      const failure = StorageFailure(message: 'existing');
      expect(mapHydroToAppFailure(failure), same(failure));
    });

    test('maps FormatException to StorageFailure', () {
      final failure = mapHydroToAppFailure(
        const FormatException('Expected FeatureCollection'),
      );
      expect(failure, isA<StorageFailure>());
      expect(failure.message, 'River route data could not be read.');
    });

    test('maps generic Exception to StorageFailure', () {
      final failure = mapHydroToAppFailure(Exception('asset missing'));
      expect(failure, isA<StorageFailure>());
      expect(failure.message, 'River route data is unavailable.');
    });
  });
}
