import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_hydro_routing/src/data/hydro_app_failure_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('mapHydroToAppFailure', () {
    test('passes through AppFailure', () {
      const failure = StorageFailure(message: 'existing');
      expect(mapHydroToAppFailure(failure), same(failure));
    });

    test('maps FormatException to ParseFailure', () {
      final failure = mapHydroToAppFailure(
        const FormatException('Expected FeatureCollection'),
      );
      expect(failure, isA<ParseFailure>());
    });

    test('maps generic Exception to AssetLoadFailure', () {
      final failure = mapHydroToAppFailure(Exception('asset missing'));
      expect(failure, isA<AssetLoadFailure>());
    });
  });
}
