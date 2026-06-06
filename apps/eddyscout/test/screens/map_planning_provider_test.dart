import 'package:eddyscout/screens/map_planning_provider.dart';
import 'package:eddyscout_map/eddyscout_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

LaunchPoint _launch({required String id, String name = 'Test Launch'}) {
  return LaunchPoint(
    id: id,
    name: name,
    latitude: 45.5,
    longitude: -122.6,
    shortNote: 'Test',
    riverSystem: RiverSystem.willamette,
    windExposure: WindExposure.moderate,
    tideRelevance: TideRelevance.none,
  );
}

void main() {
  group('routePlanningProvider', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('starts with planning mode off', () {
      expect(container.read(routePlanningProvider).planningMode, isFalse);
    });

    test('togglePlanningMode enables and disables planning', () {
      container.read(routePlanningProvider.notifier).togglePlanningMode();
      expect(container.read(routePlanningProvider).planningMode, isTrue);

      container.read(routePlanningProvider.notifier).togglePlanningMode();
      expect(container.read(routePlanningProvider).planningMode, isFalse);
    });

    test('handleLaunchTap selects put-in then take-out', () {
      container.read(routePlanningProvider.notifier).togglePlanningMode();
      final putIn = _launch(id: 'a', name: 'Put-in');
      final takeOut = _launch(id: 'b', name: 'Take-out');

      final first = container
          .read(routePlanningProvider.notifier)
          .handleLaunchTap(putIn);
      expect(first, RoutePlanningTapResult.putInSelected);
      expect(container.read(routePlanningProvider).putIn, putIn);
      expect(container.read(routePlanningProvider).takeOut, isNull);

      final second = container
          .read(routePlanningProvider.notifier)
          .handleLaunchTap(takeOut);
      expect(second, RoutePlanningTapResult.takeOutSelected);
      expect(container.read(routePlanningProvider).takeOut, takeOut);
    });

    test('handleLaunchTap rejects same launch for take-out', () {
      container.read(routePlanningProvider.notifier).togglePlanningMode();
      final launch = _launch(id: 'a');

      container.read(routePlanningProvider.notifier).handleLaunchTap(launch);
      final result = container
          .read(routePlanningProvider.notifier)
          .handleLaunchTap(launch);

      expect(result, RoutePlanningTapResult.sameAsPutIn);
      expect(container.read(routePlanningProvider).takeOut, isNull);
    });

    test('clearSelection resets picks but keeps planning mode', () {
      container.read(routePlanningProvider.notifier).togglePlanningMode();
      container
          .read(routePlanningProvider.notifier)
          .handleLaunchTap(_launch(id: 'a'));
      container.read(routePlanningProvider.notifier).setRouteLengthKm(12.5);

      container.read(routePlanningProvider.notifier).clearSelection();

      final state = container.read(routePlanningProvider);
      expect(state.planningMode, isTrue);
      expect(state.putIn, isNull);
      expect(state.takeOut, isNull);
      expect(state.routeLengthKm, isNull);
    });

    test('keeps state after listeners are removed', () {
      final sub = container.listen(routePlanningProvider, (_, _) {});

      container.read(routePlanningProvider.notifier).togglePlanningMode();
      expect(container.read(routePlanningProvider).planningMode, isTrue);

      sub.close();

      expect(container.read(routePlanningProvider).planningMode, isTrue);
    });
  });
}
