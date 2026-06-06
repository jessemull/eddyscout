import 'package:eddyscout/main.dart';
import 'package:eddyscout/routing/app_routes.dart';
import 'package:eddyscout_routing/eddyscout_routing.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Shows token instructions when MAPBOX_ACCESS_TOKEN is empty', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          routesProvider.overrideWithValue($appRoutes),
        ],
        child: const EddyScoutApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('MAPBOX_ACCESS_TOKEN'), findsWidgets);
    expect(find.textContaining('Mapbox'), findsWidgets);
  });
}
