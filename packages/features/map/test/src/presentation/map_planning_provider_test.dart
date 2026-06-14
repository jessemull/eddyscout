import 'package:eddyscout_core/eddyscout_core.dart';
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

    test('clearSelection clears route geometry but keeps start waypoint', () {
      final putIn = _launch(id: 'a');
      container.read(routePlanningProvider.notifier).togglePlanningMode();
      container.read(routePlanningProvider.notifier).handleLaunchTap(putIn);
      container
          .read(routePlanningProvider.notifier)
          .handleLaunchTap(_launch(id: 'b'));
      container
          .read(routePlanningProvider.notifier)
          .setActiveGeometry(
            geometry: RouteGeometrySnapshot(
              polylineLonLat: const [
                [-122.6, 45.5],
                [-122.5, 45.6],
              ],
              lengthMeters: 12500,
              computedAt: DateTime.utc(2026),
            ),
            routeLengthKm: 12.5,
          );

      container.read(routePlanningProvider.notifier).clearSelection();

      final state = container.read(routePlanningProvider);
      expect(state.planningMode, isTrue);
      expect(state.waypoints, [putIn]);
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

    test('setActiveGeometry stores polyline and reach id on success', () {
      container.read(routePlanningProvider.notifier).togglePlanningMode();
      final putIn = _launch(id: 'a');
      final takeOut = _launch(id: 'b');
      container.read(routePlanningProvider.notifier).handleLaunchTap(putIn);
      container.read(routePlanningProvider.notifier).handleLaunchTap(takeOut);

      container
          .read(routePlanningProvider.notifier)
          .setActiveGeometry(
            geometry: RouteGeometrySnapshot(
              polylineLonLat: const [
                [-122.6, 45.5],
                [-122.5, 45.5],
              ],
              lengthMeters: 4200,
              computedAt: DateTime.utc(2026),
            ),
            routeLengthKm: 4.2,
            routeOrigin: RouteOrigin.planner,
            routeReachId: 'columbia_gorge',
          );

      final state = container.read(routePlanningProvider);
      expect(state.phase, MapPlanningPhase.routeReady);
      expect(state.routeLengthKm, closeTo(4.2, 0.01));
      expect(state.polylineLonLat?.length, 2);
      expect(state.routeOrigin, RouteOrigin.planner);
      expect(state.routeReachId, 'columbia_gorge');
    });

    test('setRouteFailure stores failure metadata on error', () {
      container.read(routePlanningProvider.notifier).togglePlanningMode();
      final putIn = _launch(id: 'a');
      final takeOut = _launch(id: 'b');
      container.read(routePlanningProvider.notifier).handleLaunchTap(putIn);
      container.read(routePlanningProvider.notifier).handleLaunchTap(takeOut);

      container
          .read(routePlanningProvider.notifier)
          .setRouteFailure(
            failure: const RouteFailure(
              code: RouteFailureCode.disconnectedReach,
              putInReachId: 'willamette_portland',
              takeOutReachId: 'columbia_gorge',
            ),
          );

      final state = container.read(routePlanningProvider);
      expect(state.phase, MapPlanningPhase.planning);
      expect(state.lastFailureCode, RouteFailureCode.disconnectedReach);
      expect(state.lastFailurePutInReachId, 'willamette_portland');
      expect(state.lastFailureTakeOutReachId, 'columbia_gorge');
    });

    test('setRouteFailure stores river system name for noBundledLine copy', () {
      container.read(routePlanningProvider.notifier).togglePlanningMode();
      final putIn = _launch(id: 'a');
      final takeOut = _launch(id: 'b');

      container.read(routePlanningProvider.notifier).handleLaunchTap(putIn);
      container.read(routePlanningProvider.notifier).handleLaunchTap(takeOut);

      container
          .read(routePlanningProvider.notifier)
          .setRouteFailure(
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

    test('keeps state after listeners are removed', () {
      final sub = container.listen(routePlanningProvider, (_, _) {});

      container.read(routePlanningProvider.notifier).togglePlanningMode();
      expect(container.read(routePlanningProvider).planningMode, isTrue);

      sub.close();

      expect(container.read(routePlanningProvider).planningMode, isTrue);
    });

    test('captureForSave and restoreCapture preserve route geometry', () {
      container.read(routePlanningProvider.notifier).togglePlanningMode();
      final putIn = _launch(id: 'a', name: 'Put-in');
      final takeOut = _launch(id: 'b', name: 'Take-out');
      container.read(routePlanningProvider.notifier).handleLaunchTap(putIn);
      container.read(routePlanningProvider.notifier).handleLaunchTap(takeOut);
      final geometry = RouteGeometrySnapshot(
        polylineLonLat: const [
          [-122.6, 45.5],
          [-122.5, 45.6],
        ],
        lengthMeters: 12500,
        computedAt: DateTime.utc(2026),
      );
      container
          .read(routePlanningProvider.notifier)
          .setActiveGeometry(
            geometry: geometry,
            routeLengthKm: 12.5,
          );

      final capture = container
          .read(routePlanningProvider.notifier)
          .captureForSave();
      container.read(routePlanningProvider.notifier).togglePlanningMode();

      expect(container.read(routePlanningProvider).waypoints, isEmpty);

      container.read(routePlanningProvider.notifier).restoreCapture(capture);

      final restored = container.read(routePlanningProvider);
      expect(restored.planningMode, isTrue);
      expect(restored.waypoints, [putIn, takeOut]);
      expect(restored.routeLengthKm, closeTo(12.5, 0.01));
      expect(restored.activeGeometry, geometry);
    });

    test('snapshotForSaveFromCapture builds draft from frozen capture', () {
      container.read(routePlanningProvider.notifier).togglePlanningMode();
      final putIn = _launch(id: 'a', name: 'Put-in');
      final takeOut = _launch(id: 'b', name: 'Take-out');
      container.read(routePlanningProvider.notifier).handleLaunchTap(putIn);
      container.read(routePlanningProvider.notifier).handleLaunchTap(takeOut);
      final geometry = RouteGeometrySnapshot(
        polylineLonLat: const [
          [-122.6, 45.5],
          [-122.5, 45.6],
        ],
        lengthMeters: 12500,
        computedAt: DateTime.utc(2026),
      );
      container
          .read(routePlanningProvider.notifier)
          .setActiveGeometry(
            geometry: geometry,
            routeLengthKm: 12.5,
          );

      final capture = container
          .read(routePlanningProvider.notifier)
          .captureForSave();
      container.read(routePlanningProvider.notifier).togglePlanningMode();

      final draft = container
          .read(routePlanningProvider.notifier)
          .snapshotForSaveFromCapture(capture, name: 'Morning paddle');

      expect(draft, isNotNull);
      expect(draft!.name, 'Morning paddle');
      expect(draft.waypoints.map((w) => w.launchId), ['a', 'b']);
      expect(draft.geometrySnapshot, geometry);
    });

    test('loadFromSavedRoute restores waypoints and geometry', () {
      final putIn = _launch(id: 'a', name: 'Put-in');
      final takeOut = _launch(id: 'b', name: 'Take-out');
      final geometry = RouteGeometrySnapshot(
        polylineLonLat: const [
          [-122.6, 45.5],
          [-122.5, 45.6],
        ],
        lengthMeters: 5000,
        computedAt: DateTime.utc(2026),
      );
      final saved = SavedRoute(
        id: 'sr_1',
        name: 'Saved',
        waypoints: const [
          RouteWaypoint(launchId: 'a', order: 0),
          RouteWaypoint(launchId: 'b', order: 1),
        ],
        metadata: const SavedRouteMetadata(distanceMeters: 5000),
        geometrySnapshot: geometry,
        createdAt: DateTime.utc(2026),
        updatedAt: DateTime.utc(2026),
      );

      container.read(routePlanningProvider.notifier).loadFromSavedRoute(saved, [
        putIn,
        takeOut,
      ]);

      final state = container.read(routePlanningProvider);
      expect(state.planningMode, isTrue);
      expect(state.waypoints, [putIn, takeOut]);
      expect(state.loadedSavedRouteId, 'sr_1');
      expect(state.routeLengthKm, closeTo(5.0, 0.01));
      expect(state.activeGeometry, geometry);
    });

    test('removeWaypoint drops a stop while planning', () {
      container.read(routePlanningProvider.notifier).togglePlanningMode();
      final a = _launch(id: 'a');
      final b = _launch(id: 'b');
      final c = _launch(id: 'c');
      container.read(routePlanningProvider.notifier).handleLaunchTap(a);
      container.read(routePlanningProvider.notifier).handleLaunchTap(b);
      container.read(routePlanningProvider.notifier).handleLaunchTap(c);

      container.read(routePlanningProvider.notifier).removeWaypoint(1);

      expect(
        container.read(routePlanningProvider).waypoints.map((w) => w.id),
        ['a', 'c'],
      );
    });

    test('reorderWaypoints changes stop order', () {
      container.read(routePlanningProvider.notifier).togglePlanningMode();
      final a = _launch(id: 'a');
      final b = _launch(id: 'b');
      final c = _launch(id: 'c');
      container.read(routePlanningProvider.notifier).handleLaunchTap(a);
      container.read(routePlanningProvider.notifier).handleLaunchTap(b);
      container.read(routePlanningProvider.notifier).handleLaunchTap(c);

      container.read(routePlanningProvider.notifier).reorderWaypoints(0, 2);

      expect(
        container.read(routePlanningProvider).waypoints.map((w) => w.id),
        ['b', 'c', 'a'],
      );
    });
  });

  group('sharedReachIdFromSegments', () {
    test('returns id when all segments share one reach', () {
      final segments = [
        RouteResult.success(
              polylineLonLat: [
                [-122.6, 45.5],
                [-122.5, 45.5],
              ],
              lengthMeters: 1000,
              reachId: 'columbia_gorge',
            )
            as RouteSuccess,
        RouteResult.success(
              polylineLonLat: [
                [-122.5, 45.5],
                [-122.4, 45.5],
              ],
              lengthMeters: 2000,
              reachId: 'columbia_gorge',
            )
            as RouteSuccess,
      ];

      expect(sharedReachIdFromSegments(segments), 'columbia_gorge');
    });

    test('returns null when segments span multiple reaches', () {
      final segments = [
        RouteResult.success(
              polylineLonLat: [
                [-122.6, 45.5],
                [-122.5, 45.5],
              ],
              lengthMeters: 1000,
              reachId: 'willamette_portland',
            )
            as RouteSuccess,
        RouteResult.success(
              polylineLonLat: [
                [-122.5, 45.5],
                [-122.4, 45.5],
              ],
              lengthMeters: 2000,
              reachId: 'columbia_gorge',
            )
            as RouteSuccess,
      ];

      expect(sharedReachIdFromSegments(segments), isNull);
    });
  });
}
