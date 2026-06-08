import 'dart:math' as math;

import 'package:eddyscout_hydro_routing/src/data/geodesy.dart';
import 'package:eddyscout_hydro_routing/src/data/river_geojson.dart';
import 'package:eddyscout_hydro_routing/src/domain/route_result.dart';

/// Snap target on the river graph (vertex or a point along an edge).
class _SnapTarget {
  const _SnapTarget({
    required this.lat,
    required this.lon,
    required this.distanceMeters,
    this.vertexIndex,
    this.edgeU,
    this.edgeV,
    this.reachId,
  });

  final double lat;
  final double lon;
  final double distanceMeters;
  final int? vertexIndex;
  final int? edgeU;
  final int? edgeV;
  final String? reachId;
}

/// Undirected weighted graph from hydro LineStrings.
///
/// Endpoints within the merge threshold of an existing vertex are merged.
class RiverLineGraph {
  RiverLineGraph._(
    this._lat,
    this._lon,
    this._adj,
    this._componentId,
    this._vertexReachId,
  );

  final List<double> _lat;
  final List<double> _lon;
  final List<List<({int to, double w})>> _adj;
  final List<int> _componentId;
  final List<String?> _vertexReachId;

  /// Number of graph vertices after line merge.
  int get vertexCount => _lat.length;

  /// Build from parsed features.
  ///
  /// Keeps lines whose `river_system` matches [riverSystemName] or is null.
  static RiverLineGraph fromFeatures(
    List<HydroLineFeature> features, {
    required String riverSystemName,
    double mergeVertexMeters = 12,
  }) {
    final lat = <double>[];
    final lon = <double>[];
    final adj = <List<({int to, double w})>>[];
    final vertexReachId = <String?>[];

    int findOrAdd(double la, double lo, String? reachId) {
      for (var i = 0; i < lat.length; i++) {
        if (haversineMeters(lat[i], lon[i], la, lo) <= mergeVertexMeters) {
          if (vertexReachId[i] == null && reachId != null) {
            vertexReachId[i] = reachId;
          }
          return i;
        }
      }
      lat.add(la);
      lon.add(lo);
      adj.add([]);
      vertexReachId.add(reachId);
      return lat.length - 1;
    }

    void addUndirected(int u, int v, double w) {
      if (u == v) {
        return;
      }
      final has = adj[u].any((e) => e.to == v);
      if (has) {
        return;
      }
      adj[u].add((to: v, w: w));
      adj[v].add((to: u, w: w));
    }

    for (final f in features) {
      if (f.riverSystemKey != null && f.riverSystemKey != riverSystemName) {
        continue;
      }
      final c = f.coordinatesLonLat;
      for (var i = 0; i < c.length - 1; i++) {
        final lon1 = c[i][0];
        final la1 = c[i][1];
        final lon2 = c[i + 1][0];
        final la2 = c[i + 1][1];
        final u = findOrAdd(la1, lon1, f.reachId);
        final v = findOrAdd(la2, lon2, f.reachId);
        final w = haversineMeters(lat[u], lon[u], lat[v], lon[v]);
        addUndirected(u, v, w);
      }
    }

    final componentId = _labelComponents(adj);
    return RiverLineGraph._(lat, lon, adj, componentId, vertexReachId);
  }

  static List<int> _labelComponents(List<List<({int to, double w})>> adj) {
    final n = adj.length;
    final labels = List<int>.filled(n, -1);
    var next = 0;
    for (var i = 0; i < n; i++) {
      if (labels[i] >= 0) {
        continue;
      }
      final stack = <int>[i];
      labels[i] = next;
      while (stack.isNotEmpty) {
        final u = stack.removeLast();
        for (final e in adj[u]) {
          if (labels[e.to] < 0) {
            labels[e.to] = next;
            stack.add(e.to);
          }
        }
      }
      next++;
    }
    return labels;
  }

