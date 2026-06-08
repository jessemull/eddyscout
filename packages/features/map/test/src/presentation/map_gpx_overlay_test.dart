import 'package:eddyscout_map/eddyscout_map.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_localized_app.dart';

void main() {
  testWidgets('shows import always and disables export without polyline', (
    tester,
  ) async {
    await tester.pumpWidget(
      testLocalizedApp(
        child: Material(
          child: MapPlanningOverlay(
            phase: RoutePlanningPhase.pickTakeOut,
            putIn: kLaunchPoints.first,
            takeOut: null,
            routeLengthKm: null,
            riverSystem: null,
            lastFailureCode: null,
            canExportGpx: false,
            gpxBusy: false,
            onClear: () {},
            onDone: () {},
            onExportGpx: () {},
            onImportGpx: () {},
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Import GPX'), findsOneWidget);
    final exportButton = tester.widget<TextButton>(
      find.widgetWithText(TextButton, 'Export GPX'),
    );
    expect(exportButton.onPressed, isNull);
  });

  testWidgets('enables export when polyline is available', (tester) async {
    var exported = false;

    await tester.pumpWidget(
      testLocalizedApp(
        child: Material(
          child: MapPlanningOverlay(
            phase: RoutePlanningPhase.routeReady,
            putIn: kLaunchPoints.first,
            takeOut: kLaunchPoints[1],
            routeLengthKm: 8.2,
            riverSystem: kLaunchPoints.first.riverSystem,
            lastFailureCode: null,
            canExportGpx: true,
            gpxBusy: false,
            onClear: () {},
            onDone: () {},
            onExportGpx: () => exported = true,
            onImportGpx: () {},
          ),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Export GPX'));
    await tester.pump();

    expect(exported, isTrue);
  });
}
