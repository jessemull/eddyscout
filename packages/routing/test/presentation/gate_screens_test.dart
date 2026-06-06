import 'package:eddyscout_routing/eddyscout_routing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_localized_app.dart';

void main() {
  group('MissingMapboxTokenScreen', () {
    testWidgets('renders token setup guidance', (tester) async {
      await tester.pumpWidget(
        testLocalizedApp(child: const MissingMapboxTokenScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.byType(MissingMapboxTokenScreen), findsOneWidget);
      expect(find.textContaining('MAPBOX_ACCESS_TOKEN'), findsWidgets);
    });
  });

  group('WebMapPlaceholderScreen', () {
    testWidgets('renders web placeholder body', (tester) async {
      await tester.pumpWidget(
        testLocalizedApp(child: const WebMapPlaceholderScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.byType(WebMapPlaceholderScreen), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });
  });
}
