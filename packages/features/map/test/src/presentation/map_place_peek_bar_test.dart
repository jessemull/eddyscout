import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_hydro_routing/eddyscout_hydro_routing.dart';
import 'package:eddyscout_map/src/presentation/map_place_peek_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/reachability_index_fixture.dart';
import '../../helpers/test_localized_app.dart';

const _launch = LaunchPoint(
  id: 'cathedral_park',
  name: 'Cathedral Park Boat Ramp',
  latitude: 45.5621,
  longitude: -122.7328,
  shortNote: 'Test',
  riverSystem: RiverSystem.willamette,
  windExposure: WindExposure.moderate,
  tideRelevance: TideRelevance.none,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('MapPlacePeekBar renders trips-from-here section', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          launchReachabilityIndexLoaderProvider.overrideWithValue(
            readTestReachabilityIndex,
          ),
        ],
        child: testLocalizedApp(
          child: Scaffold(
            body: MapPlacePeekBar(
              launch: _launch,
              onPlanPaddle: () {},
              onViewConditions: () {},
              onDismiss: () {},
              onPlanToLaunch: (_) {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Trips from here'), findsOneWidget);
    expect(find.text('Plan paddle'), findsOneWidget);
    expect(find.text('Within 5 mi'), findsOneWidget);
  });
}
