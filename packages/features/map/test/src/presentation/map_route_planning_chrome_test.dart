import 'package:eddyscout_design_system/eddyscout_design_system.dart';
import 'package:eddyscout_map/eddyscout_map.dart';
import 'package:eddyscout_map/src/presentation/map_route_planning_chrome.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

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

    const footerHeight = 32 + (Spacing.md * 2);
    final footerFinder = find.byKey(const Key('map_planning_footer'));
    expect(tester.getSize(footerFinder).height, footerHeight);

    final footerTop = tester.getTopLeft(footerFinder).dy;
    final doneTop = tester.getTopLeft(find.text('Done')).dy;
    final doneHeight = tester.getSize(find.text('Done')).height;
    final doneCenter = doneTop + (doneHeight / 2);
    final footerCenter = footerTop + (footerHeight / 2);

    expect(doneCenter, closeTo(footerCenter, 2));
  });
}
