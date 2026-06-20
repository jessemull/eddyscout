import 'dart:io';

import 'package:eddyscout_hydro_routing/eddyscout_hydro_routing.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('bundled hydro asset bounds', () {
    const hydroDir = 'assets/hydro';
    const maxTotalBytes = 500 * 1024;

    const expectedFiles = {
      'willamette_waterway.geojson': 12000,
      'columbia_lower_waterway.geojson': 20000,
      'columbia_gorge_waterway.geojson': 15000,
      'clackamas_waterway.geojson': 45000,
      'slough_waterway.geojson': 20000,
      'tualatin_waterway.geojson': 20000,
      'sandy_waterway.geojson': 10000,
    };

    test(
      'each waterway asset exists, parses, and stays within size ceiling',
      () {
        var totalBytes = 0;
        for (final entry in expectedFiles.entries) {
          final path = '$hydroDir/${entry.key}';
          final file = File(path);
          expect(file.existsSync(), isTrue, reason: 'missing $path');
          final bytes = file.lengthSync();
          totalBytes += bytes;
          expect(
            bytes,
            lessThanOrEqualTo(entry.value),
            reason: '$path grew beyond ${entry.value} byte ceiling',
          );
          expect(
            () => parseAndMergeHydroGeoJson([file.readAsStringSync()]),
            returnsNormally,
          );
        }
        expect(totalBytes, lessThan(maxTotalBytes));
      },
    );
  });
}
