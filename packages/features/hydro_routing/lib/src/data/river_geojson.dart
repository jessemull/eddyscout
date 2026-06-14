import 'dart:convert';

/// One LineString from hydro GeoJSON with optional river metadata.
class HydroLineFeature {
  /// Creates a parsed line with optional river filter key and vertices.
  const HydroLineFeature({
    required this.riverSystemKey,
    required this.reachId,
    required this.coordinatesLonLat,
  });

  /// Matches `RiverSystem.name` when present; null means all rivers.
  final String? riverSystemKey;

  /// Bundled reach identifier from `properties.reach_id`, when present.
  final String? reachId;

  /// GeoJSON order: [lon, lat] per vertex.
  final List<List<double>> coordinatesLonLat;
}

/// Parses a FeatureCollection containing LineString features.
List<HydroLineFeature> parseHydroGeoJson(String jsonText) {
  final root = jsonDecode(jsonText) as Map<String, dynamic>;
  if (root['type'] != 'FeatureCollection') {
    throw const FormatException('Expected FeatureCollection');
  }
  final features = root['features'] as List<dynamic>? ?? [];
  final out = <HydroLineFeature>[];
  for (final raw in features) {
    final f = raw as Map<String, dynamic>;
    final geom = f['geometry'] as Map<String, dynamic>?;
    if (geom == null) {
      continue;
    }
    final type = geom['type'] as String?;
    if (type != 'LineString') {
      continue;
    }
    final coords = geom['coordinates'] as List<dynamic>? ?? [];
    final ring = <List<double>>[];
    for (final c in coords) {
      final pair = c as List<dynamic>;
      if (pair.length >= 2) {
        ring.add([(pair[0] as num).toDouble(), (pair[1] as num).toDouble()]);
      }
    }
    if (ring.length < 2) {
      continue;
    }
    final props = f['properties'] as Map<String, dynamic>?;
    final rs = props?['river_system'] as String?;
    final reachId = props?['reach_id'] as String?;
    out.add(
      HydroLineFeature(
        riverSystemKey: rs,
        reachId: reachId,
        coordinatesLonLat: ring,
      ),
    );
  }
  return out;
}
