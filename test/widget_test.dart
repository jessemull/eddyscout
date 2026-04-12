import 'package:flutter_test/flutter_test.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import 'package:eddyscout/main.dart';

void main() {
  setUp(() {
    MapboxOptions.setAccessToken('');
  });

  testWidgets('Shows token instructions when ACCESS_TOKEN is empty', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const EddyScoutApp(accessToken: ''));
    await tester.pumpAndSettle();

    expect(find.textContaining('ACCESS_TOKEN'), findsWidgets);
    expect(find.textContaining('Mapbox'), findsWidgets);
  });
}
