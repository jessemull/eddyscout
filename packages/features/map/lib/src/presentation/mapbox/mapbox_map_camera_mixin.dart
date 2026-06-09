import 'dart:async' show unawaited;

import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import '../../domain/launch_points.dart';
import '../map_constants.dart';
import '../map_session_provider.dart';
import 'map_debug_log.dart';
import 'mapbox_map_controller_shared.dart';
import 'mapbox_map_style_mixin.dart';

/// Camera easing, bounds settling, and viewport fitting for the map.
mixin MapboxMapCameraMixin on MapboxMapControllerBase, MapboxMapStyleMixin {
  /// Logs camera changes in debug builds (rate-limited).
  void onDebugCameraChanged(CameraChangedEventData e) {
    if (!kDebugMode) {
      return;
    }
    final z = e.cameraState.zoom;
    final now = DateTime.now().millisecondsSinceEpoch;
    final prev = debugLastLoggedCameraZoom;
    final dz = prev == null ? 999.0 : (z - prev).abs();
    final bigJump = prev != null && dz >= 0.45;
    if (!bigJump && dz < 0.04 && now - debugLastCameraChangeLogMs < 400) {
      return;
    }
    if (bigJump) {
      mapDebugLogTs('CAMERA_CHANGED BIG_JUMP dz=${dz.toStringAsFixed(2)}');
    }
    debugLastLoggedCameraZoom = z;
    debugLastCameraChangeLogMs = now;
    final c = e.cameraState.center.coordinates;
    mapDebugLog(
      'CAMERA_CHANGED zoom=${z.toStringAsFixed(2)} '
      'center=(${c.lng.toStringAsFixed(4)},${c.lat.toStringAsFixed(4)})',
    );
    final m = mapboxMap;
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

  /// Logs zoom gesture end in debug builds.
  void onDebugMapZoomEnded(MapContentGestureContext ctx) {
    if (ctx.gestureState != GestureState.ended) {
      return;
    }
    mapDebugLog(
      'MAP ZOOM gesture ended | '
      'screen=(${ctx.touchPosition.x.toStringAsFixed(0)},'
      '${ctx.touchPosition.y.toStringAsFixed(0)})',
    );
    final m = mapboxMap;
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

  /// Adjusts zoom when map chrome buttons are used.
  Future<void> nudgeZoomBy(double delta) async {
    final map = mapboxMap;
    if (map == null || !mapControllerRef.read(mapInteractiveProvider)) {
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
      await reassertMapCameraLimits(map);
    } on Object catch (e, st) {
      mapDebugLog('_nudgeZoomBy failed: $e\n$st');
    }
  }

  /// Fits the viewport to all launch markers (map chrome action).
  Future<void> fitRegionFromChrome() async {
    final map = mapboxMap;
    if (map == null || !mapControllerRef.read(mapInteractiveProvider)) {
      return;
    }
    await fitViewportToAllLaunches(map);
  }

  /// Eases the camera instantly (1ms) and clears gesture state.
  Future<void> instantEaseToCamera(
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

  /// Waits for camera animation then reasserts bounds (route fit safety).
  Future<void> applyBoundsAfterCameraSettle(
    MapboxMap map, {
    required String debugTag,
  }) async {
    mapDebugLogTs('$debugTag pause 400ms before setBounds (camera settle)');
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (!alive || mapboxMap != map) {
      mapDebugLog('$debugTag aborted after pause (disposed or map replaced)');
      return;
    }
    await mapDebugLogCoordinateBoundsZoom(map, '$debugTag pre-reassert');
    await reassertMapCameraLimits(map);
    mapDebugLogTs('$debugTag setBounds pass 1 done');
    await mapDebugLogMapboxSnapshot(
      map,
      '$debugTag after reassert',
      includeGestures: true,
    );
    unawaited(delayedSecondBoundsPass(map, debugTag));
  }

  /// Second bounds pass after route camera fit.
  Future<void> delayedSecondBoundsPass(MapboxMap map, String debugTag) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (!alive || mapboxMap != map) {
      return;
    }
    await reassertMapCameraLimits(map);
    mapDebugLog('$debugTag setBounds pass 2 (+500ms) Standard style safety');
    await mapDebugLogCoordinateBoundsZoom(map, '$debugTag post-pass-2');
    mapDebugLogScheduleDeferredMapDiagnostics(
      getMap: () => mapboxMap,
      isMounted: () => alive,
      tag: 'DEFER_WATCH routeFit',
    );
  }

  /// Fits camera to show all curated launch points.
  Future<void> fitViewportToAllLaunches(MapboxMap map) async {
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
      await instantEaseToCamera(
        map,
        fitted,
        debugTag: '_fitViewportToAllLaunches',
      );
      mapDebugLogTs('LAUNCH_FIT pause 200ms before setBounds');
      await Future<void>.delayed(const Duration(milliseconds: 200));
      if (!alive || mapboxMap != map) {
        return;
      }
      await mapDebugLogCoordinateBoundsZoom(map, 'LAUNCH_FIT pre-reassert');
      await reassertMapCameraLimits(map);
      mapDebugLog('_fitViewportToAllLaunches OK');
    } on Object catch (e, st) {
      mapDebugLog('_fitViewportToAllLaunches failed: $e\n$st');
    }
  }

  /// Eases the camera to a single curated launch.
  Future<void> flyToLaunch(LaunchPoint launch) async {
    final map = mapboxMap;
    if (map == null || !mapControllerRef.read(mapInteractiveProvider)) {
      return;
    }
    try {
      await instantEaseToCamera(
        map,
        CameraOptions(
          center: Point(
            coordinates: Position(launch.longitude, launch.latitude),
          ),
          zoom: 12.5,
          bearing: 0,
          pitch: 0,
        ),
        debugTag: 'flyToLaunch',
      );
    } on Object catch (e, st) {
      mapDebugLog('flyToLaunch failed: $e\n$st');
    }
  }

  /// Fits camera padding around a route polyline.
  Future<void> fitCameraToRoute(List<List<double>> lonLat) async {
    final map = mapboxMap;
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
      await instantEaseToCamera(map, fitted, debugTag: '_fitCameraToRoute');
      mapDebugLog(
        'ROUTE_FIT easeTo await returned; setBounds deferred ~400ms '
        '(was racing native animator — CAMERA_CHANGED BIG_JUMP in old logs)',
      );
      await applyBoundsAfterCameraSettle(map, debugTag: 'ROUTE_FIT');
    } on Object catch (e, st) {
      mapDebugLog('_fitCameraToRoute failed: $e\n$st');
    }
  }
}
