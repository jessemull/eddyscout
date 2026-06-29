import 'package:eddyscout_map/src/presentation/trips_from_here/suggested_trips_entry_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_localized_app.dart';

void main() {
  testWidgets('SuggestedTripsEntryRow renders title and handles tap', (
    tester,
  ) async {
    var tapped = false;

    await tester.pumpWidget(
      testLocalizedApp(
        child: Scaffold(
          body: SuggestedTripsEntryRow(
            title: 'Suggested trips',
            subtitle: '3 nearby launches',
            onTap: () => tapped = true,
          ),
        ),
      ),
    );

    expect(find.text('Suggested trips'), findsOneWidget);
    expect(find.text('3 nearby launches'), findsOneWidget);

    await tester.tap(find.text('Suggested trips'));
    await tester.pump();
    expect(tapped, isTrue);
  });
}
