import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_hydro_routing/eddyscout_hydro_routing.dart';
import 'package:eddyscout_map/src/presentation/trips_from_here/nearby_launches_provider.dart';
import 'package:eddyscout_map/src/presentation/trips_from_here/nearby_trips_search_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

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
  group('NearbyTripsSearchOrigin', () {
    test('open sets origin and resets query and max distance', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container
          .read(nearbyTripsSearchQueryProvider.notifier)
          .changeQuery('stale');
      container.read(nearbyTripsMaxDistanceMiProvider.notifier).setMiles(5);

      container.read(nearbyTripsSearchOriginProvider.notifier).open(_origin);

      expect(container.read(nearbyTripsSearchOriginProvider), _origin);
      expect(container.read(nearbyTripsSearchQueryProvider), '');
      expect(container.read(nearbyTripsMaxDistanceMiProvider), 20);
    });

    test('close clears origin and query', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(nearbyTripsSearchOriginProvider.notifier).open(_origin);
      container
          .read(nearbyTripsSearchQueryProvider.notifier)
          .changeQuery('filter');

      container.read(nearbyTripsSearchOriginProvider.notifier).close();

      expect(container.read(nearbyTripsSearchOriginProvider), isNull);
      expect(container.read(nearbyTripsSearchQueryProvider), '');
    });
  });

  group('reachabilityBandsUpToMaxMi', () {
    test('includes only 5 mi band at 5 mi max', () {
      expect(
        reachabilityBandsUpToMaxMi(5),
        [ReachabilityBand.within5Mi],
      );
    });

    test('includes 5 and 10 mi bands at 10 mi max', () {
      expect(
        reachabilityBandsUpToMaxMi(10),
        [
          ReachabilityBand.within5Mi,
          ReachabilityBand.within10Mi,
        ],
      );
    });

    test('includes all bands at 20 mi max', () {
      expect(
        reachabilityBandsUpToMaxMi(20),
        kReachabilityBandsDisplayOrder,
      );
    });
  });

  group('filteredNearbyTripsProvider', () {
    test('filters launches by query text', () async {
      const originId = 'cathedral_park';
      final alpha = LaunchPoint(
        id: 'alpha',
        name: 'Launch Alpha',
        latitude: 45.51,
        longitude: -122.61,
        shortNote: 'Alpha note',
        riverSystem: RiverSystem.willamette,
        windExposure: WindExposure.moderate,
        tideRelevance: TideRelevance.none,
      );
      final beta = LaunchPoint(
        id: 'beta',
        name: 'Launch Beta',
        latitude: 45.52,
        longitude: -122.62,
        shortNote: 'Beta note',
        riverSystem: RiverSystem.willamette,
        windExposure: WindExposure.moderate,
        tideRelevance: TideRelevance.none,
      );

      final container = ProviderContainer(
        overrides: [
          nearbyLaunchesGroupedProvider(originId).overrideWith(
            (ref) async => {
              ReachabilityBand.within5Mi: [alpha, beta],
              ReachabilityBand.within10Mi: const [],
              ReachabilityBand.within20Mi: const [],
            },
          ),
        ],
      );
      addTearDown(container.dispose);

      container
          .read(nearbyTripsSearchQueryProvider.notifier)
          .changeQuery('alpha');

      final results = await container.read(
        filteredNearbyTripsProvider(originId).future,
      );

      expect(results, [alpha]);
    });
  });
}
