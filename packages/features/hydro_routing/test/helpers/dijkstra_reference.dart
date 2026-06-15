import 'package:eddyscout_hydro_routing/src/data/river_graph.dart';

/// O(n²) Dijkstra reference for parity checks against [RiverLineGraph] A*.
List<int>? dijkstraReference(RiverLineGraph graph, int src, int dst) {
  final n = graph.vertexCount;
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
    for (final e in graph.adjacencyForTesting[u]) {
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
