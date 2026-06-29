import 'package:eddyscout_map/src/presentation/map_planning_pick_stop_banner.dart';
import 'package:eddyscout_map/src/presentation/map_planning_pick_stop_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_localized_app.dart';

void main() {
  testWidgets('pick stop banner shows prompt and cancel exits mode', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: testLocalizedApp(
          child: MapPlanningPickStopBanner(onCancel: () {}),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Tap the river to add a stop'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
  });

  test('pick stop provider toggles active state', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(mapPlanningPickStopActiveProvider), isFalse);
    container.read(mapPlanningPickStopActiveProvider.notifier).enter();
    expect(container.read(mapPlanningPickStopActiveProvider), isTrue);
    container.read(mapPlanningPickStopActiveProvider.notifier).exit();
    expect(container.read(mapPlanningPickStopActiveProvider), isFalse);
  });
}
