import 'package:eddyscout_hydro_routing/src/data/river_geojson.dart';

/// Parses and concatenates LineString features from multiple GeoJSON documents.
List<HydroLineFeature> parseAndMergeHydroGeoJson(List<String> rawDocs) {
  final merged = <HydroLineFeature>[];
  for (final raw in rawDocs) {
    merged.addAll(parseHydroGeoJson(raw));
  }
  return merged;
}
