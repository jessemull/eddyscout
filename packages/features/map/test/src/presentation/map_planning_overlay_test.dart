import 'package:eddyscout_hydro_routing/eddyscout_hydro_routing.dart';
import 'package:eddyscout_map/eddyscout_map.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_localized_app.dart';

MapPlanningOverlay _overlay({
  required RoutePlanningPhase phase,
  LaunchPoint? putIn,
  LaunchPoint? takeOut,
  double? routeLengthKm,
  RiverSystem? riverSystem,
  RouteFailureCode? lastFailureCode,
  String? lastFailureRiverSystemName,
  String? lastFailurePutInReachId,
  String? lastFailureTakeOutReachId,
  String? routeReachId,
  bool canExportGpx = false,
}) {
  return MapPlanningOverlay(
    phase: phase,
    putIn: putIn,
    takeOut: takeOut,
    routeLengthKm: routeLengthKm,
    riverSystem: riverSystem,
    lastFailureCode: lastFailureCode,
    lastFailureRiverSystemName: lastFailureRiverSystemName,
    lastFailurePutInReachId: lastFailurePutInReachId,
    lastFailureTakeOutReachId: lastFailureTakeOutReachId,
    routeReachId: routeReachId,
    canExportGpx: canExportGpx,
    gpxBusy: false,
    onClear: () {},
    onDone: () {},
    onExportGpx: () {},
    onImportGpx: () {},
  );
}

void main() {
  testWidgets('shows pick put-in step hint', (tester) async {
    await tester.pumpWidget(
      testLocalizedApp(
        child: _overlay(phase: RoutePlanningPhase.pickPutIn),
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
        child: _overlay(
          phase: RoutePlanningPhase.routeReady,
          putIn: putIn,
          takeOut: takeOut,
          routeLengthKm: 8.2,
          riverSystem: RiverSystem.willamette,
          canExportGpx: true,
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
        child: _overlay(
          phase: RoutePlanningPhase.routeError,
          putIn: kLaunchPoints.first,
          takeOut: kLaunchPoints[1],
          lastFailureCode: RouteFailureCode.disconnectedReach,
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
        child: _overlay(
          phase: RoutePlanningPhase.routeError,
          putIn: kLaunchPoints.first,
          takeOut: kLaunchPoints[1],
          lastFailureCode: RouteFailureCode.disconnectedReach,
          lastFailurePutInReachId: 'willamette_portland',
          lastFailureTakeOutReachId: 'columbia_gorge',
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
        child: _overlay(
          phase: RoutePlanningPhase.computingRoute,
          putIn: kLaunchPoints.first,
          takeOut: kLaunchPoints[1],
        ),
      ),
    );

    expect(find.text('Calculating route…'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows bundled reach id when route is ready', (tester) async {
    await tester.pumpWidget(
      testLocalizedApp(
        child: _overlay(
          phase: RoutePlanningPhase.routeReady,
          putIn: kLaunchPoints.first,
          takeOut: kLaunchPoints[1],
          routeLengthKm: 8.2,
          riverSystem: RiverSystem.columbia,
          routeReachId: 'columbia_gorge',
        ),
      ),
    );

    expect(find.textContaining('columbia_gorge'), findsOneWidget);
    expect(find.textContaining('Bundled reach'), findsOneWidget);
  });

  testWidgets('shows noBundledLine inline copy with river system name', (
    tester,
  ) async {
    await tester.pumpWidget(
      testLocalizedApp(
        child: _overlay(
          phase: RoutePlanningPhase.routeError,
          putIn: kLaunchPoints.first,
          takeOut: kLaunchPoints[1],
          lastFailureCode: RouteFailureCode.noBundledLine,
          lastFailureRiverSystemName: 'slough',
        ),
      ),
    );

    expect(find.textContaining('slough'), findsOneWidget);
    expect(find.textContaining('No bundled river line'), findsOneWidget);
  });
}
