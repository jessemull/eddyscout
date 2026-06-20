import 'dart:async';

import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_hydro_routing/eddyscout_hydro_routing.dart';
import 'package:eddyscout_map/src/presentation/trips_from_here/nearby_launches_provider.dart';
import 'package:eddyscout_map/src/presentation/trips_from_here/trips_from_here_loading_skeleton.dart';
import 'package:eddyscout_map/src/presentation/trips_from_here/trips_from_here_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
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

List<Override> _reachabilityOverrides() => [
  launchReachabilityIndexLoaderProvider.overrideWithValue(
    readTestReachabilityIndex,
  ),
];

LaunchPoint _testLaunch({required String id, required String name}) {
  return LaunchPoint(
    id: id,
    name: name,
    latitude: 45.5,
    longitude: -122.6,
    shortNote: 'Test',
    riverSystem: RiverSystem.willamette,
    windExposure: WindExposure.moderate,
    tideRelevance: TideRelevance.none,
  );
}

Map<ReachabilityBand, List<LaunchPoint>> _groupedFiveWithin5Mi() {
  return {
    ReachabilityBand.within5Mi: [
      _testLaunch(id: 'launch_a', name: 'Launch Alpha'),
      _testLaunch(id: 'launch_b', name: 'Launch Beta'),
      _testLaunch(id: 'launch_c', name: 'Launch Gamma'),
      _testLaunch(id: 'launch_d', name: 'Launch Delta'),
      _testLaunch(id: 'launch_e', name: 'Launch Epsilon'),
    ],
    ReachabilityBand.within10Mi: const [],
    ReachabilityBand.within20Mi: const [],
  };
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TripsFromHereSection', () {
    testWidgets('shows loading skeleton while index loads', (tester) async {
      final completer = Completer<String>();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            launchReachabilityIndexLoaderProvider.overrideWithValue(
              () => completer.future,
            ),
          ],
          child: testLocalizedApp(
            child: Scaffold(
              body: TripsFromHereSection(
                originLaunch: _origin,
                onPlanToLaunch: (_) {},
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Trips from here'), findsOneWidget);
      expect(find.byType(TripsFromHereLoadingSkeleton), findsOneWidget);
    });

    testWidgets('renders nearby launches grouped by band', (tester) async {
      LaunchPoint? tapped;

      await tester.pumpWidget(
        ProviderScope(
          overrides: _reachabilityOverrides(),
          child: testLocalizedApp(
            child: Scaffold(
              body: TripsFromHereSection(
                originLaunch: _origin,
                onPlanToLaunch: (launch) => tapped = launch,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Within 5 mi'), findsOneWidget);
      expect(find.text('Swan Island Boat Ramp'), findsOneWidget);
      expect(find.text('Sellwood Riverfront Park'), findsOneWidget);

      await tester.tap(find.text('Sellwood Riverfront Park'));
      expect(tapped?.id, 'sellwood_riverfront');
    });

    testWidgets('shows empty message when all bands are empty', (tester) async {
      const emptyOrigin = LaunchPoint(
        id: 'empty_launch',
        name: 'Empty Launch',
        latitude: 45.5,
        longitude: -122.6,
        shortNote: 'Empty',
        riverSystem: RiverSystem.willamette,
        windExposure: WindExposure.moderate,
        tideRelevance: TideRelevance.none,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: _reachabilityOverrides(),
          child: testLocalizedApp(
            child: Scaffold(
              body: TripsFromHereSection(
                originLaunch: emptyOrigin,
                onPlanToLaunch: (_) {},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.text('No nearby launches found along the river from here.'),
        findsOneWidget,
      );
    });

    testWidgets('shows error with retry that reloads nearby launches', (
      tester,
    ) async {
      var loadAttempts = 0;

      Future<String> loader() async {
        loadAttempts++;
        if (loadAttempts == 1) {
          throw Exception('index missing');
        }
        return kTestReachabilityIndexJson;
      }

      await tester.pumpWidget(
        testLocalizedApp(
          child: ProviderScope(
            overrides: [
              launchReachabilityIndexLoaderProvider.overrideWithValue(loader),
            ],
            child: Scaffold(
              body: TripsFromHereSection(
                originLaunch: _origin,
                onPlanToLaunch: (_) {},
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump();

      expect(find.text("Couldn't load nearby launches."), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);

      await tester.tap(find.text('Retry'));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(loadAttempts, 2);
      expect(find.text('Within 5 mi'), findsOneWidget);
      expect(find.text('Swan Island Boat Ramp'), findsOneWidget);
    });

    testWidgets('compact mode shows show-more and expands hidden launches', (
      tester,
    ) async {
      await tester.pumpWidget(
        testLocalizedApp(
          child: ProviderScope(
            overrides: [
              nearbyLaunchesGroupedProvider('cathedral_park').overrideWith(
                (ref) async => _groupedFiveWithin5Mi(),
              ),
            ],
            child: Scaffold(
              body: TripsFromHereSection(
                originLaunch: _origin,
                onPlanToLaunch: (_) {},
                compact: true,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Show 2 more launches'), findsOneWidget);
      expect(find.text('Launch Alpha'), findsOneWidget);
      expect(find.text('Launch Beta'), findsOneWidget);
      expect(find.text('Launch Gamma'), findsOneWidget);
      expect(find.text('Launch Delta'), findsNothing);
      expect(find.text('Launch Epsilon'), findsNothing);

      await tester.tap(find.text('Show 2 more launches'));
      await tester.pumpAndSettle();

      expect(find.text('Show 2 more launches'), findsNothing);
      expect(find.text('Launch Delta'), findsOneWidget);
      expect(find.text('Launch Epsilon'), findsOneWidget);
    });
  });
}
