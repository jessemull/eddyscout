import 'dart:async' show unawaited;
import 'dart:convert' show jsonEncode;

import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import '../data/launch_models.dart';
import '../data/launch_points.dart';
import '../debug/map_debug_log.dart';
import '../routing/route_result.dart';
import '../routing/river_route_planner.dart';
import 'launch_detail_screen.dart';

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

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  Cancelable? _tapCancelable;
  MapboxMap? _mapboxMap;
  bool _markersInstalled = false;

  CircleAnnotationManager? _circleManager;

  RiverRoutePlanner? _routePlanner;

  /// One-shot diagnostics (launch proximity) per map session.
  bool _mapDiagnosticsLogged = false;

  bool _planningMode = false;
  LaunchPoint? _putIn;
  LaunchPoint? _takeOut;
  double? _routeLengthKm;

  static const int _markerColor = 0xFF0077B6;
  static const int _markerStroke = 0xFFFFFFFF;
  static const int _routeLineColor = 0xFFE63946;

  static const String _routeSourceId = 'eddyscout-route-source';
  static const String _routeLayerId = 'eddyscout-route-layer';
  static const String _emptyRouteGeoJson =
      '{"type":"FeatureCollection","features":[]}';

  @override
  void initState() {
    super.initState();
    RiverRoutePlanner.load().then((p) {
      if (mounted) {
        setState(() => _routePlanner = p);
      }
    });
  }

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
        ),
      );
      mapDebugLog(
        'setBounds(world + minZoom $_mapMinZoom / maxZoom $_mapMaxZoom) OK',
      );
    } catch (e, st) {
      mapDebugLog('setBounds failed: $e\n$st');
    }
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
    try {
      await map.setConstrainMode(ConstrainMode.NONE);
      mapDebugLog('setConstrainMode(NONE) OK');
    } catch (e, st) {
      mapDebugLog('setConstrainMode failed: $e\n$st');
    }
    await _relaxCameraBounds(map);
    await mapDebugLogMapboxSnapshot(map, 'configureStandardStyleMap (after)');
  }

  /// Same framing as first load: all launches visible with UI padding.
  Future<void> _fitViewportToAllLaunches(MapboxMap map) async {
    final coords = kLaunchPoints
        .map(
          (p) => Point(coordinates: Position(p.longitude, p.latitude)),
        )
        .toList();
    final center = _regionCenter;
    try {
      final fitted = await map.cameraForCoordinatesPadding(
        coords,
        CameraOptions(
          center: center,
          zoom: 9,
          bearing: 0,
          pitch: 0,
        ),
        MbxEdgeInsets(top: 100, left: 40, bottom: 56, right: 40),
        11,
        null,
      );
      await map.setCamera(fitted);
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
      'geometry': {
        'type': 'LineString',
        'coordinates': lonLat,
      },
    });
  }

  Future<void> _installLaunchMarkersIfNeeded() async {
    if (_markersInstalled || _mapboxMap == null || !mounted) {
      return;
    }
    final mapboxMap = _mapboxMap!;
    await _configureStandardStyleMap(mapboxMap);
    await _ensureRouteLineStyle(mapboxMap);
    _markersInstalled = true;

    _circleManager = await mapboxMap.annotations.createCircleAnnotationManager();

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
    _tapCancelable = _circleManager!.tapEvents(
      onTap: _onLaunchCircleTap,
    );
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

    if (!_planningMode) {
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
    if (_putIn == null) {
      setState(() {
        _putIn = launch;
        _takeOut = null;
        _routeLengthKm = null;
      });
      unawaited(_clearRouteLine());
      return;
    }
    if (_putIn!.id == launch.id) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pick a different launch for take-out.')),
      );
      return;
    }
    setState(() {
      _takeOut = launch;
    });
    _runRoute();
  }

  Future<void> _runRoute() async {
    final put = _putIn;
    final take = _takeOut;
    final planner = _routePlanner;
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
      setState(() => _routeLengthKm = null);
      unawaited(_clearRouteLine());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message)),
      );
      return;
    }

    final ok = result as RouteSuccess;
    mapDebugLog(
      'plan OK ${put.id} -> ${take.id} lengthM=${ok.lengthMeters.toStringAsFixed(0)}',
    );
    mapDebugLogRoutePolyline('planner output', ok.polylineLonLat);
    mapDebugLogRouteSegmentMeters(ok.polylineLonLat);
    setState(() => _routeLengthKm = ok.lengthMeters / 1000.0);
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
      mapDebugLog(
        'route source updated coordCount=${lonLat.length}',
      );
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
          .map(
            (c) => Point(coordinates: Position(c[0], c[1])),
          )
          .toList();
      final fitted = await map.cameraForCoordinatesPadding(
        coords,
        CameraOptions(
          center: Point(coordinates: Position(lonLat.first[0], lonLat.first[1])),
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
      await map.setCamera(fitted);
      // Do not call [_configureStandardStyleMap] here: it reapplies [setBounds]
      // and projection and has been locking pinch-zoom after route fit.
      await mapDebugLogMapboxSnapshot(map, '_fitCameraToRoute (after setCamera)');
    } catch (e, st) {
      mapDebugLog('_fitCameraToRoute failed: $e\n$st');
    }
  }

  void _togglePlanningMode() {
    final wasPlanning = _planningMode;
    setState(() {
      _planningMode = !_planningMode;
      if (!_planningMode) {
        _putIn = null;
        _takeOut = null;
        _routeLengthKm = null;
      }
    });
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
    setState(() {
      _putIn = null;
      _takeOut = null;
      _routeLengthKm = null;
    });
    await _clearRouteLine();
    final map = _mapboxMap;
    if (map != null) {
      await _fitViewportToAllLaunches(map);
      await mapDebugLogMapboxSnapshot(map, '_clearPlanningSelection done');
    }
  }

  Future<void> _onMapCreated(MapboxMap mapboxMap) async {
    _mapboxMap = mapboxMap;
    mapDebugLog('onMapCreated');
    final center = _regionCenter;
    await mapboxMap.setCamera(
      CameraOptions(center: center, zoom: 9, pitch: 0, bearing: 0),
    );
    await mapDebugLogMapboxSnapshot(mapboxMap, 'onMapCreated');
  }

  void _onStyleLoaded(StyleLoadedEventData _) {
    if (!_mapDiagnosticsLogged) {
      _mapDiagnosticsLogged = true;
      mapDebugLogLaunchPairsWithin(400);
    }
    _installLaunchMarkersIfNeeded();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EddyScout'),
        actions: [
          IconButton(
            tooltip: _planningMode ? 'Exit route planning' : 'Plan river route',
            onPressed: _togglePlanningMode,
            icon: Icon(
              _planningMode ? Icons.close : Icons.alt_route,
            ),
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          MapWidget(
            key: const ValueKey<String>('eddyscout_map'),
            styleUri: MapboxStyles.STANDARD,
            // ignore: experimental_member_use
            androidHostingMode: AndroidPlatformViewHostingMode.TLHC_HC,
            mapOptions: MapOptions(
              pixelRatio: MediaQuery.devicePixelRatioOf(context),
            ),
            // Omit viewport: a new CameraViewportState each build made Mapbox
            // re-apply zoom 9 on every setState, undoing route fit and user zoom.
            onMapCreated: _onMapCreated,
            onStyleLoadedListener: _onStyleLoaded,
          ),
          if (_planningMode) _PlanningOverlay(
            putIn: _putIn,
            takeOut: _takeOut,
            routeLengthKm: _routeLengthKm,
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
                      TextButton(
                        onPressed: onDone,
                        child: const Text('Done'),
                      ),
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
