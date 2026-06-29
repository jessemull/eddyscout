#!/usr/bin/env dart
// Validates catalog launch water-entry snaps against bundled hydro geometry.
//
// Usage:
//   dart run scripts/generate_launch_water_entry_snaps.dart
//   dart run scripts/generate_launch_water_entry_snaps.dart --check

import 'dart:io';

import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_hydro_routing/eddyscout_hydro_routing.dart';
import 'package:eddyscout_hydro_routing/src/data/launch_water_entry_snap_generator.dart'
    show kLaunchWaterEntrySnapMaxMeters;

/// Launches beyond reachability threshold until geometry pass (see README-hydro).
const _knownUnsnappedLaunchIds = {
  'washougal_waterfront',
  'port_of_camas',
  'scappoose_bay_marina',
};

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

  final rows = planner.generateLaunchWaterEntrySnaps(kLaunchPoints)
    ..sort((a, b) => b.snapMeters.compareTo(a.snapMeters));

  if (checkOnly) {
    final violations = planner.launchWaterEntrySnapViolations(
      catalog: kLaunchPoints,
      allowlist: _knownUnsnappedLaunchIds,
      waterEntryOnly: true,
    );
    if (violations.isNotEmpty) {
      stderr.writeln(
        'Launch water-entry snap violations (>${kLaunchWaterEntrySnapMaxMeters.toInt()} m):',
      );
      for (final row in violations) {
        stderr.writeln(
          '  ${row.launchId}: ${row.snapMeters.toStringAsFixed(0)} m',
        );
      }
      stderr.writeln(
        'Run: dart run scripts/generate_launch_water_entry_snaps.dart',
      );
      exit(1);
    }
    stdout.writeln('Launch water-entry snaps within threshold.');
    return;
  }

  for (final row in rows) {
    final flag = row.snapMeters > kLaunchWaterEntrySnapMaxMeters ? ' ***' : '';
    stdout.writeln(
      '${row.snapMeters.toStringAsFixed(0).padLeft(5)} m  '
      '${row.launchId}$flag',
    );
  }
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
