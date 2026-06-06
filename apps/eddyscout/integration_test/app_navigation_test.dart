import 'package:eddyscout/main.dart';
import 'package:eddyscout_hydro_routing/eddyscout_hydro_routing.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../test/routing/test_router_overrides.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('app shell renders map or token instructions', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ...appRouterTestOverrides,
          hydroGeoJsonLoaderProvider.overrideWithValue(
            () => rootBundle.loadString(
              'assets/hydro/willamette_waterway.geojson',
            ),
          ),
        ],
        child: const EddyScoutApp(),
      ),
    );
    await tester.pumpAndSettle(const Duration(seconds: 3));
    expect(
      find.byType(MaterialApp),
      findsOneWidget,
    );
  });
}
