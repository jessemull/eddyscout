import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_map/src/domain/launch_points.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Nullable launch lookup from the curated catalog.
extension LaunchPointLookupOnRef on Ref {
  /// Returns the launch for [id], or null when not in the catalog.
  LaunchPoint? readLaunchPointIfExists(String id) => findLaunchPointById(id);
}

/// Nullable launch lookup from the curated catalog.
extension LaunchPointLookupOnWidgetRef on WidgetRef {
  /// Returns the launch for [id], or null when not in the catalog.
  LaunchPoint? readLaunchPointIfExists(String id) => findLaunchPointById(id);
}
