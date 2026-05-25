import 'dart:async' show unawaited;
import 'dart:convert' show jsonEncode;

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import '../data/launch_models.dart';
import '../data/launch_points.dart';
import '../debug/map_debug_log.dart';
import '../routing/route_result.dart';
import '../routing/river_route_planner.dart';
import '../routing/river_route_planner_provider.dart';
import 'launch_detail_screen.dart';
import 'map_planning_provider.dart';

/// Approximate centroid of [kLaunchPoints] for initial viewport.
Point get _regionCenter {
  double lat = 0, lon = 0;
  for (final p in kLaunchPoints) {
    lat += p.latitude;
    lon += p.longitude;
  }
  final n = kLaunchPoints.length.toDouble();
  return Point(coordinates: Position(lon / n, lat / n));
}

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  Cancelable? _tapCancelable;
  MapboxMap? _mapboxMap;
  bool _markersInstalled = false;

  CircleAnnotationManager? _circleManager;

  /// One-shot diagnostics (launch proximity) per map session.
  bool _mapDiagnosticsLogged = false;

  /// False until Mercator + launch fit runs; blocks gestures so users do not
  /// pinch-zoom on the default globe (blurry / wrong LOD) before style setup.
  bool _mapInteractive = false;

  /// Throttle noisy [onCameraChangeListener] logs (debug).
  double? _debugLastLoggedCameraZoom;
  int _debugLastCameraChangeLogMs = 0;

  static const int _markerColor = 0xFF0077B6;
  static const int _markerStroke = 0xFFFFFFFF;
  static const int _routeLineColor = 0xFFE63946;

  static const String _routeSourceId = 'eddyscout-route-source';
  static const String _routeLayerId = 'eddyscout-route-layer';
  static const String _emptyRouteGeoJson =
      '{"type":"FeatureCollection","features":[]}';

  @override
  void dispose() {
    _tapCancelable?.cancel();
    super.dispose();
  }

  /// Mapbox Standard / programmatic camera moves can leave a high [minZoom] or
  /// tight bounds, which caps how far the user can zoom out. Reset to world
  /// bounds and full zoom range (matches mapbox example [CameraBoundsOptions]).
  static const double _mapMinZoom = 0;
  static const double _mapMaxZoom = 25.5;
  static const double _mapMinPitch = 0;
  static const double _mapMaxPitch = 85;

  /// Step for in-app zoom buttons (emulator-friendly; Mapbox Standard’s native
  /// −/+ can stay greyed after auto-fit even when the camera could zoom out).
  static const double _chromeZoomStep = 1.25;

  Future<void> _relaxCameraBounds(MapboxMap map) async {
    try {
      await map.setBounds(
        CameraBoundsOptions(
          bounds: CoordinateBounds(
            southwest: Point(coordinates: Position(-180, -85.05112878)),
            northeast: Point(coordinates: Position(180, 85.05112878)),
            infiniteBounds: true,
          ),
          minZoom: _mapMinZoom,
          maxZoom: _mapMaxZoom,
          minPitch: _mapMinPitch,
          maxPitch: _mapMaxPitch,
        ),
      );
      mapDebugLog(
        'setBounds(world + zoom $_mapMinZoom..$_mapMaxZoom '
        'pitch $_mapMinPitch..$_mapMaxPitch) OK',
      );
    } catch (e, st) {
      mapDebugLog('setBounds failed: $e\n$st');
    }
  }

  /// Mapbox Standard (especially on Android) often tightens camera bounds or
  /// changes [ConstrainMode] after programmatic camera moves. Without this,
  /// pinch zoom-out can stay locked at the auto-fit zoom.
  Future<void> _reassertMapCameraLimits(MapboxMap map) async {
    try {
      await map.setConstrainMode(ConstrainMode.NONE);
      mapDebugLog('setConstrainMode(NONE) OK (reassert after camera)');
    } catch (e, st) {
      mapDebugLog('setConstrainMode(reassert) failed: $e\n$st');
    }
    await _relaxCameraBounds(map);
  }

  /// [setCamera] on Android + Standard has been observed to leave pinch-zoom
  /// broken; [easeTo] with ~0 ms duration goes through the animation pipeline and
  /// clears the stuck state. Also forces [setGestureInProgress](false).
  Future<void> _instantEaseToCamera(
    MapboxMap map,
    CameraOptions target, {
    required String debugTag,
  }) async {
    try {
      await map.setGestureInProgress(false);
    } catch (e, st) {
      mapDebugLog('$debugTag setGestureInProgress(false) pre: $e\n$st');
    }
    await map.easeTo(target, MapAnimationOptions(duration: 1));
    try {
      await map.setGestureInProgress(false);
    } catch (e, st) {
      mapDebugLog('$debugTag setGestureInProgress(false) post: $e\n$st');
    }
    if (kDebugMode) {
      try {
        final gip = await map.isGestureInProgress();
        mapDebugLog('$debugTag after easeTo isGestureInProgress=$gip');
      } catch (e, st) {
        mapDebugLog('$debugTag isGestureInProgress: $e\n$st');
      }
    }
  }

  /// Calling [setBounds] while [easeTo] is still settling makes Mapbox emit
  /// bogus [CAMERA_CHANGED] frames (logs showed zoom ~8.97 then ~12.56) and
  /// leaves Standard’s − / 1:1 ornaments wrong. Wait, then [setBounds] once.
  Future<void> _applyBoundsAfterCameraSettle(
    MapboxMap map, {
    required String debugTag,
  }) async {
    mapDebugLogTs('$debugTag pause 400ms before setBounds (camera settle)');
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (!mounted || _mapboxMap != map) {
      mapDebugLog('$debugTag aborted after pause (unmounted or map replaced)');
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
    if (!mounted || _mapboxMap != map) {
      return;
    }
    await _reassertMapCameraLimits(map);
    mapDebugLog('$debugTag setBounds pass 2 (+500ms) Standard style safety');
    await mapDebugLogCoordinateBoundsZoom(map, '$debugTag post-pass-2');
    mapDebugLogScheduleDeferredMapDiagnostics(
      getMap: () => _mapboxMap,
      isMounted: () => mounted,
      tag: 'DEFER_WATCH routeFit',
    );
  }

  void _onDebugCameraChanged(CameraChangedEventData e) {
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
      } catch (_) {}
    }());
  }

  void _onDebugMapZoomEnded(MapContentGestureContext ctx) {
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

  /// Standard style defaults to globe; polyline annotations can render as a
  /// near–straight chord at city zoom. Mercator keeps the line on the hydro path.
  Future<void> _configureStandardStyleMap(MapboxMap map) async {
    await mapDebugLogMapboxSnapshot(map, 'configureStandardStyleMap (before)');
    try {
      await map.style.setProjection(
        StyleProjection(name: StyleProjectionName.mercator),
      );
      mapDebugLog('setProjection(mercator) OK');
    } catch (e, st) {
      mapDebugLog('setProjection(mercator) failed: $e\n$st');
    }
    await _reassertMapCameraLimits(map);
    await mapDebugLogMapboxSnapshot(map, 'configureStandardStyleMap (after)');
  }

  /// Same framing as first load: all launches visible with UI padding.
  Future<void> _fitViewportToAllLaunches(MapboxMap map) async {
    final coords = kLaunchPoints
        .map((p) => Point(coordinates: Position(p.longitude, p.latitude)))
        .toList();
    final center = _regionCenter;
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
      if (!mounted || _mapboxMap != map) {
        return;
      }
      await mapDebugLogCoordinateBoundsZoom(map, 'LAUNCH_FIT pre-reassert');
      await _reassertMapCameraLimits(map);
      mapDebugLog('_fitViewportToAllLaunches OK');
    } catch (e, st) {
      mapDebugLog('_fitViewportToAllLaunches failed: $e\n$st');
    }
  }

  /// Style-layer route (GeoJSON) clears reliably on Android; polyline
  /// annotations often ignore [delete]/[deleteAll] with Mapbox Standard.
  Future<void> _ensureRouteLineStyle(MapboxMap map) async {
    try {
      if (!await map.style.styleSourceExists(_routeSourceId)) {
        await map.style.addSource(
          GeoJsonSource(id: _routeSourceId, data: _emptyRouteGeoJson),
        );
        mapDebugLog('route GeoJsonSource added');
      }
      if (!await map.style.styleLayerExists(_routeLayerId)) {
        await map.style.addLayer(
          LineLayer(
            id: _routeLayerId,
            sourceId: _routeSourceId,
            lineColor: _routeLineColor,
            lineWidth: 6,
            lineJoin: LineJoin.ROUND,
          ),
        );
        mapDebugLog('route LineLayer added');
      }
    } catch (e, st) {
      mapDebugLog('_ensureRouteLineStyle failed: $e\n$st');
    }
  }

  String _routeGeoJsonFromLonLat(List<List<double>> lonLat) {
    return jsonEncode({
      'type': 'Feature',
      'properties': <String, dynamic>{},
      'geometry': {'type': 'LineString', 'coordinates': lonLat},
    });
  }

  Future<void> _installLaunchMarkersIfNeeded() async {
    if (_markersInstalled || _mapboxMap == null || !mounted) {
      return;
    }
    final mapboxMap = _mapboxMap!;
    try {
      await _configureStandardStyleMap(mapboxMap);
      await _ensureRouteLineStyle(mapboxMap);
      _markersInstalled = true;

      _circleManager = await mapboxMap.annotations
          .createCircleAnnotationManager();

      final options = kLaunchPoints
          .map(
            (p) => CircleAnnotationOptions(
              geometry: Point(coordinates: Position(p.longitude, p.latitude)),
              circleRadius: 10,
              circleColor: _markerColor,
              circleStrokeWidth: 2,
              circleStrokeColor: _markerStroke,
              customData: <String, Object>{'launchId': p.id},
            ),
          )
          .toList();

      await _circleManager!.createMulti(options);

      await _fitViewportToAllLaunches(mapboxMap);

      _tapCancelable?.cancel();
      _tapCancelable = _circleManager!.tapEvents(onTap: _onLaunchCircleTap);
    } catch (e, st) {
      mapDebugLog('_installLaunchMarkersIfNeeded failed: $e\n$st');
    } finally {
      if (mounted) {
        setState(() => _mapInteractive = true);
      }
    }
  }

  void _onLaunchCircleTap(CircleAnnotation annotation) {
    final raw = annotation.customData?['launchId'];
    if (raw is! String) {
      return;
    }
    final launch = launchPointById(raw);
    if (launch == null || !context.mounted) {
      return;
    }

    final planning = ref.read(routePlanningProvider);
    if (!planning.planningMode) {
      Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder: (context) => LaunchDetailScreen(launch: launch),
        ),
      );
      return;
    }

    _handlePlanningTap(launch);
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pick a different launch for take-out.'),
          ),
        );
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Still loading river data… try again.')),
        );
      }
      return;
    }

    final result = planner.plan(put, take);
    if (!mounted) {
      return;
    }

    if (result is RouteFailure) {
      mapDebugLog('plan FAILED ${put.id} -> ${take.id}: ${result.message}');
      ref.read(routePlanningProvider.notifier).setRouteLengthKm(null);
      unawaited(_clearRouteLine());
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result.message)));
      return;
    }

    final ok = result as RouteSuccess;
    mapDebugLog(
      'plan OK ${put.id} -> ${take.id} lengthM=${ok.lengthMeters.toStringAsFixed(0)}',
    );
    mapDebugLogRoutePolyline('planner output', ok.polylineLonLat);
    mapDebugLogRouteSegmentMeters(ok.polylineLonLat);
    ref
        .read(routePlanningProvider.notifier)
        .setRouteLengthKm(ok.lengthMeters / 1000.0);
    await _drawRouteLine(ok.polylineLonLat);
    await _fitCameraToRoute(ok.polylineLonLat);
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
      await map.style.setStyleSourceProperty(_routeSourceId, 'data', data);
      mapDebugLog('route source updated coordCount=${lonLat.length}');
    } catch (e, st) {
      mapDebugLog('_drawRouteLine setStyleSourceProperty failed: $e\n$st');
    }
  }

  Future<void> _clearRouteLine() async {
    final map = _mapboxMap;
    if (map == null) {
      return;
    }
    try {
      if (await map.style.styleSourceExists(_routeSourceId)) {
        await map.style.setStyleSourceProperty(
          _routeSourceId,
          'data',
          _emptyRouteGeoJson,
        );
        mapDebugLog('_clearRouteLine: emptied GeoJSON source');
      }
    } catch (e, st) {
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
      mapDebugLog(
        '_fitCameraToRoute fitted zoom=${fitted.zoom} '
        'center=(${fitted.center?.coordinates.lng},${fitted.center?.coordinates.lat})',
      );
      mapDebugLogTs('ROUTE_FIT easeTo start');
      await _instantEaseToCamera(map, fitted, debugTag: '_fitCameraToRoute');
      mapDebugLog(
        'ROUTE_FIT easeTo await returned; next setBounds deferred ~400ms '
        '(was racing native animator — see CAMERA_CHANGED BIG_JUMP in old logs)',
      );
      await _applyBoundsAfterCameraSettle(map, debugTag: 'ROUTE_FIT');
    } catch (e, st) {
      mapDebugLog('_fitCameraToRoute failed: $e\n$st');
    }
  }

  void _togglePlanningMode() {
    final wasPlanning = ref.read(routePlanningProvider).planningMode;
    ref.read(routePlanningProvider.notifier).togglePlanningMode();
    if (wasPlanning) {
      unawaited(_afterExitPlanning());
    }
  }

  Future<void> _afterExitPlanning() async {
    await _clearRouteLine();
    final map = _mapboxMap;
    if (map != null) {
      await _fitViewportToAllLaunches(map);
      await mapDebugLogMapboxSnapshot(map, 'afterExitPlanning');
    }
  }

  Future<void> _clearPlanningSelection() async {
    mapDebugLog('_clearPlanningSelection');
    ref.read(routePlanningProvider.notifier).clearSelection();
    await _clearRouteLine();
    final map = _mapboxMap;
    if (map != null) {
      await _fitViewportToAllLaunches(map);
      await mapDebugLogMapboxSnapshot(map, '_clearPlanningSelection done');
    }
  }

  Future<void> _onMapCreated(MapboxMap mapboxMap) async {
    _mapboxMap = mapboxMap;
    mapDebugLog('onMapCreated (initial camera from MapWidget.cameraOptions)');
    await mapDebugLogMapboxSnapshot(
      mapboxMap,
      'onMapCreated',
      includeGestures: true,
    );
  }

  void _onStyleLoaded(StyleLoadedEventData _) {
    if (!_mapDiagnosticsLogged) {
      _mapDiagnosticsLogged = true;
      mapDebugLogLaunchPairsWithin(400);
    }
    _installLaunchMarkersIfNeeded();
  }

  Future<void> _nudgeZoomBy(double delta) async {
    final map = _mapboxMap;
    if (map == null || !_mapInteractive) {
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
    } catch (e, st) {
      mapDebugLog('_nudgeZoomBy failed: $e\n$st');
    }
  }

  Future<void> _fitRegionFromChrome() async {
    final map = _mapboxMap;
    if (map == null || !_mapInteractive) {
      return;
    }
    await _fitViewportToAllLaunches(map);
  }

  @override
  Widget build(BuildContext context) {
    final planning = ref.watch(routePlanningProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('EddyScout'),
        actions: [
          IconButton(
            tooltip: planning.planningMode
                ? 'Exit route planning'
                : 'Plan river route',
            onPressed: _togglePlanningMode,
            icon: Icon(planning.planningMode ? Icons.close : Icons.alt_route),
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          IgnorePointer(
            ignoring: !_mapInteractive,
            child: MapWidget(
              key: const ValueKey<String>('eddyscout_map'),
              styleUri: MapboxStyles.STANDARD,
              // ignore: experimental_member_use
              androidHostingMode: AndroidPlatformViewHostingMode.TLHC_HC,
              textureView: true,
              cameraOptions: CameraOptions(
                center: _regionCenter,
                zoom: 9,
                pitch: 0,
                bearing: 0,
              ),
              mapOptions: MapOptions(
                pixelRatio: MediaQuery.devicePixelRatioOf(context),
              ),
              // Omit viewport: a new CameraViewportState each build made Mapbox
              // re-apply zoom 9 on every setState, undoing route fit and user zoom.
              onMapCreated: _onMapCreated,
              onStyleLoadedListener: _onStyleLoaded,
              onCameraChangeListener: kDebugMode ? _onDebugCameraChanged : null,
              onZoomListener: kDebugMode ? _onDebugMapZoomEnded : null,
            ),
          ),
          if (_mapInteractive)
            Positioned(
              left: 8,
              bottom: MediaQuery.viewPaddingOf(context).bottom + 120,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(10),
                color: Theme.of(context).colorScheme.surfaceContainerHigh,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: 'Zoom in',
                      icon: const Icon(Icons.add),
                      onPressed: () => unawaited(_nudgeZoomBy(_chromeZoomStep)),
                    ),
                    const Divider(height: 1),
                    IconButton(
                      tooltip: 'Zoom out',
                      icon: const Icon(Icons.remove),
                      onPressed: () =>
                          unawaited(_nudgeZoomBy(-_chromeZoomStep)),
                    ),
                    const Divider(height: 1),
                    IconButton(
                      tooltip: 'Show all launches',
                      icon: const Icon(Icons.zoom_out_map),
                      onPressed: () => unawaited(_fitRegionFromChrome()),
                    ),
                  ],
                ),
              ),
            ),
          if (planning.planningMode)
            _PlanningOverlay(
              putIn: planning.putIn,
              takeOut: planning.takeOut,
              routeLengthKm: planning.routeLengthKm,
              onClear: () => unawaited(_clearPlanningSelection()),
              onDone: _togglePlanningMode,
            ),
        ],
      ),
    );
  }
}

class _PlanningOverlay extends StatelessWidget {
  const _PlanningOverlay({
    required this.putIn,
    required this.takeOut,
    required this.routeLengthKm,
    required this.onClear,
    required this.onDone,
  });

  final LaunchPoint? putIn;
  final LaunchPoint? takeOut;
  final double? routeLengthKm;
  final VoidCallback onClear;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(12),
            color: scheme.surfaceContainerHighest,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'River route (beta)',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Tap a launch for put-in, then another for take-out. '
                    'The line follows bundled open hydro data (approximate centerline)—not for navigation. '
                    'Several downtown launches sit close together; overlapping pins are separate sites. '
                    'Clear removes the route line and picks so you can start over. '
                    'Done closes this panel and clears the route.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  if (putIn != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Put-in: ${putIn!.name}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                  if (takeOut != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Take-out: ${takeOut!.name}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                  if (routeLengthKm != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      'Along river (estimate): ${routeLengthKm!.toStringAsFixed(1)} km',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ],
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    alignment: WrapAlignment.end,
                    children: [
                      TextButton(
                        onPressed: onClear,
                        child: const Text('Clear'),
                      ),
                      TextButton(onPressed: onDone, child: const Text('Done')),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
