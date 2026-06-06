import 'package:flutter_test/flutter_test.dart';

import 'helpers/eddyscout_integration_harness.dart';

void main() {
  ensureIntegrationTestInitialized();

  testWidgets('shows missing Mapbox token instructions without dart-define', (
    tester,
  ) async {
    await pumpEddyScoutApp(tester);
    await tester.pumpAndSettle(const Duration(seconds: 3));

    expect(find.text('Mapbox token required'), findsOneWidget);
  });
}
