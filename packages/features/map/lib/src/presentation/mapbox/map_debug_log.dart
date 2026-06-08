import 'dart:async' show unawaited;
import 'dart:developer' as developer;

import 'package:eddyscout_hydro_routing/eddyscout_hydro_routing.dart';
import 'package:flutter/foundation.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import '../../domain/launch_points.dart';

/// Prefix on every line so `flutter run` shows them (`debugPrint`).
/// `developer.log` alone often does not appear in the Flutter CLI—use this
/// prefix to filter: `[eddyscout.map]`
///
/// **adb** (Android): `adb logcat -s flutter:I | rg eddyscout.map`
/// or broader: `adb logcat | rg eddyscout`
const String kMapDebugLogName = 'eddyscout.map';

void mapDebugLog(String message) {
  if (kDebugMode) {
    debugPrint('[$kMapDebugLogName] $message');
    developer.log(message, name: kMapDebugLogName);
  }
}

/// Wall-clock ms for correlating log lines with native camera races.
void mapDebugLogTs(String phase) {
  if (kDebugMode) {
    mapDebugLog('TS ${DateTime.now().millisecondsSinceEpoch} | $phase');
  }
}

/// `coordinateBoundsZoomForCamera` — useful when Standard zoom chrome disagrees
/// with `getBounds` / `getCameraState`.
Future<void> mapDebugLogCoordinateBoundsZoom(
  MapboxMap map,
  String label,
) async {
  if (!kDebugMode) {
    return;
  }
  try {
    final cam = await map.getCameraState();
    final opts = CameraOptions(
      center: cam.center,
      zoom: cam.zoom,
      bearing: cam.bearing,
      pitch: cam.pitch,
      padding: cam.padding,
    );
    final cbz = await map.coordinateBoundsZoomForCamera(opts);
    final bb = cbz.bounds;
    mapDebugLog(
      '$label | coordBoundsZoom.zoom=${cbz.zoom.toStringAsFixed(3)} '
      'geoInf=${bb.infiniteBounds}',
    );
  } on Object catch (e, st) {
    mapDebugLog('$label | coordinateBoundsZoomForCamera failed: $e\n$st');
  }
}

/// Camera, `getBounds`, style projection, and optionally gesture settings.
Future<void> mapDebugLogMapboxSnapshot(
  MapboxMap map,
  String label, {
  bool includeGestures = false,
}) async {
  if (!kDebugMode) {
    return;
  }
  try {
    final cam = await map.getCameraState();
    final c = cam.center.coordinates;
    final pad = cam.padding;
    mapDebugLog(
      '$label | camera zoom=${cam.zoom.toStringAsFixed(2)} '
      'bearing=${cam.bearing.toStringAsFixed(1)} '
      'center=(${c.lng.toStringAsFixed(5)},${c.lat.toStringAsFixed(5)}) '
      'pitch=${cam.pitch.toStringAsFixed(1)} '
      'padding T=${pad.top} B=${pad.bottom} L=${pad.left} R=${pad.right}',
    );
  } on Object catch (e, st) {
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
  } on Object catch (e, st) {
    mapDebugLog('$label | getBounds failed: $e\n$st');
  }
  try {
    final p = await map.style.getProjection();
    mapDebugLog('$label | style.getProjection()=${p?.name}');
  } on Object catch (e) {
    mapDebugLog('$label | getProjection failed: $e');
  }
  if (includeGestures) {
    try {
      final g = await map.gestures.getSettings();
      mapDebugLog(
        '$label | gestures pinchZoom=${g.pinchToZoomEnabled} '
        'scroll=${g.scrollEnabled} quickZoom=${g.quickZoomEnabled} '
        'dblTapIn=${g.doubleTapToZoomInEnabled} '
        'dblTouchOut=${g.doubleTouchToZoomOutEnabled} '
        'pinchPan=${g.pinchPanEnabled} zoomAnimAmt=${g.zoomAnimationAmount}',
      );
    } on Object catch (e, st) {
      mapDebugLog('$label | gestures.getSettings failed: $e\n$st');
    }
    try {
      final gip = await map.isGestureInProgress();
      mapDebugLog('$label | isGestureInProgress=$gip');
    } on Object catch (e, st) {
      mapDebugLog('$label | isGestureInProgress failed: $e\n$st');
    }
  }
}

/// Logs `mapDebugLogMapboxSnapshot` at several delays to catch **async**
/// bounds/projection changes after programmatic camera moves (Mapbox Standard).
void mapDebugLogScheduleDeferredMapDiagnostics({
  required MapboxMap? Function() getMap,
  required bool Function() isMounted,
  required String tag,
  List<int> delaysMs = const [16, 50, 100, 250, 500, 1200],
}) {
  if (!kDebugMode) {
    return;
  }
  for (final ms in delaysMs) {
    unawaited(
      Future<void>.delayed(Duration(milliseconds: ms), () async {
        if (!isMounted()) {
          return;
        }
        final map = getMap();
        if (map == null) {
          return;
        }
        await mapDebugLogMapboxSnapshot(
          map,
          '$tag +${ms}ms',
          includeGestures: true,
        );
      }),
    );
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

/// Per-edge lengths (meters) — long max segments explain straight chords
/// vs water.
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
    'first(lng,lat)=(${f.lng},${f.lat}) '
    'mid=(${m.lng},${m.lat}) last=(${l.lng},${l.lat})',
  );
}

/// Pairs of distinct launches within [maxMeters] (stacked pins downtown).
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
