import 'package:eddyscout/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('EddyScoutApp boots under ProviderScope', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: EddyScoutApp(mapboxAccessToken: '')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Mapbox token required'), findsOneWidget);
  });
}
