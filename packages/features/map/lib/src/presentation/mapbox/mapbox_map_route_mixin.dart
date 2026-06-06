import 'dart:convert' show jsonEncode;

import 'package:eddyscout_map/src/presentation/map_constants.dart';
import 'package:eddyscout_map/src/presentation/mapbox/map_debug_log.dart';
import 'package:eddyscout_map/src/presentation/mapbox/mapbox_map_controller_shared.dart';
import 'package:eddyscout_map/src/presentation/mapbox/mapbox_map_style_mixin.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

/// Route line GeoJSON source/layer for river planning.
mixin MapboxMapRouteMixin on MapboxMapControllerBase, MapboxMapStyleMixin {
  String routeGeoJsonFromLonLat(List<List<double>> lonLat) => jsonEncode({
    'type': 'Feature',
    'properties': <String, dynamic>{},
    'geometry': {'type': 'LineString', 'coordinates': lonLat},
  });

  /// Adds route source/layer if missing on the current style.
  Future<void> ensureRouteLineStyle(MapboxMap map) async {
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

  /// Updates the route line GeoJSON from planner output.
  Future<void> drawRouteLine(List<List<double>> lonLat) async {
    final map = mapboxMap;
    if (map == null || lonLat.length < 2) {
      mapDebugLog('_drawRouteLine skipped (no map or len=${lonLat.length})');
      return;
    }
    await ensureRouteLineStyle(map);
    mapDebugLogRoutePolyline('_drawRouteLine input', lonLat);
    final data = routeGeoJsonFromLonLat(lonLat);
    try {
      await map.style.setStyleSourceProperty(kMapRouteSourceId, 'data', data);
      mapDebugLog('route source updated coordCount=${lonLat.length}');
    } on Object catch (e, st) {
      mapDebugLog('_drawRouteLine setStyleSourceProperty failed: $e\n$st');
    }
  }

  /// Clears the route line GeoJSON source.
  Future<void> clearRouteLine() async {
    final map = mapboxMap;
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
}
