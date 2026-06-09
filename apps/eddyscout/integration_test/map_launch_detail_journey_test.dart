// Run with:
// flutter test integration_test/map_launch_detail_journey_test.dart \
//   --dart-define=MAPBOX_ACCESS_TOKEN=pk.integration_test \
//   --dart-define=INTEGRATION_MAP_STUB=true

import 'package:eddyscout_map/eddyscout_map.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import 'helpers/eddyscout_integration_harness.dart';
import 'helpers/integration_localizations.dart';
import 'helpers/integration_pump.dart';

const _mapboxAccessToken = String.fromEnvironment('MAPBOX_ACCESS_TOKEN');
const _usesIntegrationMapStub = bool.fromEnvironment('INTEGRATION_MAP_STUB');

final bool _hasMapboxToken = _mapboxAccessToken.isNotEmpty;
final bool _skipJourneyTest = !_hasMapboxToken || !_usesIntegrationMapStub;

CircleAnnotation _launchAnnotation(String launchId) => CircleAnnotation(
  id: launchId,
  geometry: Point(coordinates: Position(0, 0)),
  customData: <String, Object>{'launchId': launchId},
);

void main() {
  ensureIntegrationTestInitialized();

  final launch = kLaunchPoints.firstWhere((l) => l.id == 'cathedral_park');

  testWidgets(
    'map place sheet to launch detail and back',
    (tester) async {
      final container = await pumpEddyScoutApp(tester);
      await integrationPumpFrames(tester, count: 5);

      final l10n = integrationL10n(tester);
      await integrationWaitFor(
        tester,
        find.text(l10n.mapSearchPlaceholder),
      );
      expect(find.byKey(const Key('integration_map_stub')), findsOneWidget);

      container
          .read(mapboxMapControllerProvider.notifier)
          .onLaunchCircleTap(_launchAnnotation('cathedral_park'));
      await integrationPumpFrames(tester);

      await integrationWaitFor(tester, find.text(l10n.mapViewConditionsButton));
      await tester.tap(find.text(l10n.mapViewConditionsButton));
      await integrationPumpFrames(tester);

      await integrationWaitFor(tester, find.text(launch.name));
      expect(find.text(l10n.launchDetailGoNoGoTitle), findsOneWidget);

      await tester.tap(find.byType(BackButton));
      await integrationPumpFrames(tester);

      await integrationWaitFor(
        tester,
        find.text(l10n.mapSearchPlaceholder),
      );
      expect(find.byKey(const Key('integration_map_stub')), findsOneWidget);
    },
    skip: _skipJourneyTest,
  );
}
