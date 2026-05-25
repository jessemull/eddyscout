import 'package:eddyscout/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

void main() {
  setUp(() {
    MapboxOptions.setAccessToken('');
  });

  testWidgets('Shows token instructions when MAPBOX_ACCESS_TOKEN is empty', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: EddyScoutApp()));
    await tester.pumpAndSettle();

    expect(find.textContaining('MAPBOX_ACCESS_TOKEN'), findsWidgets);
    expect(find.textContaining('Mapbox'), findsWidgets);
  });
}
