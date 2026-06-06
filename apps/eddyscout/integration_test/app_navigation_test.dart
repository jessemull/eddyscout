import 'package:flutter_test/flutter_test.dart';

import 'helpers/eddyscout_integration_harness.dart';
import 'helpers/integration_localizations.dart';

void main() {
  ensureIntegrationTestInitialized();

  testWidgets('shows missing Mapbox token instructions without dart-define', (
    tester,
  ) async {
    await pumpEddyScoutApp(tester);
    await tester.pumpAndSettle(const Duration(seconds: 3));

    final l10n = integrationL10n(tester);
    expect(find.text(l10n.missingMapboxTokenTitle), findsOneWidget);
  });
}