  /// Shortest path along the graph between nearest points to each launch.
  RouteResult route(
    double startLat,
    double startLon,
    double endLat,
    double endLon, {
    double maxSnapMeters = 900,
  }) {
    if (_lat.isEmpty) {
      return const RouteFailure(code: RouteFailureCode.noRiverGeometryLoaded);
    }

    final startSnap = _nearestSnap(startLat, startLon, maxSnapMeters);
    final endSnap = _nearestSnap(endLat, endLon, maxSnapMeters);
    if (startSnap == null) {
      return const RouteFailure(code: RouteFailureCode.putInTooFar);
    }
    if (endSnap == null) {
      return const RouteFailure(code: RouteFailureCode.takeOutTooFar);
    }

    if (_onSameUndirectedEdge(startSnap, endSnap)) {
      final alongEdge = haversineMeters(
        startSnap.lat,
        startSnap.lon,
        endSnap.lat,
        endSnap.lon,
      );
      final lengthMeters =
          startSnap.distanceMeters + alongEdge + endSnap.distanceMeters;
      final reachId = startSnap.reachId ?? endSnap.reachId;
      return RouteSuccess(
        polylineLonLat: _buildPolyline(
          startLat: startLat,
          startLon: startLon,
          endLat: endLat,
          endLon: endLon,
          startSnap: startSnap,
          endSnap: endSnap,
          path: const [],
        ),
        lengthMeters: lengthMeters,
        reachId: reachId,
      );
    }

    final startAnchors = _anchorVertices(startSnap);
    final endAnchors = _anchorVertices(endSnap);

    double? bestLen;
    List<int>? bestPath;
    for (final startAnchor in startAnchors) {
      for (final endAnchor in endAnchors) {
        if (_componentId[startAnchor.vertex] !=
            _componentId[endAnchor.vertex]) {
          continue;
        }
        final path = _dijkstra(startAnchor.vertex, endAnchor.vertex);
        if (path == null) {
          continue;
        }
        final len =
            startSnap.distanceMeters +
            startAnchor.extraMeters +
            _pathGraphDistance(path) +
            endAnchor.extraMeters +
            endSnap.distanceMeters;
        if (bestLen == null || len < bestLen) {
          bestLen = len;
          bestPath = path;
        }
      }
    }

    if (bestPath == null || bestLen == null) {
      if (_componentsDiffer(startSnap, endSnap)) {
        return RouteFailure(
          code: RouteFailureCode.disconnectedReach,
          putInReachId: startSnap.reachId,
          takeOutReachId: endSnap.reachId,
        );
      }
      return const RouteFailure(code: RouteFailureCode.noConnectedPath);
    }

    final reachId = _sharedReachId(startSnap, endSnap, bestPath);
    final polyline = _buildPolyline(
      startLat: startLat,
      startLon: startLon,
      endLat: endLat,
      endLon: endLon,
      startSnap: startSnap,
      endSnap: endSnap,
      path: bestPath,
    );

    return RouteSuccess(
      polylineLonLat: polyline,
      lengthMeters: bestLen,
      reachId: reachId,
    );
  }

  bool _onSameUndirectedEdge(_SnapTarget a, _SnapTarget b) {
    if (a.vertexIndex != null &&
        b.vertexIndex != null &&
        a.vertexIndex == b.vertexIndex) {
      return true;
    }
    if (a.edgeU != null &&
        b.edgeU != null &&
        a.edgeV != null &&
        b.edgeV != null) {
      return (a.edgeU == b.edgeU && a.edgeV == b.edgeV) ||
          (a.edgeU == b.edgeV && a.edgeV == b.edgeU);
    }
    return false;
  }

  bool _componentsDiffer(_SnapTarget start, _SnapTarget end) {
    final startComps = _anchorVertices(
      start,
    ).map((a) => _componentId[a.vertex]);
    final endComps = _anchorVertices(end).map((a) => _componentId[a.vertex]);
    for (final sc in startComps) {
      for (final ec in endComps) {
        if (sc == ec) {
          return false;
        }
      }
    }
    return true;
  }

  String? _sharedReachId(_SnapTarget start, _SnapTarget end, List<int> path) {
    final ids = <String>{
      if (start.reachId != null) start.reachId!,
      if (end.reachId != null) end.reachId!,
      for (final i in path)
        if (_vertexReachId[i] != null) _vertexReachId[i]!,
    };
    if (ids.length == 1) {
      return ids.first;
    }
    return null;
  }

