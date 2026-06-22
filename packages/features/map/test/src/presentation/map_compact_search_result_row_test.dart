import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_map/src/presentation/map_compact_search_result_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_localized_app.dart';

void main() {
  testWidgets(
    'MapCompactSearchResultRow uses compact go-no-go layout metrics',
    (
      tester,
    ) async {
      LaunchPoint? selected;

      await tester.pumpWidget(
        testLocalizedApp(
          child: Scaffold(
            body: MapCompactSearchResultRow(
              title: 'Jefferson Street Boat Ramp',
              subtitle: 'Willamette',
              icon: Icons.place_outlined,
              iconColor: Colors.blue,
              onTap: () => selected = const LaunchPoint(
                id: 'jefferson',
                name: 'Jefferson Street Boat Ramp',
                latitude: 45.5,
                longitude: -122.6,
                shortNote: 'Test',
                riverSystem: RiverSystem.willamette,
                windExposure: WindExposure.moderate,
                tideRelevance: TideRelevance.none,
              ),
            ),
          ),
        ),
      );

      final icon = tester.widget<Icon>(find.byIcon(Icons.place_outlined));
      expect(icon.size, kMapCompactListLeadingIconSize);
      expect(icon.color, Colors.blue);

      expect(find.text('Jefferson Street Boat Ramp'), findsOneWidget);
      expect(find.text('Willamette'), findsOneWidget);

      await tester.tap(find.text('Jefferson Street Boat Ramp'));
      await tester.pumpAndSettle();

      expect(selected?.id, 'jefferson');
    },
  );
}
