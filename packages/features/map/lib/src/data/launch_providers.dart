import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'launch_providers.g.dart';

/// Resolves a curated launch by id.
///
/// Throws [NotFoundFailure] when [id] is not in the catalog.
@Riverpod(keepAlive: true)
Future<LaunchPoint> launchPointById(Ref ref, String id) async {
  final launch = findLaunchPointById(id);
  if (launch == null) {
    throw NotFoundFailure(message: 'No launch with id: $id');
  }
  return launch;
}
