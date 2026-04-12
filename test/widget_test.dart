import 'package:flutter_test/flutter_test.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import 'package:eddyscout/main.dart';

void main() {
  setUp(() {
    MapboxOptions.setAccessToken('');
  });

  testWidgets('Shows token instructions when MAPBOX_ACCESS_TOKEN is empty', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const EddyScoutApp(mapboxAccessToken: ''));
    await tester.pumpAndSettle();

    expect(find.textContaining('MAPBOX_ACCESS_TOKEN'), findsWidgets);
    expect(find.textContaining('Mapbox'), findsWidgets);
  });
}
