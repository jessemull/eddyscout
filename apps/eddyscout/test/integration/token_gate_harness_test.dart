import 'package:flutter_test/flutter_test.dart';

import '../../integration_test/helpers/eddyscout_integration_harness.dart';
import '../../integration_test/helpers/integration_localizations.dart';
import '../../integration_test/helpers/integration_pump.dart';

void main() {
  testWidgets('integration harness shows missing Mapbox token screen', (
    tester,
  ) async {
    await pumpEddyScoutApp(tester);
    await integrationPumpFrames(tester, count: 5);

    final l10n = integrationL10n(tester);
    await integrationWaitFor(tester, find.text(l10n.missingMapboxTokenTitle));
    expect(find.text(l10n.missingMapboxTokenTitle), findsOneWidget);
  });
}
