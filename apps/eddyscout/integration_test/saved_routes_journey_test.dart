// Run with:
// flutter test integration_test/saved_routes_journey_test.dart \
//   --dart-define=MAPBOX_ACCESS_TOKEN=pk.integration_test \
//   --dart-define=INTEGRATION_MAP_STUB=true

import 'package:eddyscout_core/eddyscout_core.dart';
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

class _IntegrationRunnableRoutePlanning extends RoutePlanning {
  @override
  RoutePlanningState build() {
    final putIn = findLaunchPointById('cathedral_park')!;
    final takeOut = findLaunchPointById('sellwood_riverfront')!;
    return RoutePlanningState(
      planningMode: true,
      waypoints: [putIn, takeOut],
      routeLengthKm: 5.2,
      activeGeometry: RouteGeometrySnapshot(
        polylineLonLat: const [
          [-122.73, 45.56],
          [-122.66, 45.47],
        ],
        lengthMeters: 5200,
        computedAt: DateTime.utc(2026),
      ),
    );
  }
}

void main() {
  ensureIntegrationTestInitialized();

  testWidgets(
    'save route on map then open detail and load on map',
    (tester) async {
      final container = await createIntegrationContainer(
        extraOverrides: [
          routePlanningProvider.overrideWith(
            _IntegrationRunnableRoutePlanning.new,
          ),
        ],
      );
      await pumpEddyScoutApp(tester, container: container);
      await integrationPumpFrames(tester, count: 5);

      final l10n = integrationL10n(tester);
      await integrationWaitFor(tester, find.text(l10n.mapScreenTitle));
      expect(find.text(l10n.mapPlanningSaveLabel), findsOneWidget);

      await tester.tap(find.text(l10n.mapPlanningSaveLabel));
      await integrationPumpFrames(tester);

      await integrationWaitFor(
        tester,
        find.text(l10n.savedRoutesSaveFromMapButton),
      );
      await tester.tap(find.text(l10n.savedRoutesSaveFromMapButton));
      await integrationPumpFrames(tester);

      await integrationWaitFor(tester, find.text(l10n.savedRoutesSaveSuccess));

      await tester.tap(find.text(l10n.shellTabSavedRoutes));
      await integrationPumpFrames(tester);

      const savedName = 'Cathedral Park Boat Ramp → Sellwood Riverfront Park';
      await integrationWaitFor(tester, find.text(savedName));
      await tester.tap(find.text(savedName));
      await integrationPumpFrames(tester);

      await integrationWaitFor(tester, find.text(l10n.savedRoutesDetailTitle));
      expect(find.widgetWithText(TextField, savedName), findsOneWidget);

      await integrationWaitFor(
        tester,
        find.text(l10n.savedRoutesLoadOnMapButton),
      );
      await tester.tap(find.text(l10n.savedRoutesLoadOnMapButton));
      await integrationPumpFrames(tester);

      await integrationWaitFor(tester, find.text(l10n.mapScreenTitle));
      expect(find.text(l10n.mapPlanningSaveLabel), findsOneWidget);
      expect(find.textContaining('Cathedral Park Boat Ramp'), findsWidgets);
    },
    skip: _skipJourneyTest,
  );
}
