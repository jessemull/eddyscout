import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_map/src/presentation/map_route_preview_bar.dart';
import 'package:eddyscout_persistence/eddyscout_persistence.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_localized_app.dart';

void main() {
  testWidgets('shows metric route length when units preference is metric', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          effectiveDisplayUnitSystemProvider.overrideWithValue(
            DisplayUnitSystem.metric,
          ),
        ],
        child: testLocalizedApp(
          child: Scaffold(
            body: MapRoutePreviewBar(
              tripTimeLabel: 'Trip time: 63 min',
              routeLengthKm: 4.2,
              canSave: true,
              onBack: () {},
              onDismiss: () {},
              onStart: () {},
              onSave: () {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('4.2 km'), findsOneWidget);
  });

  testWidgets('omits route length when distance is null', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: testLocalizedApp(
          child: Scaffold(
            body: MapRoutePreviewBar(
              tripTimeLabel: 'Trip time: 63 min',
              routeLengthKm: null,
              canSave: false,
              onBack: () {},
              onDismiss: () {},
              onStart: () {},
              onSave: () {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Along river'), findsNothing);
  });

  testWidgets('shows imperial route length when units preference is imperial', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          effectiveDisplayUnitSystemProvider.overrideWithValue(
            DisplayUnitSystem.imperial,
          ),
        ],
        child: testLocalizedApp(
          child: Scaffold(
            body: MapRoutePreviewBar(
              tripTimeLabel: 'Trip time: 63 min',
              routeLengthKm: 4.2,
              canSave: true,
              onBack: () {},
              onDismiss: () {},
              onStart: () {},
              onSave: () {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('2.6 mi'), findsOneWidget);
  });
}
