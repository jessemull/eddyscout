import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_map/src/data/launch_points.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'launch_providers.g.dart';

/// Resolves a curated launch by id.
@riverpod
LaunchPoint launchPointById(Ref ref, String id) {
  return kLaunchPoints.firstWhere((launch) => launch.id == id);
}
