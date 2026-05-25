import 'dart:async' show unawaited;
import 'dart:convert' show jsonEncode;

import 'package:eddyscout/debug/map_debug_log.dart';
import 'package:eddyscout/screens/map/map_constants.dart';
import 'package:eddyscout/screens/map/map_ui_callbacks.dart';
import 'package:eddyscout/screens/map_planning_provider.dart';
import 'package:eddyscout/screens/map_session_provider.dart';
import 'package:eddyscout_hydro_routing/eddyscout_hydro_routing.dart';
import 'package:eddyscout_map/eddyscout_map.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

/// Owns Mapbox map lifecycle: markers, route line, camera, and launch taps.
class MapboxMapController extends AutoDisposeNotifier<void> {
  MapUiCallbacks _ui = const MapUiCallbacks();

  /// Snackbar and navigation hooks from the map screen (set after first frame).
  // ignore: use_setters_to_change_properties -- setter triggers conflicting lints.
  void bindUiCallbacks(MapUiCallbacks callbacks) => _ui = callbacks;

  MapboxMap? _mapboxMap;
  Cancelable? _tapCancelable;
  bool _markersInstalled = false;
  late CircleAnnotationManager? _circleManager;
  bool _mapDiagnosticsLogged = false;

  double? _debugLastLoggedCameraZoom;
  int _debugLastCameraChangeLogMs = 0;
  bool _alive = true;

  @override
  void build() {
    _alive = true;
    ref.onDispose(() {
      _alive = false;
      _tapCancelable?.cancel();
    });
  }

  Future<void> onMapCreated(MapboxMap mapboxMap) async {
    _mapboxMap = mapboxMap;
    mapDebugLog('onMapCreated (initial camera from MapWidget viewport)');
    await mapDebugLogMapboxSnapshot(
      mapboxMap,
      'onMapCreated',
      includeGestures: true,
    );
  }

  void onStyleLoaded() {
    if (!_mapDiagnosticsLogged) {
      _mapDiagnosticsLogged = true;
      mapDebugLogLaunchPairsWithin(400);
    }
    unawaited(_installLaunchMarkersIfNeeded());
  }

  void onDebugCameraChanged(CameraChangedEventData e) {
    if (!kDebugMode) {
      return;
    }
    final z = e.cameraState.zoom;
    final now = DateTime.now().millisecondsSinceEpoch;
    final prev = _debugLastLoggedCameraZoom;
    final dz = prev == null ? 999.0 : (z - prev).abs();
    final bigJump = prev != null && dz >= 0.45;
    if (!bigJump && dz < 0.04 && now - _debugLastCameraChangeLogMs < 400) {
      return;
    }
    if (bigJump) {
      mapDebugLogTs('CAMERA_CHANGED BIG_JUMP dz=${dz.toStringAsFixed(2)}');
    }
    _debugLastLoggedCameraZoom = z;
    _debugLastCameraChangeLogMs = now;
    final c = e.cameraState.center.coordinates;
    mapDebugLog(
      'CAMERA_CHANGED zoom=${z.toStringAsFixed(2)} '
      'center=(${c.lng.toStringAsFixed(4)},${c.lat.toStringAsFixed(4)})',
    );
    final m = _mapboxMap;
    if (m == null) {
      return;
    }
    unawaited(() async {
      try {
        mapDebugLog(
          'CAMERA_CHANGED isGestureInProgress=${await m.isGestureInProgress()}',
        );
      } on Object catch (_) {}
    }());
  }

  void onDebugMapZoomEnded(MapContentGestureContext ctx) {
    if (ctx.gestureState != GestureState.ended) {
      return;
    }
    mapDebugLog(
      'MAP ZOOM gesture ended | '
      'screen=(${ctx.touchPosition.x.toStringAsFixed(0)},'
      '${ctx.touchPosition.y.toStringAsFixed(0)})',
    );
    final m = _mapboxMap;
    if (m == null) {
      return;
    }
    unawaited(
      mapDebugLogMapboxSnapshot(
        m,
        'after user pinch/zoom',
        includeGestures: true,
      ),
    );
  }

