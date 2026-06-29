import 'package:eddyscout_saved_routes/src/presentation/pages/saved_route_detail_distance_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders distance label with semantics', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SavedRouteDetailDistanceSection(
            label: 'Distance',
            distanceLabel: '5.2 km',
          ),
        ),
      ),
    );

    expect(find.text('Distance'), findsOneWidget);
    expect(find.text('5.2 km'), findsOneWidget);
    expect(find.byType(MergeSemantics), findsOneWidget);
  });
}
