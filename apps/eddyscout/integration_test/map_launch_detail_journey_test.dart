// Run with:
// flutter test integration_test/map_launch_detail_journey_test.dart \
//   --dart-define=MAPBOX_ACCESS_TOKEN=pk.integration_test \
//   --dart-define=INTEGRATION_MAP_STUB=true

import 'dart:async' show unawaited;

import 'package:eddyscout/routing/app_routes.dart';
import 'package:eddyscout_map/eddyscout_map.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/eddyscout_integration_harness.dart';
import 'helpers/integration_localizations.dart';
import 'helpers/integration_pump.dart';

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
      await integrationPumpFrames(tester, count: 5);

      final l10n = integrationL10n(tester);
      await integrationWaitFor(tester, find.text(l10n.mapScreenTitle));
      expect(find.byKey(const Key('integration_map_stub')), findsOneWidget);

      final mapContext = tester.element(find.text(l10n.mapScreenTitle));
      // go_router push completes when the route is popped — do not await here.
      unawaited(LaunchDetailRoute(launchId: launch.id).push<void>(mapContext));
      await integrationPumpFrames(tester);

      await integrationWaitFor(tester, find.text(launch.name));
      expect(find.text(l10n.launchDetailGoNoGoTitle), findsOneWidget);

      await tester.tap(find.byType(BackButton));
      await integrationPumpFrames(tester);

      await integrationWaitFor(tester, find.text(l10n.mapScreenTitle));
      expect(find.byKey(const Key('integration_map_stub')), findsOneWidget);
    },
    skip: _skipJourneyTest,
  );
}