  void onLaunchCircleTap(CircleAnnotation annotation) {
    final raw = annotation.customData?['launchId'];
    if (raw is! String) {
      return;
    }
    final launch = launchPointById(raw);
    if (launch == null) {
      return;
    }

    final planning = ref.read(routePlanningProvider);
    if (!planning.planningMode) {
      _ui.openLaunchDetail?.call(launch);
      return;
    }

    _handlePlanningTap(launch);
  }

  void togglePlanningMode() {
    final wasPlanning = ref.read(routePlanningProvider).planningMode;
    ref.read(routePlanningProvider.notifier).togglePlanningMode();
    if (wasPlanning) {
      unawaited(_afterExitPlanning());
    }
  }

  Future<void> clearPlanningSelection() async {
    mapDebugLog('_clearPlanningSelection');
    ref.read(routePlanningProvider.notifier).clearSelection();
    await _clearRouteLine();
    final map = _mapboxMap;
    if (map != null) {
      await _fitViewportToAllLaunches(map);
      await mapDebugLogMapboxSnapshot(map, '_clearPlanningSelection done');
    }
  }

  Future<void> nudgeZoomBy(double delta) async {
    final map = _mapboxMap;
    if (map == null || !ref.read(mapInteractiveProvider)) {
      return;
    }
    try {
      await map.setGestureInProgress(false);
      final cam = await map.getCameraState();
      final z = (cam.zoom + delta).clamp(0.5, 22.0);
      await map.easeTo(
        CameraOptions(
          center: cam.center,
          zoom: z,
          bearing: cam.bearing,
          pitch: cam.pitch,
          padding: cam.padding,
        ),
        MapAnimationOptions(duration: 200),
      );
      await map.setGestureInProgress(false);
      await _reassertMapCameraLimits(map);
    } on Object catch (e, st) {
      mapDebugLog('_nudgeZoomBy failed: $e\n$st');
    }
  }

  Future<void> fitRegionFromChrome() async {
    final map = _mapboxMap;
    if (map == null || !ref.read(mapInteractiveProvider)) {
      return;
    }
    await _fitViewportToAllLaunches(map);
  }

  void _handlePlanningTap(LaunchPoint launch) {
    final result = ref
        .read(routePlanningProvider.notifier)
        .handleLaunchTap(launch);
    switch (result) {
      case RoutePlanningTapResult.putInSelected:
        unawaited(_clearRouteLine());
      case RoutePlanningTapResult.takeOutSelected:
        unawaited(_runRoute());
      case RoutePlanningTapResult.sameAsPutIn:
        _ui.showSnackBar?.call('Pick a different launch for take-out.');
      case null:
        break;
    }
  }

  Future<void> _runRoute() async {
    final planning = ref.read(routePlanningProvider);
    final put = planning.putIn;
    final take = planning.takeOut;
    final planner = ref.read(riverRoutePlannerProvider).valueOrNull;
    if (put == null || take == null) {
      return;
    }
    if (planner == null) {
      if (_alive) {
        _ui.showSnackBar?.call('Still loading river data… try again.');
      }
      return;
    }

    final result = planner.plan(put, take);
    if (!_alive) {
      return;
    }

    if (result is RouteFailure) {
      mapDebugLog('plan FAILED ${put.id} -> ${take.id}: ${result.message}');
      ref.read(routePlanningProvider.notifier).setRouteLengthKm(null);
      unawaited(_clearRouteLine());
      _ui.showSnackBar?.call(result.message);
      return;
    }

    final ok = result as RouteSuccess;
    mapDebugLog(
      'plan OK ${put.id} -> ${take.id} '
      'lengthM=${ok.lengthMeters.toStringAsFixed(0)}',
    );
    mapDebugLogRoutePolyline('planner output', ok.polylineLonLat);
    mapDebugLogRouteSegmentMeters(ok.polylineLonLat);
    ref
        .read(routePlanningProvider.notifier)
        .setRouteLengthKm(ok.lengthMeters / 1000.0);
    await _drawRouteLine(ok.polylineLonLat);
    await _fitCameraToRoute(ok.polylineLonLat);
  }

