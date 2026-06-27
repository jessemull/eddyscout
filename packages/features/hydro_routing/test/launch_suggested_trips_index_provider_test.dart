import 'package:eddyscout_hydro_routing/eddyscout_hydro_routing.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/committed_suggested_trips_index.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('launchSuggestedTripsIndexProvider', () {
    test('loads bundled suggested trips index', () async {
      final container = ProviderContainer(
        overrides: [
          launchSuggestedTripsIndexLoaderProvider.overrideWithValue(
            readCommittedSuggestedTripsIndex,
          ),
        ],
      );
      addTearDown(container.dispose);

      final index = await container.read(
        launchSuggestedTripsIndexProvider.future,
      );

      expect(index.schemaVersion, 1);
      expect(index.crossSystemReachability, isTrue);
      expect(index.entryFor('cathedral_park'), isNotNull);
      expect(
        index.oneWayTripsFor('cathedral_park').map((trip) => trip.destination),
        contains('swan_island_boat_ramp'),
      );
    });

    test('surfaces loader failure as AppFailure', () async {
      final container = ProviderContainer(
        overrides: [
          launchSuggestedTripsIndexLoaderProvider.overrideWithValue(
            () async => throw Exception('asset missing'),
          ),
        ],
      );
      addTearDown(container.dispose);

      await expectLater(
        container.read(launchSuggestedTripsIndexProvider.future),
        throwsA(isA<HydroAppFailureException>()),
      );
    });
  });
}
