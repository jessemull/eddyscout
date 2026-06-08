import 'package:eddyscout_hydro_routing/eddyscout_hydro_routing.dart';
import 'package:eddyscout_map/eddyscout_map.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_localized_app.dart';

void main() {
  testWidgets('shows pick put-in step hint', (tester) async {
    await tester.pumpWidget(
      testLocalizedApp(
        child: MapPlanningOverlay(
          phase: RoutePlanningPhase.pickPutIn,
          putIn: null,
          takeOut: null,
          routeLengthKm: null,
          riverSystem: null,
          lastFailureCode: null,
          lastFailurePutInReachId: null,
          lastFailureTakeOutReachId: null,
          onClear: () {},
          onDone: () {},
        ),
      ),
    );

    expect(find.text('Step 1: Tap a launch for put-in.'), findsOneWidget);
  });

  testWidgets('shows computing indicator and route length when ready', (
    tester,
  ) async {
    final putIn = kLaunchPoints.first;
    final takeOut = kLaunchPoints[1];

    await tester.pumpWidget(
      testLocalizedApp(
        child: MapPlanningOverlay(
          phase: RoutePlanningPhase.routeReady,
          putIn: putIn,
          takeOut: takeOut,
          routeLengthKm: 8.2,
          riverSystem: RiverSystem.willamette,
          lastFailureCode: null,
          lastFailurePutInReachId: null,
          lastFailureTakeOutReachId: null,
          onClear: () {},
          onDone: () {},
        ),
      ),
    );

    expect(find.textContaining('Put-in:'), findsOneWidget);
    expect(find.textContaining('Take-out:'), findsOneWidget);
    expect(find.textContaining('8.2 km'), findsOneWidget);
    expect(find.textContaining('willamette'), findsOneWidget);
  });

  testWidgets('shows inline error on routeError phase', (tester) async {
    await tester.pumpWidget(
      testLocalizedApp(
        child: MapPlanningOverlay(
          phase: RoutePlanningPhase.routeError,
          putIn: kLaunchPoints.first,
          takeOut: kLaunchPoints[1],
          routeLengthKm: null,
          riverSystem: null,
          lastFailureCode: RouteFailureCode.disconnectedReach,
          lastFailurePutInReachId: null,
          lastFailureTakeOutReachId: null,
          onClear: () {},
          onDone: () {},
        ),
      ),
    );

    expect(
      find.textContaining('different river segments'),
      findsOneWidget,
    );
  });

  testWidgets('shows named inline error when reach ids are known', (
    tester,
  ) async {
    await tester.pumpWidget(
      testLocalizedApp(
        child: MapPlanningOverlay(
          phase: RoutePlanningPhase.routeError,
          putIn: kLaunchPoints.first,
          takeOut: kLaunchPoints[1],
          routeLengthKm: null,
          riverSystem: null,
          lastFailureCode: RouteFailureCode.disconnectedReach,
          lastFailurePutInReachId: 'willamette_portland',
          lastFailureTakeOutReachId: 'columbia_gorge',
          onClear: () {},
          onDone: () {},
        ),
      ),
    );

    expect(
      find.textContaining('willamette_portland'),
      findsOneWidget,
    );
    expect(
      find.textContaining('columbia_gorge'),
      findsOneWidget,
    );
    expect(
      find.textContaining('different bundled segments'),
      findsOneWidget,
    );
  });

  testWidgets('shows loading indicator while computing', (tester) async {
    await tester.pumpWidget(
      testLocalizedApp(
        child: MapPlanningOverlay(
          phase: RoutePlanningPhase.computingRoute,
          putIn: kLaunchPoints.first,
          takeOut: kLaunchPoints[1],
          routeLengthKm: null,
          riverSystem: null,
          lastFailureCode: null,
          lastFailurePutInReachId: null,
          lastFailureTakeOutReachId: null,
          onClear: () {},
          onDone: () {},
        ),
      ),
    );

    expect(find.text('Calculating route…'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
