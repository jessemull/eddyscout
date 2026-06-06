import 'package:flutter_test/flutter_test.dart';

import 'helpers/eddyscout_integration_harness.dart';
import 'helpers/integration_localizations.dart';
import 'helpers/integration_pump.dart';

void main() {
  ensureIntegrationTestInitialized();

  testWidgets('shows missing Mapbox token instructions without dart-define', (
    tester,
  ) async {
    await pumpEddyScoutApp(tester);
    await integrationPumpFrames(tester, count: 5);

    final l10n = integrationL10n(tester);
    await integrationWaitFor(tester, find.text(l10n.missingMapboxTokenTitle));
  });
}
