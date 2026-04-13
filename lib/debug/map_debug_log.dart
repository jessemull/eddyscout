import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import '../data/launch_points.dart';
import '../routing/geodesy.dart';

/// Prefix on every line so `flutter run` shows them (`debugPrint`).
/// `developer.log` alone often does not appear in the Flutter CLI—use this prefix
/// to filter: `[eddyscout.map]`
const String kMapDebugLogName = 'eddyscout.map';

void mapDebugLog(String message) {
  if (kDebugMode) {
    debugPrint('[$kMapDebugLogName] $message');
    developer.log(message, name: kMapDebugLogName);
  }
}

/// Camera, [getBounds], and style projection (helps diagnose zoom-out lock).
Future<void> mapDebugLogMapboxSnapshot(MapboxMap map, String label) async {
  if (!kDebugMode) {
    return;
  }
  try {
    final cam = await map.getCameraState();
    final c = cam.center.coordinates;
    mapDebugLog(
      '$label | camera zoom=${cam.zoom.toStringAsFixed(2)} '
      'center=(${c.lng.toStringAsFixed(5)},${c.lat.toStringAsFixed(5)}) '
      'pitch=${cam.pitch.toStringAsFixed(1)}',
    );
  } catch (e, st) {
    mapDebugLog('$label | getCameraState failed: $e\n$st');
  }
  try {
    final b = await map.getBounds();
    final bb = b.bounds;
    mapDebugLog(
      '$label | bounds minZoom=${b.minZoom} maxZoom=${b.maxZoom} '
      'pitch min=${b.minPitch} max=${b.maxPitch} '
      'geoInf=${bb.infiniteBounds}',
    );
    if (!bb.infiniteBounds) {
      final sw = bb.southwest.coordinates;
      final ne = bb.northeast.coordinates;
      mapDebugLog(
        '$label | bounds box SW=(${sw.lng},${sw.lat}) NE=(${ne.lng},${ne.lat})',
      );
    }
  } catch (e, st) {
    mapDebugLog('$label | getBounds failed: $e\n$st');
  }
  try {
    final p = await map.style.getProjection();
    mapDebugLog('$label | style.getProjection()=${p?.name}');
  } catch (e) {
    mapDebugLog('$label | getProjection failed: $e');
  }
}

void mapDebugLogRoutePolyline(String context, List<List<double>> lonLat) {
  if (!kDebugMode || lonLat.isEmpty) {
    return;
  }
  final n = lonLat.length;
  final first = lonLat.first;
  final last = lonLat.last;
  final mid = lonLat[n ~/ 2];
  mapDebugLog(
    '$context | polyline count=$n '
    'first[lon,lat]=(${first[0]},${first[1]}) '
    'mid=(${mid[0]},${mid[1]}) '
    'last=(${last[0]},${last[1]})',
  );
}

/// Per-edge lengths (meters) — long max segments explain “straight” chords vs map water.
void mapDebugLogRouteSegmentMeters(List<List<double>> lonLat) {
  if (!kDebugMode || lonLat.length < 2) {
    return;
  }
  final d = <double>[];
  for (var i = 0; i < lonLat.length - 1; i++) {
    d.add(
      haversineMeters(
        lonLat[i][1],
        lonLat[i][0],
        lonLat[i + 1][1],
        lonLat[i + 1][0],
      ),
    );
  }
  d.sort();
  final sum = d.fold<double>(0, (a, b) => a + b);
  final n = d.length;
  final p90 = d[((n - 1) * 0.9).round().clamp(0, n - 1)];
  mapDebugLog(
    'route segment lengths | n=$n meanM=${(sum / n).toStringAsFixed(0)} '
    'minM=${d.first.toStringAsFixed(0)} maxM=${d.last.toStringAsFixed(0)} '
    'p90M=${p90.toStringAsFixed(0)}',
  );
}

void mapDebugLogPolylinePositions(String context, List<Position> positions) {
  if (!kDebugMode || positions.isEmpty) {
    return;
  }
  final n = positions.length;
  final f = positions.first;
  final l = positions.last;
  final m = positions[n ~/ 2];
  mapDebugLog(
    '$context | LineString positions=$n '
    'first(lng,lat)=(${f.lng},${f.lat}) mid=(${m.lng},${m.lat}) last=(${l.lng},${l.lat})',
  );
}

/// Pairs of distinct launches within [maxMeters] (explains stacked pins downtown).
void mapDebugLogLaunchPairsWithin(double maxMeters) {
  if (!kDebugMode) {
    return;
  }
  mapDebugLog('launch pair scan: threshold=${maxMeters}m');
  for (var i = 0; i < kLaunchPoints.length; i++) {
    for (var j = i + 1; j < kLaunchPoints.length; j++) {
      final a = kLaunchPoints[i];
      final b = kLaunchPoints[j];
      final d = haversineMeters(
        a.latitude,
        a.longitude,
        b.latitude,
        b.longitude,
      );
      if (d <= maxMeters) {
        mapDebugLog(
          '${d.toStringAsFixed(0)}m: ${a.id} ↔ ${b.id} '
          '(${a.name} / ${b.name})',
        );
      }
    }
  }
}
