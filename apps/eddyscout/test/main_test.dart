import 'package:eddyscout/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_localized_app.dart';

void main() {
  testWidgets('EddyScoutApp boots with missing Mapbox token route', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: testLocalizedApp(child: const EddyScoutApp()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Mapbox token required'), findsOneWidget);
  });
}
