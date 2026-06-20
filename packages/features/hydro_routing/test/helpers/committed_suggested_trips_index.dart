import 'dart:io';

/// Reads the committed app suggested trips index by walking up to the repo root.
Future<String> readCommittedSuggestedTripsIndex() async {
  return File(committedSuggestedTripsIndexPath()).readAsString();
}

/// Absolute path to the bundled suggested trips index JSON in the app assets tree.
String committedSuggestedTripsIndexPath() {
  var dir = Directory.current;
  while (true) {
    final candidate = File(
      '${dir.path}/apps/eddyscout/assets/data/'
      'launch_suggested_trips_index.json',
    );
    if (candidate.existsSync()) {
      return candidate.path;
    }
    final parent = dir.parent;
    if (parent.path == dir.path) {
      throw StateError(
        'Could not find suggested trips index asset from '
        '${Directory.current.path}',
      );
    }
    dir = parent;
  }
}
