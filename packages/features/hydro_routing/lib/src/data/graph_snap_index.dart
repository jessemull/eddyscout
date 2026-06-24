import 'dart:math' as math;

import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_hydro_routing/src/data/river_graph.dart';

/// Default route snap radius in meters.
///
/// Matches the default [RiverLineGraph.route] `maxSnapMeters`.
const kGraphSnapBaseCellMeters = 900.0;

/// Result of snapping a point to the nearest vertex or edge on the graph.
class GraphSnapResult {
  /// Creates a snap result.
  const GraphSnapResult({
    required this.lat,
    required this.lon,
    required this.distanceMeters,
    this.vertexIndex,
    this.edgeU,
    this.edgeV,
    this.reachId,
  });

  /// Snapped latitude in degrees.
  final double lat;

  /// Snapped longitude in degrees.
  final double lon;

  /// Haversine distance from query point to snap in meters.
  final double distanceMeters;

  /// Vertex index when snapped to a graph node.
  final int? vertexIndex;

  /// Lower endpoint of edge when snapped along a segment.
  final int? edgeU;

  /// Upper endpoint of edge when snapped along a segment.
  final int? edgeV;

  /// Reach id when known.
  final String? reachId;
}

/// Uniform grid spatial index for route-time snap and vertex lookup.
class GraphSnapIndex {
  /// Builds an index over [lat], [lon], and undirected [adj] edges.
  GraphSnapIndex({
    required List<double> lat,
    required List<double> lon,
    required List<List<GraphEdge>> adj,
    required List<String?> vertexReachId,
    double refLatitude = 45.0,
    double baseCellMeters = kGraphSnapBaseCellMeters,
  }) : _lat = lat,
       _lon = lon,
       _adj = adj,
       _vertexReachId = vertexReachId,
       _cellLatDeg = baseCellMeters / _metersPerDegreeLatitude,
       _cellLonDeg =
           baseCellMeters /
           (_metersPerDegreeLatitude *
               math.cos(refLatitude * math.pi / 180).abs().clamp(1e-6, 1.0)) {
    _buildVertexBuckets();
    _buildEdgeBuckets();
  }

  static const _metersPerDegreeLatitude = 111320.0;

  final List<double> _lat;
  final List<double> _lon;
  final List<List<GraphEdge>> _adj;
  final List<String?> _vertexReachId;
  final double _cellLatDeg;
  final double _cellLonDeg;
  final Map<(int, int), List<int>> _vertexBuckets = {};
  final Map<(int, int), List<(int, int)>> _edgeBuckets = {};

  /// Nearest vertex within [maxMeters], or null when none qualify.
  int? nearestVertexIndex(double la, double lo, double maxMeters) {
    var bestI = -1;
    var bestD = maxMeters;
    for (final i in _candidateVertices(la, lo, maxMeters)) {
      final d = haversineMeters(_lat[i], _lon[i], la, lo);
      if (d < bestD) {
        bestD = d;
        bestI = i;
      }
    }
    return bestI < 0 ? null : bestI;
  }

  /// Nearest snap target within [maxMeters] using the same semantics as brute
  /// force vertex-then-edge iteration order.
  GraphSnapResult? nearestSnap(double la, double lo, double maxMeters) {
    GraphSnapResult? best;

    void consider(GraphSnapResult candidate) {
      if (candidate.distanceMeters > maxMeters) {
        return;
      }
      if (best == null || candidate.distanceMeters < best!.distanceMeters) {
        best = candidate;
      }
    }

    for (final i in _candidateVertices(la, lo, maxMeters)) {
      final d = haversineMeters(_lat[i], _lon[i], la, lo);
      consider(
        GraphSnapResult(
          lat: _lat[i],
          lon: _lon[i],
          distanceMeters: d,
          vertexIndex: i,
          reachId: _vertexReachId[i],
        ),
      );
    }

    for (final pair in _candidateEdges(la, lo, maxMeters)) {
      final u = pair.$1;
      final v = pair.$2;
      final closest = _closestPointOnSegment(
        la1: _lat[u],
        lo1: _lon[u],
        la2: _lat[v],
        lo2: _lon[v],
        la: la,
        lo: lo,
      );
      final d = haversineMeters(closest.lat, closest.lon, la, lo);
      final reachId = _vertexReachId[u] ?? _vertexReachId[v];
      if (closest.onVertexU) {
        consider(
          GraphSnapResult(
            lat: _lat[u],
            lon: _lon[u],
            distanceMeters: d,
            vertexIndex: u,
            reachId: reachId,
          ),
        );
      } else if (closest.onVertexV) {
        consider(
          GraphSnapResult(
            lat: _lat[v],
            lon: _lon[v],
            distanceMeters: d,
            vertexIndex: v,
            reachId: reachId,
          ),
        );
      } else {
        consider(
          GraphSnapResult(
            lat: closest.lat,
            lon: closest.lon,
            distanceMeters: d,
            edgeU: u,
            edgeV: v,
            reachId: reachId,
          ),
        );
      }
    }

    return best;
  }

