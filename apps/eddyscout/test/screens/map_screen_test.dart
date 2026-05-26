import 'package:eddyscout/screens/map_planning_provider.dart';
import 'package:eddyscout/screens/map_screen.dart';
import 'package:eddyscout/screens/map_session_provider.dart';
import 'package:eddyscout_map/eddyscout_map.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpMap(
    WidgetTester tester, {
    required List<Override> overrides,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: overrides,
        child: const MaterialApp(
          home: MapScreen(
            mapSlot: SizedBox(key: Key('map_test_stub')),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
  }

  testWidgets('shows app bar and map stub', (tester) async {
    await pumpMap(tester, overrides: []);

    expect(find.text('EddyScout'), findsOneWidget);
    expect(find.byKey(const Key('map_test_stub')), findsOneWidget);
  });

  testWidgets('shows zoom chrome when map is interactive', (tester) async {
    await pumpMap(
      tester,
      overrides: [
        mapInteractiveProvider.overrideWith((ref) => true),
      ],
    );

    expect(find.byTooltip('Zoom in'), findsOneWidget);
    expect(find.byTooltip('Zoom out'), findsOneWidget);
    expect(find.byTooltip('Show all launches'), findsOneWidget);
  });

  testWidgets('hides zoom chrome while map is not interactive', (tester) async {
    await pumpMap(
      tester,
      overrides: [
        mapInteractiveProvider.overrideWith((ref) => false),
      ],
    );

    expect(find.byTooltip('Zoom in'), findsNothing);
  });

  testWidgets('shows route planning overlay when planning mode is on', (
    tester,
  ) async {
    await pumpMap(
      tester,
      overrides: [
        mapInteractiveProvider.overrideWith((ref) => true),
        routePlanningProvider.overrideWith(_FixedRoutePlanning.new),
      ],
    );

    expect(find.text('River route (beta)'), findsOneWidget);
    expect(
      find.textContaining('Put-in: ${kLaunchPoints.first.name}'),
      findsOneWidget,
    );
    expect(
      find.textContaining('Take-out: ${kLaunchPoints[1].name}'),
      findsOneWidget,
    );
    expect(find.textContaining('12.5 km'), findsOneWidget);
  });
}

class _FixedRoutePlanning extends RoutePlanningNotifier {
  @override
  RoutePlanningState build() {
    final putIn = kLaunchPoints.first;
    final takeOut = kLaunchPoints[1];
    return RoutePlanningState(
      planningMode: true,
      putIn: putIn,
      takeOut: takeOut,
      routeLengthKm: 12.5,
    );
  }
}
