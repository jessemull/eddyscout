import 'package:flutter_test/flutter_test.dart';

import '../../integration_test/helpers/eddyscout_integration_harness.dart';
import '../../integration_test/helpers/integration_localizations.dart';

void main() {
  testWidgets('integration harness shows missing Mapbox token screen', (
    tester,
  ) async {
    await pumpEddyScoutApp(tester);
    await tester.pumpAndSettle();

    final l10n = integrationL10n(tester);
    expect(find.text(l10n.missingMapboxTokenTitle), findsOneWidget);
  });
}
