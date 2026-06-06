import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_map/src/data/launch_points.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'launch_providers.g.dart';

LaunchPoint? _readLaunchPointIfExists(
  LaunchPoint Function(String id) readProvider,
  String id,
) {
  if (findLaunchPointById(id) == null) {
    return null;
  }
  return readProvider(id);
}

/// Nullable launch lookup routed through [launchPointByIdProvider].
extension LaunchPointLookupOnRef on Ref {
  /// Returns the launch for [id], or null when not in the catalog.
  LaunchPoint? readLaunchPointIfExists(String id) {
    return _readLaunchPointIfExists(
      (launchId) => read(launchPointByIdProvider(launchId)),
      id,
    );
  }
}

/// Nullable launch lookup routed through [launchPointByIdProvider].
extension LaunchPointLookupOnWidgetRef on WidgetRef {
  /// Returns the launch for [id], or null when not in the catalog.
  LaunchPoint? readLaunchPointIfExists(String id) {
    return _readLaunchPointIfExists(
      (launchId) => read(launchPointByIdProvider(launchId)),
      id,
    );
  }
}

/// Resolves a curated launch by id.
@Riverpod(keepAlive: true)
LaunchPoint launchPointById(Ref ref, String id) {
  final launch = findLaunchPointById(id);
  if (launch == null) {
    throw StateError('No launch with id: $id');
  }
  return launch;
}
