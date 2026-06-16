import 'dart:convert';

import 'package:eddyscout_hydro_routing/src/domain/launch_reachability_index.dart';

/// Parses a bundled reachability index JSON document.
LaunchReachabilityIndex parseLaunchReachabilityIndex(String jsonText) {
  final root = jsonDecode(jsonText) as Map<String, dynamic>;
  final entriesRaw = root['entries'] as Map<String, dynamic>? ?? {};
  final entries = <String, LaunchReachabilityEntry>{};
  for (final entry in entriesRaw.entries) {
    final bands = entry.value as Map<String, dynamic>;
    entries[entry.key] = LaunchReachabilityEntry(
      within5Mi: _stringList(bands['5mi']),
      within10Mi: _stringList(bands['10mi']),
      within20Mi: _stringList(bands['20mi']),
    );
  }

  return LaunchReachabilityIndex(
    schemaVersion: (root['schemaVersion'] as num?)?.toInt() ?? 1,
    generatedAt: DateTime.parse(root['generatedAt'] as String),
    distanceModel: root['distanceModel'] as String? ?? 'graph_plus_snap',
    snapMaxMeters:
        (root['snapMaxMeters'] as num?)?.toDouble() ??
        kReachabilitySnapMaxMeters,
    thresholdsMi: _intList(root['thresholdsMi']) ?? kReachabilityThresholdsMi,
    crossSystemReachability: root['crossSystemReachability'] as bool? ?? false,
    entries: entries,
  );
}

/// Encodes [index] to stable, pretty-printed JSON for committed artifacts.
String encodeLaunchReachabilityIndex(LaunchReachabilityIndex index) {
  final entries = <String, dynamic>{};
  final sortedLaunchIds = index.entries.keys.toList()..sort();
  for (final launchId in sortedLaunchIds) {
    final entry = index.entries[launchId]!;
    entries[launchId] = {
      '5mi': List<String>.from(entry.within5Mi),
      '10mi': List<String>.from(entry.within10Mi),
      '20mi': List<String>.from(entry.within20Mi),
    };
  }

  final root = <String, dynamic>{
    'schemaVersion': index.schemaVersion,
    'generatedAt': index.generatedAt.toUtc().toIso8601String(),
    'distanceModel': index.distanceModel,
    'snapMaxMeters': index.snapMaxMeters,
    'thresholdsMi': index.thresholdsMi,
    'crossSystemReachability': index.crossSystemReachability,
    'entries': entries,
  };
  return const JsonEncoder.withIndent('  ').convert(root);
}

List<String> _stringList(Object? value) {
  if (value is! List<dynamic>) {
    return const [];
  }
  return value.map((e) => e as String).toList();
}

List<int>? _intList(Object? value) {
  if (value is! List<dynamic>) {
    return null;
  }
  return value.map((e) => (e as num).toInt()).toList();
}
