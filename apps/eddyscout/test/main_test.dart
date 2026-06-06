import 'package:eddyscout/main.dart';
import 'package:eddyscout/routing/app_routes.dart';
import 'package:eddyscout_routing/eddyscout_routing.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_localized_app.dart';

void main() {
  testWidgets('EddyScoutApp boots with missing Mapbox token route', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          routesProvider.overrideWithValue($appRoutes),
        ],
        child: testLocalizedApp(child: const EddyScoutApp()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Mapbox token required'), findsOneWidget);
  });
}
