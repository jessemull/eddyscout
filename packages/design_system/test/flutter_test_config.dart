import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

/// Tolerates sub-pixel raster diffs when macOS font rendering shifts.
const _goldenDiffTolerance = 0.01;

/// Preloads Roboto and package fonts before any design_system test runs.
///
/// Golden PNGs are compared on pinned macOS CI runners; loading fonts here
/// avoids per-test races where the first frame renders before [loadAppFonts]
/// completes.
Future<void> testExecutable(FutureOr<void> Function() testMain) async =>
    GoldenToolkit.runWithConfiguration(
      () async {
        goldenFileComparator = _TolerantLocalFileComparator(
          Uri.parse('test/goldens/app_theme_golden_test.dart'),
        );
        await loadAppFonts();
        await testMain();
      },
      config: GoldenToolkitConfiguration(),
    );

final class _TolerantLocalFileComparator extends LocalFileComparator {
  _TolerantLocalFileComparator(super.testFile);

  @override
  Future<bool> compare(Uint8List imageBytes, Uri golden) async {
    final result = await GoldenFileComparator.compareLists(
      imageBytes,
      await getGoldenBytes(golden),
    );

    final passed = result.passed || result.diffPercent <= _goldenDiffTolerance;
    if (passed) {
      result.dispose();
      return true;
    }

    final error = await generateFailureOutput(result, golden, basedir);
    result.dispose();
    throw FlutterError(error);
  }
}
