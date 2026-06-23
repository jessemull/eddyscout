import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_design_system/eddyscout_design_system.dart';
import 'package:eddyscout_hydro_routing/eddyscout_hydro_routing.dart';
import 'package:eddyscout_map/src/presentation/map_place_peek_bar.dart';
import 'package:eddyscout_map/src/presentation/map_route_preview_bar.dart';
import 'package:eddyscout_map/src/presentation/map_sheet_bottom_bar.dart';
import 'package:eddyscout_map/src/presentation/trips_from_here/nearby_launches_provider.dart';
import 'package:eddyscout_map/src/presentation/trips_from_here/suggested_trips_entry_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/reachability_index_fixture.dart';
import '../../helpers/test_localized_app.dart';

const _launch = LaunchPoint(
  id: 'cathedral_park',
  name: 'Swan Island Boat Ramp',
  latitude: 45.5621,
  longitude: -122.7328,
  shortNote: 'Test',
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

double _bottomOf(WidgetTester tester, Finder finder) {
  return tester.getRect(finder).bottom;
}

double _topOf(WidgetTester tester, Finder finder) {
  return tester.getRect(finder).top;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('middle-section widget gaps match between peek and preview', (
    tester,
  ) async {
    final mockGoNoGo = SuggestedTripsEntryRow(
      title: 'Favorable conditions',
      subtitle: 'No warnings',
      onTap: () {},
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          launchReachabilityIndexLoaderProvider.overrideWithValue(
            readTestReachabilityIndex,
          ),
          nearbyLaunchesGroupedProvider(_launch.id).overrideWith(
            (ref) async => {
              ReachabilityBand.within5Mi: [
                _testLaunch(id: 'a', name: 'Launch A'),
              ],
              ReachabilityBand.within10Mi: const [],
              ReachabilityBand.within20Mi: const [],
            },
          ),
        ],
        child: testLocalizedApp(
          child: Scaffold(
            body: Column(
              children: [
                MapPlacePeekBar(
                  launch: _launch,
                  onPlanPaddle: () {},
                  onViewConditions: () {},
                  onDismiss: () {},
                  onOpenSuggestedTrips: () {},
                ),
                MapRoutePreviewBar(
                  tripTimeLabel: '90 min',
                  routeLengthKm: 5.95,
                  canSave: true,
                  goNoGoSection: mockGoNoGo,
                  onBack: () {},
                  onDismiss: () {},
                  onStart: () {},
                  onSave: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final middleSections = find.byKey(const Key('map_sheet_middle_section'));
    expect(middleSections, findsNWidgets(2));

    final peekMiddle = middleSections.at(0);
    final previewMiddle = middleSections.at(1);
    final peekSubtitle = find.textContaining('Willamette');
    final previewSubtitle = find.textContaining('Along river');
    final peekButtonRow = find.widgetWithText(FilledButton, 'Plan paddle');
    final previewButtonRow = find.widgetWithText(OutlinedButton, 'Start');

    final peekGapAbove =
        _topOf(tester, peekMiddle) - _bottomOf(tester, peekSubtitle);
    final previewGapAbove =
        _topOf(tester, previewMiddle) - _bottomOf(tester, previewSubtitle);

    final peekGapBelow =
        _topOf(tester, peekButtonRow) - _bottomOf(tester, peekMiddle);
    final previewGapBelow =
        _topOf(tester, previewButtonRow) - _bottomOf(tester, previewMiddle);

    expect(peekGapAbove, previewGapAbove);
    expect(peekGapBelow, previewGapBelow);
    expect(peekGapAbove, kMapSheetSectionSpacing + Spacing.sm);
    expect(peekGapBelow, kMapSheetSectionSpacing + Spacing.sm);
  });
}
