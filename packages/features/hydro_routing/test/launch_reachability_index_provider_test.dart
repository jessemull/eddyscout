import 'package:eddyscout_hydro_routing/eddyscout_hydro_routing.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/committed_reachability_index.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('launchReachabilityIndexProvider', () {
    test('loads bundled reachability index', () async {
      final container = ProviderContainer(
        overrides: [
          launchReachabilityIndexLoaderProvider.overrideWithValue(
            readCommittedReachabilityIndex,
          ),
        ],
      );
      addTearDown(container.dispose);

      final index = await container.read(
        launchReachabilityIndexProvider.future,
      );

      expect(index.schemaVersion, 1);
      expect(index.crossSystemReachability, isFalse);
      expect(index.entryFor('cathedral_park'), isNotNull);
      expect(
        index.nearbyLaunchIds(
          'cathedral_park',
          ReachabilityBand.within10Mi,
        ),
        contains('sellwood_riverfront'),
      );
    });

    test('surfaces loader failure as AppFailure', () async {
      final container = ProviderContainer(
        overrides: [
          launchReachabilityIndexLoaderProvider.overrideWithValue(
            () async => throw Exception('asset missing'),
          ),
        ],
      );
      addTearDown(container.dispose);

      await expectLater(
        container.read(launchReachabilityIndexProvider.future),
        throwsA(isA<HydroAppFailureException>()),
      );
    });
  });
}