  void _buildVertexBuckets() {
    for (var i = 0; i < _lat.length; i++) {
      _vertexBuckets.putIfAbsent(_cell(_lat[i], _lon[i]), () => []).add(i);
    }
  }

  void _buildEdgeBuckets() {
    for (var u = 0; u < _adj.length; u++) {
      for (final e in _adj[u]) {
        if (u >= e.to) {
          continue;
        }
        final v = e.to;
        for (final cell in _cellsForSegment(
          _lat[u],
          _lon[u],
          _lat[v],
          _lon[v],
        )) {
          _edgeBuckets.putIfAbsent(cell, () => []).add((u, v));
        }
      }
    }
  }

  Iterable<int> _candidateVertices(
    double la,
    double lo,
    double maxMeters,
  ) sync* {
    final seen = <int>{};
    for (final cell in _cellsInRadius(la, lo, maxMeters)) {
      final bucket = _vertexBuckets[cell];
      if (bucket == null) {
        continue;
      }
      bucket.forEach(seen.add);
    }
    final sorted = seen.toList()..sort();
    for (final i in sorted) {
      yield i;
    }
  }

  Iterable<(int, int)> _candidateEdges(
    double la,
    double lo,
    double maxMeters,
  ) sync* {
    final seen = <(int, int)>{};
    for (final cell in _cellsInRadius(la, lo, maxMeters)) {
      final bucket = _edgeBuckets[cell];
      if (bucket == null) {
        continue;
      }
      for (final pair in bucket) {
        if (seen.add(pair)) {
          // defer sort
        }
      }
    }
    final sorted = seen.toList()
      ..sort((a, b) {
        final cu = a.$1.compareTo(b.$1);
        return cu != 0 ? cu : a.$2.compareTo(b.$2);
      });
    for (final pair in sorted) {
      yield pair;
    }
  }

  Iterable<(int, int)> _cellsInRadius(
    double la,
    double lo,
    double maxMeters,
  ) sync* {
    final cellMeters = _cellLatDeg * _metersPerDegreeLatitude;
    final rings = (maxMeters / cellMeters).ceil() + 1;
    final (centerRow, centerCol) = _cell(la, lo);
    for (var dr = -rings; dr <= rings; dr++) {
      for (var dc = -rings; dc <= rings; dc++) {
        yield (centerRow + dr, centerCol + dc);
      }
    }
  }

  Iterable<(int, int)> _cellsForSegment(
    double la1,
    double lo1,
    double la2,
    double lo2,
  ) sync* {
    final minLa = la1 < la2 ? la1 : la2;
    final maxLa = la1 > la2 ? la1 : la2;
    final minLo = lo1 < lo2 ? lo1 : lo2;
    final maxLo = lo1 > lo2 ? lo1 : lo2;
    final rowStart = (minLa / _cellLatDeg).floor();
    final rowEnd = (maxLa / _cellLatDeg).floor();
    final colStart = (minLo / _cellLonDeg).floor();
    final colEnd = (maxLo / _cellLonDeg).floor();
    for (var row = rowStart; row <= rowEnd; row++) {
      for (var col = colStart; col <= colEnd; col++) {
        yield (row, col);
      }
    }
  }

  (int, int) _cell(double la, double lo) {
    final row = (la / _cellLatDeg).floor();
    final col = (lo / _cellLonDeg).floor();
    return (row, col);
  }

  static ({double lat, double lon, bool onVertexU, bool onVertexV})
  _closestPointOnSegment({
    required double la1,
    required double lo1,
    required double la2,
    required double lo2,
    required double la,
    required double lo,
  }) {
    const eps = 1e-9;
    final cosLat = _cosLatRef(la1, la2, la);
    final x1 = lo1 * cosLat;
    final y1 = la1;
    final x2 = lo2 * cosLat;
    final y2 = la2;
    final x = lo * cosLat;
    final y = la;

    final dx = x2 - x1;
    final dy = y2 - y1;
    final len2 = dx * dx + dy * dy;
    if (len2 < eps) {
      return (lat: la1, lon: lo1, onVertexU: true, onVertexV: false);
    }

    final t = ((x - x1) * dx + (y - y1) * dy) / len2;
    if (t <= eps) {
      return (lat: la1, lon: lo1, onVertexU: true, onVertexV: false);
    }
    if (t >= 1 - eps) {
      return (lat: la2, lon: lo2, onVertexU: false, onVertexV: true);
    }

    final projLon = (x1 + t * dx) / cosLat;
    final projLat = y1 + t * dy;
    return (lat: projLat, lon: projLon, onVertexU: false, onVertexV: false);
  }

  static double _cosLatRef(double la1, double la2, double la) {
    final ref = (la1 + la2 + la) / 3 * math.pi / 180;
    final c = math.cos(ref);
    return c.abs() < 1e-6 ? 1e-6 : c;
  }
}
