import 'package:eddyscout/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('EddyScoutApp boots with missing Mapbox token route', (
    tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: EddyScoutApp()));
    await tester.pumpAndSettle();

    expect(find.text('Mapbox token required'), findsOneWidget);
  });
}
