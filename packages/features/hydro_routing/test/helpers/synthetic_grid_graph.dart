import 'dart:math' as math;

import 'package:eddyscout_hydro_routing/src/data/geodesy.dart';
import 'package:eddyscout_hydro_routing/src/data/river_graph.dart';

/// Builds a connected grid graph near Portland with roughly [targetNodes] vertices.
RiverLineGraph buildSyntheticGridGraph(int targetNodes) {
  final side = math.sqrt(targetNodes).ceil();
  final lat = <double>[];
  final lon = <double>[];
  final adj = <List<GraphEdge>>[];

  const baseLat = 45.5;
  const baseLon = -122.6;
  const stepLat = 0.001;
  const stepLon = 0.001;

  for (var r = 0; r < side; r++) {
    for (var c = 0; c < side; c++) {
      lat.add(baseLat + r * stepLat);
      lon.add(baseLon + c * stepLon);
      adj.add([]);
    }
  }

  int idx(int r, int c) => r * side + c;

  void link(int u, int v) {
    final w = haversineMeters(lat[u], lon[u], lat[v], lon[v]);
    adj[u].add((to: v, w: w, riverSystem: 'bench', oneWay: false));
    adj[v].add((to: u, w: w, riverSystem: 'bench', oneWay: false));
  }

  for (var r = 0; r < side; r++) {
    for (var c = 0; c < side; c++) {
      final u = idx(r, c);
      if (c + 1 < side) {
        link(u, idx(r, c + 1));
      }
      if (r + 1 < side) {
        link(u, idx(r + 1, c));
      }
    }
  }

  return RiverLineGraph.forTesting(lat: lat, lon: lon, adj: adj);
}
