import 'package:eddyscout_localization/eddyscout_localization.dart';
import 'package:eddyscout_routing/eddyscout_routing.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_localized_app.dart';

void main() {
  testWidgets('LaunchNotFoundScreen renders localized title and body', (
    tester,
  ) async {
    await tester.pumpWidget(
      testLocalizedApp(child: const LaunchNotFoundScreen()),
    );
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(LaunchNotFoundScreen));
    final l10n = context.l10n;

    expect(find.text(l10n.launchNotFoundTitle), findsOneWidget);
    expect(find.text(l10n.launchNotFoundBody), findsOneWidget);
  });
}