  List<({int vertex, double extraMeters})> _anchorVertices(_SnapTarget snap) {
    if (snap.vertexIndex != null) {
      return [(vertex: snap.vertexIndex!, extraMeters: 0)];
    }
    final u = snap.edgeU!;
    final v = snap.edgeV!;
    return [
      (
        vertex: u,
        extraMeters: haversineMeters(snap.lat, snap.lon, _lat[u], _lon[u]),
      ),
      (
        vertex: v,
        extraMeters: haversineMeters(snap.lat, snap.lon, _lat[v], _lon[v]),
      ),
    ];
  }

  double _pathGraphDistance(List<int> path) {
    var dist = 0.0;
    for (var i = 0; i < path.length - 1; i++) {
      dist += haversineMeters(
        _lat[path[i]],
        _lon[path[i]],
        _lat[path[i + 1]],
        _lon[path[i + 1]],
      );
    }
    return dist;
  }

  List<List<double>> _buildPolyline({
    required double startLat,
    required double startLon,
    required double endLat,
    required double endLon,
    required _SnapTarget startSnap,
    required _SnapTarget endSnap,
    required List<int> path,
  }) {
    void appendIfDistinct(List<List<double>> out, double lon, double lat) {
      if (out.isEmpty) {
        out.add([lon, lat]);
        return;
      }
      final prev = out.last;
      if (haversineMeters(prev[1], prev[0], lat, lon) < 0.5) {
        return;
      }
      out.add([lon, lat]);
    }

    final polyline = <List<double>>[];
    appendIfDistinct(polyline, startLon, startLat);
    appendIfDistinct(polyline, startSnap.lon, startSnap.lat);
    for (final i in path) {
      appendIfDistinct(polyline, _lon[i], _lat[i]);
    }
    appendIfDistinct(polyline, endSnap.lon, endSnap.lat);
    appendIfDistinct(polyline, endLon, endLat);
    return polyline;
  }

  _SnapTarget? _nearestSnap(double la, double lo, double maxM) {
    _SnapTarget? best;

    void consider(_SnapTarget candidate) {
      if (candidate.distanceMeters > maxM) {
        return;
      }
      if (best == null || candidate.distanceMeters < best!.distanceMeters) {
        best = candidate;
      }
    }

    for (var i = 0; i < _lat.length; i++) {
      final d = haversineMeters(_lat[i], _lon[i], la, lo);
      consider(
        _SnapTarget(
          lat: _lat[i],
          lon: _lon[i],
          distanceMeters: d,
          vertexIndex: i,
          reachId: _vertexReachId[i],
        ),
      );
    }

    for (var u = 0; u < _adj.length; u++) {
      for (final e in _adj[u]) {
        if (u >= e.to) {
          continue;
        }
        final v = e.to;
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
            _SnapTarget(
              lat: _lat[u],
              lon: _lon[u],
              distanceMeters: d,
              vertexIndex: u,
              reachId: reachId,
            ),
          );
        } else if (closest.onVertexV) {
          consider(
            _SnapTarget(
              lat: _lat[v],
              lon: _lon[v],
              distanceMeters: d,
              vertexIndex: v,
              reachId: reachId,
            ),
          );
        } else {
          consider(
            _SnapTarget(
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
    }

    return best;
  }

  /// Closest point on segment using equirectangular projection (local scale).
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

  /// Returns vertex indices from [src] to [dst], or null if disconnected.
  List<int>? _dijkstra(int src, int dst) {
    final n = _lat.length;
    const inf = 1e30;
    final dist = List<double>.filled(n, inf);
    final prev = List<int>.filled(n, -1);
    final used = List<bool>.filled(n, false);
    dist[src] = 0;

    for (var iter = 0; iter < n; iter++) {
      var u = -1;
      var best = inf;
      for (var i = 0; i < n; i++) {
        if (!used[i] && dist[i] < best) {
          best = dist[i];
          u = i;
        }
      }
      if (u < 0 || best >= inf) {
        break;
      }
      if (u == dst) {
        break;
      }
      used[u] = true;
      for (final e in _adj[u]) {
        if (used[e.to]) {
          continue;
        }
        final nd = dist[u] + e.w;
        if (nd < dist[e.to]) {
          dist[e.to] = nd;
          prev[e.to] = u;
        }
      }
    }

    if (dist[dst] >= inf) {
      return null;
    }

    final rev = <int>[dst];
    var cur = dst;
    while (cur != src) {
      final p = prev[cur];
      if (p < 0) {
        return null;
      }
      rev.add(p);
      cur = p;
    }
    return rev.reversed.toList();
  }
}
