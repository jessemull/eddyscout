import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_hydro_routing/eddyscout_hydro_routing.dart';
import 'package:eddyscout_map/src/presentation/trips_from_here/nearby_launches_provider.dart';
import 'package:eddyscout_map/src/presentation/trips_from_here/nearby_trips_search_view.dart';
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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('NearbyTripsSearchView filters results by query', (tester) async {
    LaunchPoint? selected;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          launchReachabilityIndexLoaderProvider.overrideWithValue(
            readTestReachabilityIndex,
          ),
          nearbyLaunchesGroupedProvider(_origin.id).overrideWith(
            (ref) async => {
              ReachabilityBand.within5Mi: [
                _testLaunch(id: 'alpha', name: 'Launch Alpha'),
                _testLaunch(id: 'beta', name: 'Launch Beta'),
              ],
              ReachabilityBand.within10Mi: const [],
              ReachabilityBand.within20Mi: const [],
            },
          ),
        ],
        child: testLocalizedApp(
          child: Scaffold(
            body: NearbyTripsSearchView(
              originLaunch: _origin,
              onLaunchSelected: (launch) => selected = launch,
              onClose: () {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Launches'), findsOneWidget);
    expect(find.text('Launch Alpha'), findsOneWidget);
    expect(find.text('Launch Beta'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'beta');
    await tester.pumpAndSettle();

    expect(find.text('Launch Alpha'), findsNothing);
    expect(find.text('Launch Beta'), findsOneWidget);

    await tester.tap(find.text('Launch Beta'));
    await tester.pumpAndSettle();

    expect(selected?.id, 'beta');
  });

  testWidgets('NearbyTripsSearchView filters results by max distance', (
    tester,
  ) async {
    final near = _testLaunch(id: 'near', name: 'Launch Near');
    final far = _testLaunch(id: 'far', name: 'Launch Far');

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          launchReachabilityIndexLoaderProvider.overrideWithValue(
            readTestReachabilityIndex,
          ),
          nearbyLaunchesGroupedProvider(_origin.id).overrideWith(
            (ref) async => {
              ReachabilityBand.within5Mi: [near],
              ReachabilityBand.within10Mi: [far],
              ReachabilityBand.within20Mi: const [],
            },
          ),
        ],
        child: testLocalizedApp(
          child: Scaffold(
            body: NearbyTripsSearchView(
              originLaunch: _origin,
              onLaunchSelected: (_) {},
              onClose: () {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Launch Near'), findsOneWidget);
    expect(find.text('Launch Far'), findsOneWidget);

    await tester.tap(find.byType(DropdownButtonFormField<int>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('5 Miles').last);
    await tester.pumpAndSettle();

    expect(find.text('Launch Near'), findsOneWidget);
    expect(find.text('Launch Far'), findsNothing);
  });
}
