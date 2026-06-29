import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_hydro_routing/src/data/river_graph.dart';
import 'package:eddyscout_hydro_routing/src/domain/launch_reachability_index.dart';

/// Maximum snap distance (meters) for water-entry validation at build time.
///
/// Stricter than [kReachabilitySnapMaxMeters]; see ROADMAP R3 snap quality
/// gate.
const kLaunchWaterEntrySnapMaxMeters = 200.0;

/// Catalog launches exempt from the 200 m water-entry snap gate until R3
/// water-entry coords land or geometry is tightened.
///
/// Documented in `apps/eddyscout/scripts/README-hydro.md` (Launch water-entry
/// snap validation). All three route within [kReachabilitySnapMaxMeters]
/// (900 m).
const Set<String> kLaunchWaterEntrySnapAllowlist = {
  'washougal_waterfront',
  'port_of_camas',
  'scappoose_bay_marina',
};

/// Snap result for a catalog launch against the unified hydro graph.
class LaunchWaterEntrySnapRow {
  /// Creates a water-entry snap row.
  const LaunchWaterEntrySnapRow({
    required this.launchId,
    required this.snapMeters,
    this.vertexIndex,
  });

  /// Catalog launch id.
  final String launchId;

  /// Haversine distance from routing coords to nearest graph geometry in
  /// meters.
  final double snapMeters;

  /// Graph vertex index when snapped to a node.
  final int? vertexIndex;
}

/// Computes catalog launch snaps to bundled hydro geometry at build time.
abstract final class LaunchWaterEntrySnapGenerator {
  /// Snaps each [catalog] launch routing coordinate to [graph].
  static List<LaunchWaterEntrySnapRow> generate({
    required RiverLineGraph graph,
    required List<LaunchPoint> catalog,
  }) {
    return [
      for (final launch in catalog) _snapLaunch(graph: graph, launch: launch),
    ];
  }

  /// Returns launch ids exceeding [maxSnapMeters], excluding [allowlist].
  ///
  /// When [waterEntryOnly] is true, only launches with explicit water-entry
  /// coordinates are validated (R3 strict gate before catalog migration).
  static List<LaunchWaterEntrySnapRow> violations({
    required RiverLineGraph graph,
    required List<LaunchPoint> catalog,
    Set<String> allowlist = const {},
    double maxSnapMeters = kLaunchWaterEntrySnapMaxMeters,
    bool waterEntryOnly = false,
  }) {
    final targets = waterEntryOnly
        ? catalog
              .where(
                (launch) =>
                    launch.waterEntryLatitude != null &&
                    launch.waterEntryLongitude != null,
              )
              .toList()
        : catalog;
    return generate(graph: graph, catalog: targets).where((row) {
      if (allowlist.contains(row.launchId)) {
        return false;
      }
      return row.snapMeters > maxSnapMeters;
    }).toList();
  }

  static LaunchWaterEntrySnapRow _snapLaunch({
    required RiverLineGraph graph,
    required LaunchPoint launch,
  }) {
    final snap = graph.snapToVertex(
      launch.routingLatitude,
      launch.routingLongitude,
    );
    if (snap == null) {
      return LaunchWaterEntrySnapRow(
        launchId: launch.id,
        snapMeters: double.infinity,
      );
    }
    return LaunchWaterEntrySnapRow(
      launchId: launch.id,
      snapMeters: snap.snapMeters,
      vertexIndex: snap.vertexIndex,
    );
  }
}