  Future<void> _afterExitPlanning() async {
    await _clearRouteLine();
    final map = _mapboxMap;
    if (map != null) {
      await _fitViewportToAllLaunches(map);
      await mapDebugLogMapboxSnapshot(map, 'afterExitPlanning');
    }
  }

  Future<void> _relaxCameraBounds(MapboxMap map) async {
    try {
      await map.setBounds(
        CameraBoundsOptions(
          bounds: CoordinateBounds(
            southwest: Point(coordinates: Position(-180, -85.05112878)),
            northeast: Point(coordinates: Position(180, 85.05112878)),
            infiniteBounds: true,
          ),
          minZoom: kMapMinZoom,
          maxZoom: kMapMaxZoom,
          minPitch: kMapMinPitch,
          maxPitch: kMapMaxPitch,
        ),
      );
      mapDebugLog(
        'setBounds(world + zoom $kMapMinZoom..$kMapMaxZoom '
        'pitch $kMapMinPitch..$kMapMaxPitch) OK',
      );
    } on Object catch (e, st) {
      mapDebugLog('setBounds failed: $e\n$st');
    }
  }

  Future<void> _reassertMapCameraLimits(MapboxMap map) async {
    try {
      await map.setConstrainMode(ConstrainMode.NONE);
      mapDebugLog('setConstrainMode(NONE) OK (reassert after camera)');
    } on Object catch (e, st) {
      mapDebugLog('setConstrainMode(reassert) failed: $e\n$st');
    }
    await _relaxCameraBounds(map);
  }

  Future<void> _instantEaseToCamera(
    MapboxMap map,
    CameraOptions target, {
    required String debugTag,
  }) async {
    try {
      await map.setGestureInProgress(false);
    } on Object catch (e, st) {
      mapDebugLog('$debugTag setGestureInProgress(false) pre: $e\n$st');
    }
    await map.easeTo(target, MapAnimationOptions(duration: 1));
    try {
      await map.setGestureInProgress(false);
    } on Object catch (e, st) {
      mapDebugLog('$debugTag setGestureInProgress(false) post: $e\n$st');
    }
    if (kDebugMode) {
      try {
        final gip = await map.isGestureInProgress();
        mapDebugLog('$debugTag after easeTo isGestureInProgress=$gip');
      } on Object catch (e, st) {
        mapDebugLog('$debugTag isGestureInProgress: $e\n$st');
      }
    }
  }

  Future<void> _applyBoundsAfterCameraSettle(
    MapboxMap map, {
    required String debugTag,
  }) async {
    mapDebugLogTs('$debugTag pause 400ms before setBounds (camera settle)');
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (!_alive || _mapboxMap != map) {
      mapDebugLog('$debugTag aborted after pause (disposed or map replaced)');
      return;
    }
    await mapDebugLogCoordinateBoundsZoom(map, '$debugTag pre-reassert');
    await _reassertMapCameraLimits(map);
    mapDebugLogTs('$debugTag setBounds pass 1 done');
    await mapDebugLogMapboxSnapshot(
      map,
      '$debugTag after reassert',
      includeGestures: true,
    );
    unawaited(_delayedSecondBoundsPass(map, debugTag));
  }

