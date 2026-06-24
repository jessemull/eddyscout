import 'dart:async' show unawaited;

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

  testWidgets('NearbyTripsSearchOverlay close clears origin and callback', (
    tester,
  ) async {
    var closeCalled = false;

    await tester.pumpWidget(
      ProviderScope(
        overrides: _searchOverrides(),
        child: testLocalizedApp(
          child: Builder(
            builder: (context) {
              return Scaffold(
                body: NearbyTripsSearchOverlay(
                  originLaunch: _origin,
                  onLaunchSelected: (_) {},
                  onClose: () => closeCalled = true,
                ),
              );
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(
      tester.element(find.byKey(const Key('nearby_trips_search_view'))),
    );
    container.read(nearbyTripsSearchOriginProvider.notifier).open(_origin);
    expect(container.read(nearbyTripsSearchOriginProvider), _origin);

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    expect(closeCalled, isTrue);
    expect(container.read(nearbyTripsSearchOriginProvider), isNull);
  });

  testWidgets('NearbyTripsSearchPage pops route and clears origin on close', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: _searchOverrides(),
        child: testLocalizedApp(
          child: Builder(
            builder: (context) {
              return Scaffold(
                body: Center(
                  child: FilledButton(
                    onPressed: () {
                      unawaited(
                        Navigator.of(context).push(
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
                ),
              );
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Open search'));
    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(
      tester.element(find.byKey(const Key('nearby_trips_search_view'))),
    );
    container.read(nearbyTripsSearchOriginProvider.notifier).open(_origin);

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    expect(find.text('Open search'), findsOneWidget);
    expect(container.read(nearbyTripsSearchOriginProvider), isNull);
  });

  testWidgets('NearbyTripsSearchPage clears origin on system back', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: _searchOverrides(),
        child: testLocalizedApp(
          child: Builder(
            builder: (context) {
              return Scaffold(
                body: Center(
                  child: FilledButton(
                    onPressed: () {
                      unawaited(
                        Navigator.of(context).push(
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
                ),
              );
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Open search'));
    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(
      tester.element(find.byKey(const Key('nearby_trips_search_view'))),
    );
    container.read(nearbyTripsSearchOriginProvider.notifier).open(_origin);

    final didPop = await tester.binding.handlePopRoute();
    expect(didPop, isTrue);
    await tester.pumpAndSettle();

    expect(find.text('Open search'), findsOneWidget);
    expect(container.read(nearbyTripsSearchOriginProvider), isNull);
  });
}
