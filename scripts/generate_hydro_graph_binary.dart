#!/usr/bin/env dart
// Generates apps/eddyscout/assets/data/unified_hydro_graph.bin
//
// Usage:
//   dart run scripts/generate_hydro_graph_binary.dart
//   dart run scripts/generate_hydro_graph_binary.dart --check

import 'dart:io';

import 'package:eddyscout_hydro_routing/eddyscout_hydro_routing.dart';
import 'package:eddyscout_hydro_routing/src/data/river_graph_binary_codec.dart'
    show RiverGraphBinaryMetadata;

const _outputRelativePath =
    'apps/eddyscout/assets/data/unified_hydro_graph.bin';

/// Fixed timestamp keeps committed bytes stable when geometry is unchanged.
const _generatedAtIso = '2026-06-23T00:00:00.000Z';

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

  final outputFile = File('${repoRoot.path}/$_outputRelativePath');
  if (checkOnly) {
    if (!outputFile.existsSync()) {
      stderr.writeln('Missing committed graph binary: ${outputFile.path}');
      exit(1);
    }
    final committed = await outputFile.readAsBytes();
    final decoded = RiverRoutePlanner.fromBinary(committed);
    if (!planner.hasSameUnifiedGraphAs(decoded)) {
      stderr.writeln(
        'Hydro graph binary is stale '
        '(fresh=${planner.unifiedGraphVertexCount} vertices, '
        'committed=${decoded.unifiedGraphVertexCount} vertices). '
        'Run: make gen-hydro-graph',
      );
      exit(1);
    }
    stdout.writeln('Hydro graph binary is up to date.');
    return;
  }

  final bytes = planner.encodeUnifiedGraphBinary(
    metadata: const RiverGraphBinaryMetadata(generatedAtIso: _generatedAtIso),
  );

  await outputFile.parent.create(recursive: true);
  await outputFile.writeAsBytes(bytes);
  stdout.writeln(
    'Wrote ${outputFile.path} (${bytes.length} bytes, '
    '${planner.unifiedGraphVertexCount} vertices)',
  );
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
