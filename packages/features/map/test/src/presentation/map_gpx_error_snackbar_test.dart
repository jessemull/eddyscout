import 'package:eddyscout_analytics/eddyscout_analytics.dart';
import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_localization/eddyscout_localization.dart';
import 'package:eddyscout_map/eddyscout_map.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/test_hydro_map_providers.dart';
import '../../helpers/test_localized_app.dart';

class _MockGpxFileGateway extends Mock implements GpxFileGateway {}

const _outsidePnwGpx = '''
<?xml version="1.0" encoding="UTF-8"?>
<gpx version="1.1" creator="test">
  <trk><trkseg>
    <trkpt lat="40.0" lon="-74.0"/>
    <trkpt lat="41.0" lon="-75.0"/>
  </trkseg></trk>
</gpx>''';

const _pnwFarFromLaunchesGpx = '''
<?xml version="1.0" encoding="UTF-8"?>
<gpx version="1.1" creator="test">
  <trk><trkseg>
    <trkpt lat="44.058" lon="-121.315"/>
    <trkpt lat="44.060" lon="-121.310"/>
  </trkseg></trk>
</gpx>''';

Future<void> _pumpGpxImportButton(
  WidgetTester tester, {
  required _MockGpxFileGateway gateway,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        gpxFileGatewayProvider.overrideWithValue(gateway),
        analyticsClientProvider.overrideWithValue(RecordingAnalyticsClient()),
        testHydroMapGpxServiceOverride(),
        mapboxMapControllerProvider.overrideWith(MapboxMapController.new),
      ],
      child: testLocalizedApp(
        child: Consumer(
          builder: (context, ref, _) {
            return Scaffold(
              body: FilledButton(
                onPressed: () async {
                  final outcome = await ref
                      .read(gpxActionsProvider.notifier)
                      .importRoute();
                  if (!context.mounted) {
                    return;
                  }
                  final l10n = context.l10n;
                  switch (outcome) {
                    case GpxActionCancelled():
                      return;
                    case GpxActionSuccess():
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.mapGpxImportSuccess)),
                      );
                    case GpxActionFailure(:final failure):
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            localizeGpxActionFailure(
                              l10n: l10n,
                              failure: failure,
                            ),
                          ),
                        ),
                      );
                  }
                },
                child: Text(context.l10n.menuImportGpx),
              ),
            );
          },
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('shows localized snackbar when GPX import is malformed', (
    tester,
  ) async {
    final gateway = _MockGpxFileGateway();
    when(gateway.pickAndReadGpx).thenAnswer(
      (_) async => const Result.success('<<<not gpx xml>>>'),
    );

    await _pumpGpxImportButton(tester, gateway: gateway);

    await tester.tap(find.text('Import GPX'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Could not read that GPX file.'), findsOneWidget);
  });

  testWidgets(
    'shows PNW failure snackbar when track is outside bbox',
    (tester) async {
      final gateway = _MockGpxFileGateway();
      when(gateway.pickAndReadGpx).thenAnswer(
        (_) async => const Result.success(_outsidePnwGpx),
      );

      await _pumpGpxImportButton(tester, gateway: gateway);

      await tester.tap(find.text('Import GPX'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Track imported.'), findsNothing);
      expect(
        find.text('This track is outside our Pacific Northwest focus area.'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'shows launch snap failure snackbar when endpoints do not match catalog',
    (tester) async {
      final gateway = _MockGpxFileGateway();
      when(gateway.pickAndReadGpx).thenAnswer(
        (_) async => const Result.success(_pnwFarFromLaunchesGpx),
      );

      await _pumpGpxImportButton(tester, gateway: gateway);

      await tester.tap(find.text('Import GPX'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Track imported.'), findsNothing);
      expect(
        find.text(
          'Put-in and take-out could not be matched to known launches.',
        ),
        findsOneWidget,
      );
    },
  );
}
