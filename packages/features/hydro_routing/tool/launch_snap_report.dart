/// Developer CLI: prints catalog launch snap distances to stdout.
library;

import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_hydro_routing/eddyscout_hydro_routing.dart';
import 'package:eddyscout_hydro_routing/src/data/river_graph.dart';

import '../test/helpers/bundled_hydro_assets.dart';

void main() async {
  final docs = await readBundledHydroGeoJsonDocuments();
  final features = parseAndMergeHydroGeoJson(docs);
  final unified = RiverLineGraph.fromAllFeatures(features);

  final rows = <({String id, double meters, String system})>[];
  for (final launch in kLaunchPoints) {
    final snap = unified.snapToVertex(
      launch.latitude,
      launch.longitude,
      maxSnapMeters: 10000,
    );
    rows.add((
      id: launch.id,
      meters: snap?.snapMeters ?? double.infinity,
      system: launch.riverSystem.name,
    ));
  }
  rows.sort((a, b) => b.meters.compareTo(a.meters));
  for (final row in rows) {
    final flag = row.meters > 200
        ? ' ***'
        : row.meters > 100
        ? ' *'
        : '';
    // CLI diagnostic output (not a test).
    // ignore: avoid_print
    print(
      '${row.meters.toStringAsFixed(0).padLeft(5)} m  '
      '${row.id.padRight(24)} (${row.system})$flag',
    );
  }
}
