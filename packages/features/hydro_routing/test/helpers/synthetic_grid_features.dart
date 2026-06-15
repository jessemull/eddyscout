import 'dart:math' as math;

import 'package:eddyscout_hydro_routing/src/data/river_geojson.dart';

/// LineString features forming a grid with roughly [targetNodes] vertices.
List<HydroLineFeature> buildSyntheticGridFeatures(int targetNodes) {
  final side = math.sqrt(targetNodes).ceil();
  const baseLat = 45.5;
  const baseLon = -122.6;
  const stepLat = 0.001;
  const stepLon = 0.001;

  final features = <HydroLineFeature>[];
  for (var r = 0; r < side; r++) {
    final coords = List<List<double>>.generate(
      side,
      (c) => [baseLon + c * stepLon, baseLat + r * stepLat],
    );
    features.add(
      HydroLineFeature(
        riverSystemKey: 'bench',
        reachId: null,
        coordinatesLonLat: coords,
      ),
    );
  }
  for (var c = 0; c < side; c++) {
    final coords = List<List<double>>.generate(
      side,
      (r) => [baseLon + c * stepLon, baseLat + r * stepLat],
    );
    features.add(
      HydroLineFeature(
        riverSystemKey: 'bench',
        reachId: null,
        coordinatesLonLat: coords,
      ),
    );
  }
  return features;
}

/// Expected unique vertex count for [buildSyntheticGridFeatures].
int syntheticGridVertexCount(int targetNodes) {
  final side = math.sqrt(targetNodes).ceil();
  return side * side;
}
