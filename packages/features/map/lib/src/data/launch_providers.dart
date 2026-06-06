import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_map/src/data/launch_points.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'launch_providers.g.dart';

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

/// Resolves a curated launch by id.
@Riverpod(keepAlive: true)
Result<LaunchPoint, AppFailure> launchPointById(Ref ref, String id) {
  final launch = findLaunchPointById(id);
  if (launch == null) {
    return Result.failure(
      NotFoundFailure(message: 'No launch with id: $id'),
    );
  }
  return Result.success(launch);
}
