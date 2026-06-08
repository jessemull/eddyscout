import 'package:eddyscout_hydro_routing/eddyscout_hydro_routing.dart';
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

      expect(
        container.read(routePlanningProvider).phase,
        RoutePlanningPhase.pickPutIn,
      );

      final first = container
          .read(routePlanningProvider.notifier)
          .handleLaunchTap(putIn);
      expect(first, RoutePlanningTapResult.putInSelected);
      expect(container.read(routePlanningProvider).putIn, putIn);
      expect(container.read(routePlanningProvider).takeOut, isNull);
      expect(
        container.read(routePlanningProvider).phase,
        RoutePlanningPhase.pickTakeOut,
      );

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

    test('clearSelection resets picks and phase but keeps planning mode', () {
      container.read(routePlanningProvider.notifier).togglePlanningMode();
      container
          .read(routePlanningProvider.notifier)
          .handleLaunchTap(_launch(id: 'a'));
      container
          .read(routePlanningProvider.notifier)
          .setPlannedRoute(
            polylineLonLat: [
              [-122.7, 45.5],
              [-122.6, 45.4],
            ],
            routeLengthKm: 12.5,
            routeOrigin: RouteOrigin.planner,
          );

      container.read(routePlanningProvider.notifier).clearSelection();

      final state = container.read(routePlanningProvider);
      expect(state.planningMode, isTrue);
      expect(state.phase, RoutePlanningPhase.pickPutIn);
      expect(state.putIn, isNull);
      expect(state.takeOut, isNull);
      expect(state.routeLengthKm, isNull);
      expect(state.polylineLonLat, isNull);
    });

    test('applyImportedRoute stores polyline and launch picks', () {
      final putIn = _launch(id: 'a');
      final takeOut = _launch(id: 'b');
      final route = PlannedRoute(
        points: const [
          GpxPoint(latitude: 45.5, longitude: -122.7),
          GpxPoint(latitude: 45.4, longitude: -122.6),
        ],
        putIn: putIn,
        takeOut: takeOut,
        lengthMeters: 8000,
        origin: RouteOrigin.imported,
      );

      container.read(routePlanningProvider.notifier).applyImportedRoute(route);

      final state = container.read(routePlanningProvider);
      expect(state.planningMode, isTrue);
      expect(state.putIn, putIn);
      expect(state.takeOut, takeOut);
      expect(state.routeLengthKm, closeTo(8.0, 0.01));
      expect(state.polylineLonLat?.length, 2);
      expect(state.routeOrigin, RouteOrigin.imported);
    });

    test('setPlannedRoute stores polyline on success', () {
      container.read(routePlanningProvider.notifier).togglePlanningMode();
      final putIn = _launch(id: 'a');
      final takeOut = _launch(id: 'b');

      container
          .read(routePlanningProvider.notifier)
          .setPlannedRoute(
            polylineLonLat: const [
              [-122.6, 45.5],
              [-122.5, 45.5],
            ],
            routeLengthKm: 4.2,
            routeOrigin: RouteOrigin.planner,
            putIn: putIn,
            takeOut: takeOut,
            phase: RoutePlanningPhase.routeReady,
          );

      final state = container.read(routePlanningProvider);
      expect(state.phase, RoutePlanningPhase.routeReady);
      expect(state.routeLengthKm, closeTo(4.2, 0.01));
      expect(state.polylineLonLat?.length, 2);
      expect(state.routeOrigin, RouteOrigin.planner);
    });

    test(
      'revertFromComputingRoute returns to pickTakeOut with selections kept',
      () {
        container.read(routePlanningProvider.notifier).togglePlanningMode();
        final putIn = _launch(id: 'a');
        final takeOut = _launch(id: 'b');
        container.read(routePlanningProvider.notifier).handleLaunchTap(putIn);
        container.read(routePlanningProvider.notifier).handleLaunchTap(takeOut);
        container.read(routePlanningProvider.notifier).setComputingRoute();

        container
            .read(routePlanningProvider.notifier)
            .revertFromComputingRoute();

        final state = container.read(routePlanningProvider);
        expect(state.phase, RoutePlanningPhase.pickTakeOut);
        expect(state.putIn, putIn);
        expect(state.takeOut, takeOut);
      },
    );

    test('setRouteFailure stores failure code on error', () {
      container.read(routePlanningProvider.notifier).togglePlanningMode();
      final putIn = _launch(id: 'a');
      final takeOut = _launch(id: 'b');

      container
          .read(routePlanningProvider.notifier)
          .setRouteFailure(
            putIn: putIn,
            takeOut: takeOut,
            failure: const RouteFailure(
              code: RouteFailureCode.disconnectedReach,
              putInReachId: 'willamette_portland',
              takeOutReachId: 'columbia_gorge',
            ),
          );

      final state = container.read(routePlanningProvider);
      expect(state.phase, RoutePlanningPhase.routeError);
      expect(state.lastFailureCode, RouteFailureCode.disconnectedReach);
      expect(state.lastFailurePutInReachId, 'willamette_portland');
      expect(state.lastFailureTakeOutReachId, 'columbia_gorge');
    });

    test('setRouteFailure stores river system name for noBundledLine copy', () {
      container.read(routePlanningProvider.notifier).togglePlanningMode();
      final putIn = _launch(id: 'a');
      final takeOut = _launch(id: 'b');

      container
          .read(routePlanningProvider.notifier)
          .setRouteFailure(
            putIn: putIn,
            takeOut: takeOut,
            failure: const RouteFailure(
              code: RouteFailureCode.noBundledLine,
              riverSystemName: 'slough',
            ),
          );

      expect(
        container.read(routePlanningProvider).lastFailureRiverSystemName,
        'slough',
      );
    });

    test('setPlannedRoute stores route reach id on success', () {
      container.read(routePlanningProvider.notifier).togglePlanningMode();

      container
          .read(routePlanningProvider.notifier)
          .setPlannedRoute(
            polylineLonLat: const [
              [-122.6, 45.5],
              [-122.5, 45.5],
            ],
            routeLengthKm: 4.2,
            routeOrigin: RouteOrigin.planner,
            routeReachId: 'columbia_gorge',
            phase: RoutePlanningPhase.routeReady,
          );

      expect(
        container.read(routePlanningProvider).routeReachId,
        'columbia_gorge',
      );
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
