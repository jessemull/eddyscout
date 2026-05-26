import 'package:eddyscout_hydro_routing/src/data/geodesy.dart';
import 'package:eddyscout_hydro_routing/src/data/river_geojson.dart';
import 'package:eddyscout_hydro_routing/src/domain/route_result.dart';

/// Undirected weighted graph from hydro LineStrings.
///
/// Endpoints within the merge threshold of an existing vertex are merged.
class RiverLineGraph {
  RiverLineGraph._(this._lat, this._lon, this._adj);

  final List<double> _lat;
  final List<double> _lon;
  final List<List<({int to, double w})>> _adj;

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

    int findOrAdd(double la, double lo) {
      for (var i = 0; i < lat.length; i++) {
        if (haversineMeters(lat[i], lon[i], la, lo) <= mergeVertexMeters) {
          return i;
        }
      }
      lat.add(la);
      lon.add(lo);
      adj.add([]);
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
        final u = findOrAdd(la1, lon1);
        final v = findOrAdd(la2, lon2);
        final w = haversineMeters(lat[u], lon[u], lat[v], lon[v]);
        addUndirected(u, v, w);
      }
    }

    return RiverLineGraph._(lat, lon, adj);
  }

  /// Shortest path along the graph between nearest vertices to each launch.
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

    final startIdx = _nearestVertexWithin(startLat, startLon, maxSnapMeters);
    final endIdx = _nearestVertexWithin(endLat, endLon, maxSnapMeters);
    if (startIdx == null) {
      return const RouteFailure(
        code: RouteFailureCode.putInTooFar,
      );
    }
    if (endIdx == null) {
      return const RouteFailure(
        code: RouteFailureCode.takeOutTooFar,
      );
    }

    final path = _dijkstra(startIdx, endIdx);
    if (path == null) {
      return const RouteFailure(
        code: RouteFailureCode.noConnectedPath,
      );
    }

    final snapStartD = haversineMeters(
      startLat,
      startLon,
      _lat[path.first],
      _lon[path.first],
    );
    final snapEndD = haversineMeters(
      endLat,
      endLon,
      _lat[path.last],
      _lon[path.last],
    );
    var graphDist = 0.0;
    for (var i = 0; i < path.length - 1; i++) {
      graphDist += haversineMeters(
        _lat[path[i]],
        _lon[path[i]],
        _lat[path[i + 1]],
        _lon[path[i + 1]],
      );
    }
    final lengthMeters = graphDist + snapStartD + snapEndD;

    /// Append [lon, lat] if it is not ~duplicate of [last].
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
    for (final i in path) {
      appendIfDistinct(polyline, _lon[i], _lat[i]);
    }
    appendIfDistinct(polyline, endLon, endLat);

    return RouteSuccess(polylineLonLat: polyline, lengthMeters: lengthMeters);
  }

  int? _nearestVertexWithin(double la, double lo, double maxM) {
    var bestI = -1;
    var bestD = maxM;
    for (var i = 0; i < _lat.length; i++) {
      final d = haversineMeters(_lat[i], _lon[i], la, lo);
      if (d < bestD) {
        bestD = d;
        bestI = i;
      }
    }
    return bestI < 0 ? null : bestI;
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
