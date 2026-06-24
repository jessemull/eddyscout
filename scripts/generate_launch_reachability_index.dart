#!/usr/bin/env dart
// Generates apps/eddyscout/assets/data/launch_reachability_index.json
//
// Expected runtime: < 2 s for ~19 catalog launches on CI hardware.
//
// Usage:
//   dart run scripts/generate_launch_reachability_index.dart
//   dart run scripts/generate_launch_reachability_index.dart --check

import 'dart:io';

import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_hydro_routing/src/data/launch_reachability_index_generator.dart';
import 'package:eddyscout_hydro_routing/src/data/river_route_planner.dart';

const _hydroAssetNames = [
  'willamette_waterway.geojson',
  'columbia_lower_waterway.geojson',
  'columbia_gorge_waterway.geojson',
];

const _bridgesAssetName = 'confluence_bridges.json';

const _outputRelativePath =
    'apps/eddyscout/assets/data/launch_reachability_index.json';

/// Bump when regenerating committed reachability JSON after hydro/catalog changes.
final _indexGeneratedAt = DateTime.utc(2026, 6, 23);

Future<void> main(List<String> args) async {
  final checkOnly = args.contains('--check');
  final repoRoot = _findRepoRoot();
  final hydroDir = Directory('${repoRoot.path}/apps/eddyscout/assets/hydro');
  if (!hydroDir.existsSync()) {
    stderr.writeln('Missing hydro assets directory: ${hydroDir.path}');
    exit(1);
  }

  final docs = <String>[];
  for (final name in _hydroAssetNames) {
    final file = File('${hydroDir.path}/$name');
    if (!file.existsSync()) {
      stderr.writeln('Missing hydro asset: ${file.path}');
      exit(1);
    }
    docs.add(await file.readAsString());
  }

  final bridgesFile = File('${hydroDir.path}/$_bridgesAssetName');
  if (!bridgesFile.existsSync()) {
    stderr.writeln('Missing hydro asset: ${bridgesFile.path}');
    exit(1);
  }
  final bridgesJson = await bridgesFile.readAsString();

  final planner = RiverRoutePlanner.fromGeoJsonDocuments(
    docs,
    confluenceBridgesJson: bridgesJson,
  );
  final jsonText = LaunchReachabilityIndexGenerator.generateJson(
    planner: planner,
    catalog: kLaunchPoints,
    generatedAt: _indexGeneratedAt,
    crossSystemReachability: true,
    onWarning: stderr.writeln,
  );

  final outputFile = File('${repoRoot.path}/$_outputRelativePath');
  if (checkOnly) {
    if (!outputFile.existsSync()) {
      stderr.writeln('Missing committed index: ${outputFile.path}');
      exit(1);
    }
    final committed = await outputFile.readAsString();
    if (committed.trim() != jsonText.trim()) {
      stderr.writeln('Reachability index is stale. Run: make gen-reachability');
      exit(1);
    }
    stdout.writeln('Reachability index is up to date.');
    return;
  }

  await outputFile.parent.create(recursive: true);
  await outputFile.writeAsString('$jsonText\n');
  stdout.writeln('Wrote ${outputFile.path}');
}

Directory _findRepoRoot() {
  var dir = Directory.current;
  while (true) {
    final pubspec = File('${dir.path}/pubspec.yaml');
    final melosMarker = File('${dir.path}/melos.yaml');
    if (pubspec.existsSync()) {
      final content = pubspec.readAsStringSync();
      if (content.contains('melos:') || melosMarker.existsSync()) {
        return dir;
      }
    }
    final parent = dir.parent;
    if (parent.path == dir.path) {
      return Directory.current;
    }
    dir = parent;
  }
}
