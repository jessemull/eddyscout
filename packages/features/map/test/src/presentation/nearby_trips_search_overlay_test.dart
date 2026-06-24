import 'dart:async';

import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_hydro_routing/eddyscout_hydro_routing.dart';
import 'package:eddyscout_map/src/presentation/trips_from_here/nearby_launches_provider.dart';
import 'package:eddyscout_map/src/presentation/trips_from_here/nearby_trips_search_overlay.dart';
import 'package:eddyscout_map/src/presentation/trips_from_here/nearby_trips_search_provider.dart';
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

List<Override> _searchOverrides() => [
  launchReachabilityIndexLoaderProvider.overrideWithValue(
    readTestReachabilityIndex,
  ),
  nearbyLaunchesGroupedProvider(_origin.id).overrideWith(
    (ref) async => {
      ReachabilityBand.within5Mi: [
        _testLaunch(id: 'alpha', name: 'Launch Alpha'),
      ],
      ReachabilityBand.within10Mi: const [],
      ReachabilityBand.within20Mi: const [],
    },
  ),
];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('NearbyTripsSearchOverlay closes search session on back', (
    tester,
  ) async {
    var closed = false;
    final container = ProviderContainer(overrides: _searchOverrides());
    addTearDown(container.dispose);
    container.read(nearbyTripsSearchOriginProvider.notifier).open(_origin);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: testLocalizedApp(
          child: Scaffold(
            body: NearbyTripsSearchOverlay(
              originLaunch: _origin,
              onLaunchSelected: (_) {},
              onClose: () => closed = true,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    expect(closed, isTrue);
    expect(container.read(nearbyTripsSearchOriginProvider), isNull);
  });

  testWidgets('NearbyTripsSearchPage pops route and clears search origin', (
    tester,
  ) async {
    final container = ProviderContainer(overrides: _searchOverrides());
    addTearDown(container.dispose);
    container.read(nearbyTripsSearchOriginProvider.notifier).open(_origin);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: testLocalizedApp(
          child: Scaffold(
            body: Builder(
              builder: (context) {
                return Center(
                  child: ElevatedButton(
                    onPressed: () {
                      unawaited(
                        Navigator.of(context).push<void>(
                          MaterialPageRoute<void>(
                            builder: (context) => NearbyTripsSearchPage(
                              originLaunch: _origin,
                              onLaunchSelected: (_) {},
                            ),
                          ),
                        ),
                      );
                    },
                    child: const Text('Open search'),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open search'));
    await tester.pumpAndSettle();

    expect(find.byType(NearbyTripsSearchPage), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    expect(find.byType(NearbyTripsSearchPage), findsNothing);
    expect(container.read(nearbyTripsSearchOriginProvider), isNull);
  });
}
