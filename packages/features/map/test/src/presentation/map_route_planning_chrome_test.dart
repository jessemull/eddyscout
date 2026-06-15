import 'package:eddyscout_design_system/eddyscout_design_system.dart';
import 'package:eddyscout_map/eddyscout_map.dart';
import 'package:eddyscout_map/src/presentation/map_route_planning_chrome.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/memory_key_value_store.dart';
import '../../helpers/test_localized_app.dart';

void main() {
  testWidgets('centers Done vertically in the footer band', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: testLocalizedApp(
          child: MapRoutePlanningChrome(
            waypoints: [kLaunchPoints.first],
            routeLengthKm: null,
            onBack: () {},
            onDone: () {},
            onRemoveStop: (_) {},
            onReorderStop: (from, to) {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    const footerHeight = 32 + (Spacing.sm * 2);
    final footerFinder = find.byKey(const Key('map_planning_footer'));
    expect(tester.getSize(footerFinder).height, footerHeight);

    final footerTop = tester.getTopLeft(footerFinder).dy;
    final doneTop = tester.getTopLeft(find.text('Done')).dy;
    final doneHeight = tester.getSize(find.text('Done')).height;
    final doneCenter = doneTop + (doneHeight / 2);
    final footerCenter = footerTop + (footerHeight / 2);

    expect(doneCenter, closeTo(footerCenter, 2));
  });

  testWidgets('aligns footer edges with chrome columns', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: testLocalizedApp(
          child: MapRoutePlanningChrome(
            waypoints: [kLaunchPoints[0], kLaunchPoints[1]],
            routeLengthKm: 5.8,
            onBack: () {},
            onDone: () {},
            onRemoveStop: (_) {},
            onReorderStop: (from, to) {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final totalTripRect = tester.getRect(find.textContaining('Total trip'));
    final doneRect = tester.getRect(find.text('Done'));
    final closeRect = tester.getRect(find.byIcon(Icons.close).first);
    final backArrowRect = tester.getRect(find.byIcon(Icons.arrow_back));

    expect(
      totalTripRect.left,
      closeTo(backArrowRect.left, 2),
    );
    expect(doneRect.right, closeTo(closeRect.right, 2));
  });

  testWidgets('uses personalized paddling speed for trip estimate', (
    tester,
  ) async {
    final store = MemoryKeyValueStore();
    await store.setDouble(kPaddleSpeedKmhKey, 5);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          mapKeyValueStoreProvider.overrideWith((ref) async => store),
        ],
        child: testLocalizedApp(
          child: MapRoutePlanningChrome(
            waypoints: [kLaunchPoints[0], kLaunchPoints[1]],
            routeLengthKm: 5,
            onBack: () {},
            onDone: () {},
            onRemoveStop: (_) {},
            onReorderStop: (from, to) {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Total trip: 60 min'), findsOneWidget);
  });
}
