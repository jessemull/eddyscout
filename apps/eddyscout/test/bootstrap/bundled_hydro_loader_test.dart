import 'package:eddyscout/bootstrap/bundled_hydro_loader.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('assertBundledHydroGeoJsonLoaded rejects incomplete bundle', () {
    expect(
      () => assertBundledHydroGeoJsonLoaded([
        '{"type":"FeatureCollection","features":[]}',
        '{"type":"FeatureCollection","features":[]}',
      ]),
      throwsStateError,
    );
  });

  test('assertBundledHydroGeoJsonLoaded accepts columbia_lower marker', () {
    expect(
      () => assertBundledHydroGeoJsonLoaded([
        for (var i = 0; i < 7; i++)
          '{"type":"FeatureCollection","features":[{"properties":{"reach_id":"columbia_lower"}}]}',
      ]),
      returnsNormally,
    );
  });
}
