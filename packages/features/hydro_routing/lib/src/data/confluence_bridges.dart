import 'dart:convert';

import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_hydro_routing/src/data/hydro_debug_log.dart';

/// One curated edge connecting two waterway systems at a confluence.
class ConfluenceBridge {
  /// Creates a bridge between two lat/lon endpoints.
  const ConfluenceBridge({
    required this.id,
    required this.aLat,
    required this.aLon,
    required this.bLat,
    required this.bLon,
  });

  /// Stable identifier for logging and tests.
  final String id;

  /// First endpoint latitude in degrees.
  final double aLat;

  /// First endpoint longitude in degrees.
  final double aLon;

  /// Second endpoint latitude in degrees.
  final double bLat;

  /// Second endpoint longitude in degrees.
  final double bLon;
}

/// Parses a JSON array of confluence bridge objects.
///
/// Returns an empty list for null/empty input. Skips malformed entries.
List<ConfluenceBridge> parseConfluenceBridgesJson(String? jsonText) {
  if (jsonText == null || jsonText.trim().isEmpty) {
    return const [];
  }
  final decoded = jsonDecode(jsonText);
  if (decoded is! List<dynamic>) {
    throw const FormatException('Expected JSON array of confluence bridges');
  }
  final out = <ConfluenceBridge>[];
  for (final raw in decoded) {
    if (raw is! Map<String, dynamic>) {
      hydroDebugLog('parseConfluenceBridgesJson: skipping non-object entry');
      continue;
    }
    final id = raw['id'];
    final a = raw['a'];
    final b = raw['b'];
    if (id is! String || a is! Map || b is! Map) {
      hydroDebugLog(
        'parseConfluenceBridgesJson: skipping bridge with bad shape',
      );
      continue;
    }
    final aLat = a['lat'];
    final aLon = a['lon'];
    final bLat = b['lat'];
    final bLon = b['lon'];
    if (aLat is! num || aLon is! num || bLat is! num || bLon is! num) {
      hydroDebugLog(
        'parseConfluenceBridgesJson: skipping bridge $id with bad coords',
      );
      continue;
    }
    out.add(
      ConfluenceBridge(
        id: id,
        aLat: quantizeWgs84Degree(aLat.toDouble()),
        aLon: quantizeWgs84Degree(aLon.toDouble()),
        bLat: quantizeWgs84Degree(bLat.toDouble()),
        bLon: quantizeWgs84Degree(bLon.toDouble()),
      ),
    );
  }
  return out;
}
