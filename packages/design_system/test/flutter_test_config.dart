import 'dart:async';

import 'package:golden_toolkit/golden_toolkit.dart';

/// Preloads Roboto and package fonts before any design_system test runs.
///
/// Golden PNGs are compared on pinned macOS CI runners; loading fonts here
/// avoids per-test races where the first frame renders before [loadAppFonts]
/// completes.
Future<void> testExecutable(FutureOr<void> Function() testMain) async =>
    GoldenToolkit.runWithConfiguration(
      () async {
        await loadAppFonts();
        await testMain();
      },
      config: GoldenToolkitConfiguration(),
    );
