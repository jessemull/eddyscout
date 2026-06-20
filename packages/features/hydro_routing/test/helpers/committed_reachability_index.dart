import 'dart:io';

/// Reads the committed app reachability index by walking up to the repo root.
Future<String> readCommittedReachabilityIndex() async {
  return File(committedReachabilityIndexPath()).readAsString();
}

/// Absolute path to the bundled reachability index JSON in the app assets tree.
String committedReachabilityIndexPath() {
  var dir = Directory.current;
  while (true) {
    final candidate = File(
      '${dir.path}/apps/eddyscout/assets/data/'
      'launch_reachability_index.json',
    );
    if (candidate.existsSync()) {
      return candidate.path;
    }
    final parent = dir.parent;
    if (parent.path == dir.path) {
      throw StateError(
        'Could not find reachability index asset from ${Directory.current.path}',
      );
    }
    dir = parent;
  }
}
