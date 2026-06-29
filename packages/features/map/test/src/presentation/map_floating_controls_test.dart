import 'package:eddyscout_map/eddyscout_map.dart';
import 'package:eddyscout_map/src/presentation/map_floating_controls.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_localized_app.dart';

void main() {
  testWidgets('MapZoomControls invokes controller zoom actions', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          mapboxMapControllerProvider.overrideWith(MapboxMapController.new),
        ],
        child: testLocalizedApp(
          child: Consumer(
            builder: (context, ref, _) {
              final controller = ref.read(mapboxMapControllerProvider.notifier);
              return Scaffold(
                body: MapZoomControls(controller: controller),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();
    await tester.tap(find.byIcon(Icons.remove));
    await tester.pump();
    await tester.tap(find.byIcon(Icons.zoom_out_map));
    await tester.pump();

    expect(find.byIcon(Icons.add), findsOneWidget);
  });

  testWidgets('MapLocateControl renders locate button', (tester) async {
    await tester.pumpWidget(
      testLocalizedApp(
        child: const Scaffold(
          body: MapLocateControl(),
        ),
      ),
    );

    expect(find.byIcon(Icons.my_location), findsOneWidget);
  });

  testWidgets('MapFloatingControls stacks zoom and locate controls', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          mapboxMapControllerProvider.overrideWith(MapboxMapController.new),
        ],
        child: testLocalizedApp(
          child: Consumer(
            builder: (context, ref, _) {
              final controller = ref.read(mapboxMapControllerProvider.notifier);
              return Scaffold(
                body: MapFloatingControls(
                  bottomPadding: 16,
                  controller: controller,
                  showZoomChrome: true,
                ),
              );
            },
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.add), findsOneWidget);
    expect(find.byIcon(Icons.my_location), findsOneWidget);
  });
}
