import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_map/src/presentation/trips_from_here/suggested_trips_section.dart';
import 'package:flutter/material.dart';
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
  testWidgets('SuggestedTripsSection renders empty placeholder', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SuggestedTripsSection(
          originLaunch: _origin,
          onPlanToLaunch: (_) {},
        ),
      ),
    );

    expect(find.byType(SuggestedTripsSection), findsOneWidget);
  });
}
