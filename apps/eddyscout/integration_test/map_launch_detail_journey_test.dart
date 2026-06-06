// Run with:
// flutter test integration_test/map_launch_detail_journey_test.dart \
//   --dart-define=MAPBOX_ACCESS_TOKEN=pk.integration_test \
//   --dart-define=INTEGRATION_MAP_STUB=true

import 'package:eddyscout/routing/app_routes.dart';
import 'package:eddyscout_map/eddyscout_map.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/eddyscout_integration_harness.dart';

const _mapboxAccessToken = String.fromEnvironment('MAPBOX_ACCESS_TOKEN');
const _usesIntegrationMapStub = bool.fromEnvironment('INTEGRATION_MAP_STUB');

final bool _hasMapboxToken = _mapboxAccessToken.isNotEmpty;
final bool _skipJourneyTest = !_hasMapboxToken || !_usesIntegrationMapStub;

void main() {
  ensureIntegrationTestInitialized();

  final launch = kLaunchPoints.firstWhere((l) => l.id == 'cathedral_park');

  testWidgets(
    'map to launch detail and back',
    (tester) async {
      await pumpEddyScoutApp(tester);
      await tester.pumpAndSettle(const Duration(seconds: 5));

      expect(find.text('EddyScout'), findsOneWidget);
      expect(find.byKey(const Key('integration_map_stub')), findsOneWidget);

      final mapContext = tester.element(find.text('EddyScout'));
      await LaunchDetailRoute(launchId: launch.id).push<void>(mapContext);
      await tester.pumpAndSettle(const Duration(seconds: 5));

      expect(find.text(launch.name), findsOneWidget);
      expect(find.text('Go / No-go (informational)'), findsOneWidget);

      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      expect(find.text('EddyScout'), findsOneWidget);
      expect(find.byKey(const Key('integration_map_stub')), findsOneWidget);
    },
    skip: _skipJourneyTest,
  );
}
