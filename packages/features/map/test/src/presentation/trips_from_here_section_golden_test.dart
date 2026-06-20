import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_design_system/eddyscout_design_system.dart';
import 'package:eddyscout_hydro_routing/eddyscout_hydro_routing.dart';
import 'package:eddyscout_map/src/presentation/trips_from_here/trips_from_here_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/reachability_index_fixture.dart';
import '../../helpers/test_localized_app.dart';

const _origin = LaunchPoint(
  id: 'cathedral_park',
  name: 'Cathedral Park Boat Ramp',
  latitude: 45.5621,
  longitude: -122.7328,
  shortNote: 'Test origin',
  riverSystem: RiverSystem.willamette,
  windExposure: WindExposure.moderate,
  tideRelevance: TideRelevance.none,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('TripsFromHereSection golden — light theme with data', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          launchReachabilityIndexLoaderProvider.overrideWithValue(
            readTestReachabilityIndex,
          ),
        ],
        child: testLocalizedApp(
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
            useMaterial3: true,
          ),
          child: Scaffold(
            body: Padding(
              padding: EdgeInsets.all(Spacing.md),
              child: TripsFromHereSection(
                originLaunch: _origin,
                onPlanToLaunch: _noopPlan,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(TripsFromHereSection),
      matchesGoldenFile('goldens/trips_from_here_section_light.png'),
    );
  });

  testWidgets('TripsFromHereSection golden — dark theme with data', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          launchReachabilityIndexLoaderProvider.overrideWithValue(
            readTestReachabilityIndex,
          ),
        ],
        child: testLocalizedApp(
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue,
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
          ),
          child: Scaffold(
            body: Padding(
              padding: EdgeInsets.all(Spacing.md),
              child: TripsFromHereSection(
                originLaunch: _origin,
                onPlanToLaunch: _noopPlan,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(TripsFromHereSection),
      matchesGoldenFile('goldens/trips_from_here_section_dark.png'),
    );
  });
}

void _noopPlan(LaunchPoint _) {}
