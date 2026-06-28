import 'package:eddyscout_core/eddyscout_core.dart';
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

RoutePlanningStop _catalog(LaunchPoint launch) =>
    RoutePlanningStop.catalog(launch);

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
      expect(container.read(routePlanningProvider).putIn, _catalog(putIn));
      expect(container.read(routePlanningProvider).takeOut, isNull);

      final second = container
          .read(routePlanningProvider.notifier)
          .handleLaunchTap(takeOut);
      expect(second, RoutePlanningTapResult.takeOutSelected);
      expect(container.read(routePlanningProvider).takeOut, _catalog(takeOut));
    });

    test('handleSnapStop adds custom stop', () {
      container.read(routePlanningProvider.notifier).togglePlanningMode();
      const snap = WaterwaySnapPoint(
        latitude: 45.51,
        longitude: -122.61,
        distanceMeters: 12,
      );

      final result = container
          .read(routePlanningProvider.notifier)
          .handleSnapStop(snap, label: 'Custom stop 1');

      expect(result, RoutePlanningTapResult.putInSelected);
      expect(container.read(routePlanningProvider).stops, hasLength(1));
      expect(container.read(routePlanningProvider).stops.first.isSnap, isTrue);
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

    test('clearSelection clears route geometry but keeps start stop', () {
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
      expect(state.stops, [_catalog(putIn)]);
      expect(state.routeLengthKm, isNull);
      expect(state.polylineLonLat, isNull);
    });

    test('applyImportedWaypoints stores polyline and launch picks', () {
      final putIn = _launch(id: 'a');
      final takeOut = _launch(id: 'b');
      final geometry = RouteGeometrySnapshot(
        polylineLonLat: const [
          [-122.7, 45.5],
          [-122.6, 45.4],
        ],
        lengthMeters: 8000,
        computedAt: DateTime.utc(2026),
      );

      container
          .read(routePlanningProvider.notifier)
          .applyImportedWaypoints(
            waypoints: [putIn, takeOut],
            geometry: geometry,
            routeLengthKm: 8.0,
            routeOrigin: RouteOrigin.imported,
          );

      final state = container.read(routePlanningProvider);
      expect(state.planningMode, isTrue);
      expect(state.putIn, _catalog(putIn));
      expect(state.takeOut, _catalog(takeOut));
      expect(state.routeLengthKm, closeTo(8.0, 0.01));
      expect(state.polylineLonLat?.length, 2);
      expect(state.routeOrigin, RouteOrigin.imported);
    });

    test('setActiveGeometry stores polyline on success', () {
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
          );

      final state = container.read(routePlanningProvider);
      expect(state.phase, MapPlanningPhase.routeReady);
      expect(state.routeLengthKm, closeTo(4.2, 0.01));
      expect(state.polylineLonLat?.length, 2);
      expect(state.routeOrigin, RouteOrigin.planner);
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

      expect(container.read(routePlanningProvider).stops, isEmpty);

      container.read(routePlanningProvider.notifier).restoreCapture(capture);

      final restored = container.read(routePlanningProvider);
      expect(restored.planningMode, isTrue);
      expect(restored.stops, [_catalog(putIn), _catalog(takeOut)]);
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

    test('snapshotForSaveFromCapture persists snap stops', () {
      container.read(routePlanningProvider.notifier).togglePlanningMode();
      final putIn = _launch(id: 'a');
      container.read(routePlanningProvider.notifier).handleLaunchTap(putIn);
      container
          .read(routePlanningProvider.notifier)
          .handleSnapStop(
            const WaterwaySnapPoint(
              latitude: 45.51,
              longitude: -122.61,
              distanceMeters: 10,
            ),
            label: 'Mid-river',
          );
      final geometry = RouteGeometrySnapshot(
        polylineLonLat: const [
          [-122.6, 45.5],
          [-122.61, 45.51],
        ],
        lengthMeters: 5000,
        computedAt: DateTime.utc(2026),
      );
      container
          .read(routePlanningProvider.notifier)
          .setActiveGeometry(
            geometry: geometry,
            routeLengthKm: 5,
          );

      final capture = container
          .read(routePlanningProvider.notifier)
          .captureForSave();
      final draft = container
          .read(routePlanningProvider.notifier)
          .snapshotForSaveFromCapture(capture, name: 'Snap route');

      expect(draft, isNotNull);
      expect(draft!.waypoints, hasLength(2));
      expect(draft.waypoints.first, isA<CatalogRouteWaypoint>());
      expect(draft.waypoints.last, isA<SnapRouteWaypoint>());
    });

    test('loadFromSavedRoute restores stops and geometry', () {
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
          RouteWaypoint.catalog(launchId: 'a', order: 0),
          RouteWaypoint.catalog(launchId: 'b', order: 1),
        ],
        metadata: const SavedRouteMetadata(distanceMeters: 5000),
        geometrySnapshot: geometry,
        createdAt: DateTime.utc(2026),
        updatedAt: DateTime.utc(2026),
      );

      container.read(routePlanningProvider.notifier).loadFromSavedRoute(
        saved,
        [_catalog(putIn), _catalog(takeOut)],
      );

      final state = container.read(routePlanningProvider);
      expect(state.planningMode, isTrue);
      expect(state.stops, [_catalog(putIn), _catalog(takeOut)]);
      expect(state.loadedSavedRouteId, 'sr_1');
      expect(state.routeLengthKm, closeTo(5.0, 0.01));
      expect(state.activeGeometry, geometry);
    });

    test('removeStop drops a stop while planning', () {
      container.read(routePlanningProvider.notifier).togglePlanningMode();
      final a = _launch(id: 'a');
      final b = _launch(id: 'b');
      final c = _launch(id: 'c');
      container.read(routePlanningProvider.notifier).handleLaunchTap(a);
      container.read(routePlanningProvider.notifier).handleLaunchTap(b);
      container.read(routePlanningProvider.notifier).handleLaunchTap(c);

      container.read(routePlanningProvider.notifier).removeStop(1);

      expect(
        container.read(routePlanningProvider).stops.map((s) => s.stopId),
        ['a', 'c'],
      );
    });

    test('reorderStops changes stop order', () {
      container.read(routePlanningProvider.notifier).togglePlanningMode();
      final a = _launch(id: 'a');
      final b = _launch(id: 'b');
      final c = _launch(id: 'c');
      container.read(routePlanningProvider.notifier).handleLaunchTap(a);
      container.read(routePlanningProvider.notifier).handleLaunchTap(b);
      container.read(routePlanningProvider.notifier).handleLaunchTap(c);

      container.read(routePlanningProvider.notifier).reorderStops(0, 2);

      expect(
        container.read(routePlanningProvider).stops.map((s) => s.stopId),
        ['b', 'c', 'a'],
      );
    });

    test('restoreStops reverts a failed reorder attempt', () {
      container.read(routePlanningProvider.notifier).togglePlanningMode();
      final a = _launch(id: 'a');
      final b = _launch(id: 'b');
      final c = _launch(id: 'c');
      container.read(routePlanningProvider.notifier).handleLaunchTap(a);
      container.read(routePlanningProvider.notifier).handleLaunchTap(b);
      container.read(routePlanningProvider.notifier).handleLaunchTap(c);
      final previous = container.read(routePlanningProvider).stops;

      container.read(routePlanningProvider.notifier).reorderStops(0, 2);
      container.read(routePlanningProvider.notifier).restoreStops(previous);

      expect(
        container.read(routePlanningProvider).stops.map((s) => s.stopId),
        ['a', 'b', 'c'],
      );
    });

    test('startPlanFromHereTo pre-fills put-in and take-out', () {
      final putIn = _launch(id: 'a', name: 'Put-in');
      final takeOut = _launch(id: 'b', name: 'Take-out');

      container
          .read(routePlanningProvider.notifier)
          .startPlanFromHereTo(
            putIn: putIn,
            takeOut: takeOut,
          );

      final state = container.read(routePlanningProvider);
      expect(state.planningMode, isTrue);
      expect(state.putIn, _catalog(putIn));
      expect(state.takeOut, _catalog(takeOut));
      expect(state.activeGeometry, isNull);
    });

    test('startPlanPaddle seeds put-in in planning phase', () {
      final launch = _launch(id: 'a');
      container.read(routePlanningProvider.notifier).startPlanPaddle(launch);

      final state = container.read(routePlanningProvider);
      expect(state.phase, MapPlanningPhase.planning);
      expect(state.putIn, _catalog(launch));
      expect(state.loadedSavedRouteId, isNull);
    });

    test('selectPlace moves to placeSelected without stops', () {
      final launch = _launch(id: 'a');
      container.read(routePlanningProvider.notifier).selectPlace(launch);

      final state = container.read(routePlanningProvider);
      expect(state.phase, MapPlanningPhase.placeSelected);
      expect(state.stops, isEmpty);
      expect(state.planningMode, isFalse);
    });

    test('restoreStops ignores mismatched stop counts', () {
      container.read(routePlanningProvider.notifier).togglePlanningMode();
      final a = _launch(id: 'a');
      final b = _launch(id: 'b');
      container.read(routePlanningProvider.notifier).handleLaunchTap(a);
      container.read(routePlanningProvider.notifier).handleLaunchTap(b);
      container.read(routePlanningProvider.notifier).reorderStops(0, 1);

      container.read(routePlanningProvider.notifier).restoreStops([
        _catalog(a),
        _catalog(b),
        _catalog(_launch(id: 'c')),
      ]);

      expect(
        container.read(routePlanningProvider).stops.map((s) => s.stopId),
        ['b', 'a'],
      );
    });

    test('removeLastStop drops the final stop', () {
      container.read(routePlanningProvider.notifier).togglePlanningMode();
      final a = _launch(id: 'a');
      final b = _launch(id: 'b');
      container.read(routePlanningProvider.notifier).handleLaunchTap(a);
      container.read(routePlanningProvider.notifier).handleLaunchTap(b);

      container.read(routePlanningProvider.notifier).removeLastStop();

      expect(container.read(routePlanningProvider).stops, [_catalog(a)]);
    });

    test('captureForSave throws when geometry is missing', () {
      container.read(routePlanningProvider.notifier).togglePlanningMode();
      container
          .read(routePlanningProvider.notifier)
          .handleLaunchTap(_launch(id: 'a'));
      container
          .read(routePlanningProvider.notifier)
          .handleLaunchTap(_launch(id: 'b'));

      expect(
        () => container.read(routePlanningProvider.notifier).captureForSave(),
        throwsStateError,
      );
    });

    test('snapshotForSave returns null when route is not ready', () {
      container.read(routePlanningProvider.notifier).togglePlanningMode();
      container
          .read(routePlanningProvider.notifier)
          .handleLaunchTap(_launch(id: 'a'));

      expect(
        container
            .read(routePlanningProvider.notifier)
            .snapshotForSave(
              name: 'Draft',
            ),
        isNull,
      );
    });

    test('snapshotForSave returns draft when route geometry is ready', () {
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
                [-122.5, 45.6],
              ],
              lengthMeters: 5000,
              computedAt: DateTime.utc(2026),
            ),
            routeLengthKm: 5,
          );

      final draft = container
          .read(routePlanningProvider.notifier)
          .snapshotForSave(
            name: 'Afternoon paddle',
            notes: 'Test notes',
          );

      expect(draft, isNotNull);
      expect(draft!.name, 'Afternoon paddle');
      expect(draft.notes, 'Test notes');
    });

    test('clearSelection from placeSelected keeps phase', () {
      container
          .read(routePlanningProvider.notifier)
          .selectPlace(_launch(id: 'a'));
      container.read(routePlanningProvider.notifier).clearSelection();

      expect(
        container.read(routePlanningProvider).phase,
        MapPlanningPhase.placeSelected,
      );
    });

    test(
      'setActiveGeometry from browse enters planning when clearing geometry',
      () {
        container
            .read(routePlanningProvider.notifier)
            .setActiveGeometry(geometry: null, routeLengthKm: null);

        expect(
          container.read(routePlanningProvider).phase,
          MapPlanningPhase.planning,
        );
      },
    );
  });

  group('RoutePlanningState', () {
    test('canFinishPlanning requires geometry and two stops', () {
      const empty = RoutePlanningState();
      expect(empty.canFinishPlanning, isFalse);
      expect(empty.hasRunnableRoute, isFalse);

      final putIn = _launch(id: 'a');
      final takeOut = _launch(id: 'b');
      final withoutGeometry = RoutePlanningState(
        stops: [_catalog(putIn), _catalog(takeOut)],
      );
      expect(withoutGeometry.hasRunnableRoute, isTrue);
      expect(withoutGeometry.canFinishPlanning, isFalse);

      final ready = RoutePlanningState(
        phase: MapPlanningPhase.routeReady,
        stops: [_catalog(putIn), _catalog(takeOut)],
        activeGeometry: RouteGeometrySnapshot(
          polylineLonLat: const [
            [-122.6, 45.5],
            [-122.5, 45.6],
          ],
          lengthMeters: 4200,
          computedAt: DateTime.utc(2026),
        ),
      );
      expect(ready.canFinishPlanning, isTrue);
      expect(ready.putIn, _catalog(putIn));
      expect(ready.takeOut, _catalog(takeOut));
    });

    test('catalogLaunches excludes snap stops', () {
      const snap = RoutePlanningStop.snap(
        id: 'snap_1',
        latitude: 45.51,
        longitude: -122.61,
        label: 'Custom',
      );
      final state = RoutePlanningState(
        stops: [
          _catalog(_launch(id: 'a')),
          snap,
        ],
      );

      expect(state.catalogLaunches, hasLength(1));
      expect(state.catalogLaunches.first.id, 'a');
    });
  });
}
