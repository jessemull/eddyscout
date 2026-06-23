#!/usr/bin/env dart
// Generates apps/eddyscout/assets/data/launch_suggested_trips_index.json
//
// Expected runtime: < 2 s for ~19 catalog launches on CI hardware.
//
// Usage:
//   dart run scripts/generate_launch_suggested_trips_index.dart
//   dart run scripts/generate_launch_suggested_trips_index.dart --check

import 'dart:io';

import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_hydro_routing/eddyscout_hydro_routing.dart';

const _outputRelativePath =
    'apps/eddyscout/assets/data/launch_suggested_trips_index.json';

Future<void> main(List<String> args) async {
  final checkOnly = args.contains('--check');
  final repoRoot = _findRepoRoot();
  final hydroDir = Directory('${repoRoot.path}/apps/eddyscout/assets/hydro');
  if (!hydroDir.existsSync()) {
    stderr.writeln('Missing hydro assets directory: ${hydroDir.path}');
    exit(1);
  }

  final docs = <String>[];
  for (final name in bundledHydroGeoJsonAssetFileNames) {
    final file = File('${hydroDir.path}/$name');
    if (!file.existsSync()) {
      stderr.writeln('Missing hydro asset: ${file.path}');
      exit(1);
    }
    docs.add(await file.readAsString());
  }

  final bridgesFile = File('${hydroDir.path}/confluence_bridges.json');
  final bridgesJson = bridgesFile.existsSync()
      ? await bridgesFile.readAsString()
      : null;

  final planner = RiverRoutePlanner.fromGeoJsonDocuments(
    docs,
    confluenceBridgesJson: bridgesJson,
  );
  final generatedAt = DateTime.utc(2026, 6, 20);
  final jsonText = LaunchSuggestedTripsIndexGenerator.generateJson(
    planner: planner,
    catalog: kLaunchPoints,
    generatedAt: generatedAt,
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
      stderr.writeln(
        'Suggested trips index is stale. Run: make gen-suggested-trips',
      );
      exit(1);
    }
    stdout.writeln('Suggested trips index is up to date.');
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
