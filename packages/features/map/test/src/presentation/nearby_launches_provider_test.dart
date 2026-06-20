import 'package:eddyscout_hydro_routing/eddyscout_hydro_routing.dart';
import 'package:eddyscout_map/src/presentation/trips_from_here/nearby_launches_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/reachability_index_fixture.dart';

void main() {
  group('nearbyLaunchesGroupedProvider', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer(
        overrides: [
          launchReachabilityIndexLoaderProvider.overrideWithValue(
            readTestReachabilityIndex,
          ),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('resolves launch ids to catalog launches', () async {
      final grouped = await container.read(
        nearbyLaunchesGroupedProvider('cathedral_park').future,
      );

      expect(
        grouped[ReachabilityBand.within5Mi]?.map((l) => l.id),
        ['swan_island_boat_ramp'],
      );
      expect(
        grouped[ReachabilityBand.within10Mi]?.map((l) => l.id),
        ['sellwood_riverfront'],
      );
      expect(
        grouped[ReachabilityBand.within20Mi]?.map((l) => l.id),
        ['jefferson_st_milwaukie'],
      );
    });

    test('skips unknown launch ids in index', () async {
      final grouped = await container.read(
        nearbyLaunchesGroupedProvider('unknown_launch').future,
      );

      expect(grouped[ReachabilityBand.within5Mi], isEmpty);
    });

    test('returns empty bands when origin is absent from index', () async {
      final grouped = await container.read(
        nearbyLaunchesGroupedProvider('not_in_index').future,
      );

      for (final band in kReachabilityBandsDisplayOrder) {
        expect(grouped[band], isEmpty);
      }
    });
  });

  group('tripsFromHereRoutePendingProvider', () {
    test('marks and clears pending route run', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(tripsFromHereRoutePendingProvider), isFalse);
      container.read(tripsFromHereRoutePendingProvider.notifier).markPending();
      expect(container.read(tripsFromHereRoutePendingProvider), isTrue);
      container.read(tripsFromHereRoutePendingProvider.notifier).clear();
      expect(container.read(tripsFromHereRoutePendingProvider), isFalse);
    });
  });
}
