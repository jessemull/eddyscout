import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'planned_route.freezed.dart';

/// Stable read-only route shape for GPX export, saved routes, and trip log.
///
/// Built from a successful plan between two curated launches;
/// not persisted in this package.
@freezed
abstract class PlannedRoute with _$PlannedRoute {
  /// Successful river route between two launches.
  const factory PlannedRoute({
    required String putInLaunchId,
    required String takeOutLaunchId,
    required RiverSystem riverSystem,
    required List<List<double>> polylineLonLat,
    required double lengthMeters,
    String? reachId,
  }) = _PlannedRoute;
}
