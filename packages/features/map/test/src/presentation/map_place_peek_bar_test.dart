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

  testWidgets('MapPlacePeekBar renders suggested trips entry', (
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
              onOpenSuggestedTrips: () {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Suggested trips'), findsOneWidget);
    expect(find.text('Plan paddle'), findsOneWidget);
    expect(find.byKey(const Key('suggested_trips_entry_tile')), findsOneWidget);

    final suggestedTop = tester.getTopLeft(find.text('Suggested trips')).dy;
    final planPaddleTop = tester.getTopLeft(find.text('Plan paddle')).dy;
    expect(suggestedTop, lessThan(planPaddleTop));
  });
}