  Future<void> _delayedSecondBoundsPass(MapboxMap map, String debugTag) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (!_alive || _mapboxMap != map) {
      return;
    }
    await _reassertMapCameraLimits(map);
    mapDebugLog('$debugTag setBounds pass 2 (+500ms) Standard style safety');
    await mapDebugLogCoordinateBoundsZoom(map, '$debugTag post-pass-2');
    mapDebugLogScheduleDeferredMapDiagnostics(
      getMap: () => _mapboxMap,
      isMounted: () => _alive,
      tag: 'DEFER_WATCH routeFit',
    );
  }

  Future<void> _configureStandardStyleMap(MapboxMap map) async {
    await mapDebugLogMapboxSnapshot(map, 'configureStandardStyleMap (before)');
    try {
      await map.style.setProjection(
        StyleProjection(name: StyleProjectionName.mercator),
      );
      mapDebugLog('setProjection(mercator) OK');
    } on Object catch (e, st) {
      mapDebugLog('setProjection(mercator) failed: $e\n$st');
    }
    await _reassertMapCameraLimits(map);
    await mapDebugLogMapboxSnapshot(map, 'configureStandardStyleMap (after)');
  }

  Future<void> _fitViewportToAllLaunches(MapboxMap map) async {
    final coords = kLaunchPoints
        .map((p) => Point(coordinates: Position(p.longitude, p.latitude)))
        .toList();
    final center = mapRegionCenter();
    try {
      final fitted = await map.cameraForCoordinatesPadding(
        coords,
        CameraOptions(center: center, zoom: 9, bearing: 0, pitch: 0),
        MbxEdgeInsets(top: 100, left: 40, bottom: 56, right: 40),
        11,
        null,
      );
      await _instantEaseToCamera(
        map,
        fitted,
        debugTag: '_fitViewportToAllLaunches',
      );
      mapDebugLogTs('LAUNCH_FIT pause 200ms before setBounds');
      await Future<void>.delayed(const Duration(milliseconds: 200));
      if (!_alive || _mapboxMap != map) {
        return;
      }
      await mapDebugLogCoordinateBoundsZoom(map, 'LAUNCH_FIT pre-reassert');
      await _reassertMapCameraLimits(map);
      mapDebugLog('_fitViewportToAllLaunches OK');
    } on Object catch (e, st) {
      mapDebugLog('_fitViewportToAllLaunches failed: $e\n$st');
    }
  }

  Future<void> _ensureRouteLineStyle(MapboxMap map) async {
    try {
      if (!await map.style.styleSourceExists(kMapRouteSourceId)) {
        await map.style.addSource(
          GeoJsonSource(id: kMapRouteSourceId, data: kMapEmptyRouteGeoJson),
        );
        mapDebugLog('route GeoJsonSource added');
      }
      if (!await map.style.styleLayerExists(kMapRouteLayerId)) {
        await map.style.addLayer(
          LineLayer(
            id: kMapRouteLayerId,
            sourceId: kMapRouteSourceId,
            lineColor: kMapRouteLineColor,
            lineWidth: 6,
            lineJoin: LineJoin.ROUND,
          ),
        );
        mapDebugLog('route LineLayer added');
      }
    } on Object catch (e, st) {
      mapDebugLog('_ensureRouteLineStyle failed: $e\n$st');
    }
  }

  String _routeGeoJsonFromLonLat(List<List<double>> lonLat) => jsonEncode({
    'type': 'Feature',
    'properties': <String, dynamic>{},
    'geometry': {'type': 'LineString', 'coordinates': lonLat},
  });

  Future<void> _installLaunchMarkersIfNeeded() async {
    if (_markersInstalled || _mapboxMap == null || !_alive) {
      if (!_alive && _mapboxMap != null) {
        mapDebugLog(
          '_installLaunchMarkersIfNeeded skipped (controller disposed)',
        );
      }
      return;
    }
    final mapboxMap = _mapboxMap!;
    try {
      await _configureStandardStyleMap(mapboxMap);
      await _ensureRouteLineStyle(mapboxMap);

      _circleManager = await mapboxMap.annotations
          .createCircleAnnotationManager();

      final options = kLaunchPoints
          .map(
            (p) => CircleAnnotationOptions(
              geometry: Point(coordinates: Position(p.longitude, p.latitude)),
              circleRadius: 10,
              circleColor: kMapMarkerColor,
              circleStrokeWidth: 2,
              circleStrokeColor: kMapMarkerStroke,
              customData: <String, Object>{'launchId': p.id},
            ),
          )
          .toList();

      await _circleManager!.createMulti(options);
      _markersInstalled = true;
      mapDebugLog(
        '_installLaunchMarkersIfNeeded OK markers=${kLaunchPoints.length}',
      );

      await _fitViewportToAllLaunches(mapboxMap);

      _tapCancelable?.cancel();
      _tapCancelable = _circleManager!.tapEvents(onTap: onLaunchCircleTap);
    } on Object catch (e, st) {
      mapDebugLog('_installLaunchMarkersIfNeeded failed: $e\n$st');
    } finally {
      if (_alive) {
        ref.read(mapInteractiveProvider.notifier).state = true;
      }
    }
  }

  Future<void> _drawRouteLine(List<List<double>> lonLat) async {
    final map = _mapboxMap;
    if (map == null || lonLat.length < 2) {
      mapDebugLog('_drawRouteLine skipped (no map or len=${lonLat.length})');
      return;
    }
    await _ensureRouteLineStyle(map);
    mapDebugLogRoutePolyline('_drawRouteLine input', lonLat);
    final data = _routeGeoJsonFromLonLat(lonLat);
    try {
      await map.style.setStyleSourceProperty(kMapRouteSourceId, 'data', data);
      mapDebugLog('route source updated coordCount=${lonLat.length}');
    } on Object catch (e, st) {
      mapDebugLog('_drawRouteLine setStyleSourceProperty failed: $e\n$st');
    }
  }

  Future<void> _clearRouteLine() async {
    final map = _mapboxMap;
    if (map == null) {
      return;
    }
    try {
      if (await map.style.styleSourceExists(kMapRouteSourceId)) {
        await map.style.setStyleSourceProperty(
          kMapRouteSourceId,
          'data',
          kMapEmptyRouteGeoJson,
        );
        mapDebugLog('_clearRouteLine: emptied GeoJSON source');
      }
    } on Object catch (e, st) {
      mapDebugLog('_clearRouteLine failed: $e\n$st');
    }
  }

  Future<void> _fitCameraToRoute(List<List<double>> lonLat) async {
    final map = _mapboxMap;
    if (map == null || lonLat.length < 2) {
      mapDebugLog('_fitCameraToRoute skipped (no map or len=${lonLat.length})');
      return;
    }
    mapDebugLogRoutePolyline('_fitCameraToRoute padding coords', lonLat);
    try {
      final coords = lonLat
          .map((c) => Point(coordinates: Position(c[0], c[1])))
          .toList();
      final fitted = await map.cameraForCoordinatesPadding(
        coords,
        CameraOptions(
          center: Point(
            coordinates: Position(lonLat.first[0], lonLat.first[1]),
          ),
          zoom: 10,
          bearing: 0,
          pitch: 0,
        ),
        MbxEdgeInsets(top: 160, left: 48, bottom: 200, right: 48),
        16,
        null,
      );
      final center = fitted.center?.coordinates;
      mapDebugLog(
        '_fitCameraToRoute fitted zoom=${fitted.zoom} '
        'center=(${center?.lng},${center?.lat})',
      );
      mapDebugLogTs('ROUTE_FIT easeTo start');
      await _instantEaseToCamera(map, fitted, debugTag: '_fitCameraToRoute');
      mapDebugLog(
        'ROUTE_FIT easeTo await returned; setBounds deferred ~400ms '
        '(was racing native animator — CAMERA_CHANGED BIG_JUMP in old logs)',
      );
      await _applyBoundsAfterCameraSettle(map, debugTag: 'ROUTE_FIT');
    } on Object catch (e, st) {
      mapDebugLog('_fitCameraToRoute failed: $e\n$st');
    }
  }
}

final mapboxMapControllerProvider =
    AutoDisposeNotifierProvider<MapboxMapController, void>(
      MapboxMapController.new,
    );
