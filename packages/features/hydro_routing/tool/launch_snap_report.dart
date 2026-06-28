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

  final rows =
      <
        ({
          String id,
          double routingMeters,
          double? accessMeters,
          String system,
        })
      >[];
  for (final launch in kLaunchPoints) {
    final routingSnap = unified.snapToVertex(
      launch.routingLatitude,
      launch.routingLongitude,
      maxSnapMeters: 10000,
    );
    final accessSnap = launch.hasDistinctWaterEntry
        ? unified.snapToVertex(
            launch.accessLatitude,
            launch.accessLongitude,
            maxSnapMeters: 10000,
          )
        : null;
    rows.add((
      id: launch.id,
      routingMeters: routingSnap?.snapMeters ?? double.infinity,
      accessMeters: accessSnap?.snapMeters,
      system: launch.riverSystem.name,
    ));
  }
  rows.sort((a, b) => b.routingMeters.compareTo(a.routingMeters));
  for (final row in rows) {
    final flag = row.routingMeters > kCatalogWaterEntrySnapMaxMeters
        ? ' ***'
        : row.routingMeters > 100
        ? ' *'
        : '';
    final accessNote = row.accessMeters == null
        ? ''
        : '  access=${row.accessMeters!.toStringAsFixed(0)}m';
    // CLI diagnostic output (not a test).
    // ignore: avoid_print
    print(
      '${row.routingMeters.toStringAsFixed(0).padLeft(5)} m  '
      '${row.id.padRight(24)} (${row.system})$flag$accessNote',
    );
  }
}
