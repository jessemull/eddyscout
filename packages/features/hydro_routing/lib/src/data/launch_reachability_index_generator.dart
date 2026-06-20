import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_hydro_routing/src/data/launch_reachability_index_codec.dart';
import 'package:eddyscout_hydro_routing/src/data/river_route_planner.dart';
import 'package:eddyscout_hydro_routing/src/domain/launch_reachability_index.dart';
import 'package:eddyscout_hydro_routing/src/domain/route_result.dart';

/// Builds a pre-computed reachability index from hydro graphs and the catalog.
abstract final class LaunchReachabilityIndexGenerator {
  /// Generates an index using graph routing between catalog launches.
  ///
  /// Cross-system pairs are excluded when [crossSystemReachability] is false.
  static LaunchReachabilityIndex generate({
    required RiverRoutePlanner planner,
    required List<LaunchPoint> catalog,
    DateTime? generatedAt,
    bool crossSystemReachability = false,
    void Function(String message)? onWarning,
  }) {
    final entries = <String, LaunchReachabilityEntry>{};

    for (final source in catalog) {
      final bandLists = <ReachabilityBand, List<({String id, double meters})>>{
        for (final band in ReachabilityBand.values) band: [],
      };

      for (final target in catalog) {
        if (source.id == target.id) {
          continue;
        }
        if (!crossSystemReachability &&
            source.riverSystem != target.riverSystem) {
          continue;
        }

        final result = planner.plan(source, target);
        if (result is! RouteSuccess) {
          continue;
        }

        final band = reachabilityBandForDistance(result.lengthMeters);
        if (band == null) {
          continue;
        }
        bandLists[band]!.add((id: target.id, meters: result.lengthMeters));
      }

      for (final band in ReachabilityBand.values) {
        final list = bandLists[band]!
          ..sort((a, b) {
            final byDist = a.meters.compareTo(b.meters);
            if (byDist != 0) {
              return byDist;
            }
            return a.id.compareTo(b.id);
          });
        bandLists[band] = list;
      }

      final hasAny = bandLists.values.any((list) => list.isNotEmpty);

      entries[source.id] = LaunchReachabilityEntry(
        within5Mi: bandLists[ReachabilityBand.within5Mi]!
            .map((e) => e.id)
            .toList(),
        within10Mi: bandLists[ReachabilityBand.within10Mi]!
            .map((e) => e.id)
            .toList(),
        within20Mi: bandLists[ReachabilityBand.within20Mi]!
            .map((e) => e.id)
            .toList(),
      );

      if (!hasAny && onWarning != null) {
        final sameSystemPeer = catalog.where(
          (launch) =>
              launch.id != source.id &&
              launch.riverSystem == source.riverSystem,
        );
        if (sameSystemPeer.isEmpty) {
          onWarning(
            'Launch ${source.id} has no routable peers on '
            '${source.riverSystem.name}',
          );
        }
      }
    }

    return LaunchReachabilityIndex(
      schemaVersion: 1,
      generatedAt: (generatedAt ?? DateTime.now()).toUtc(),
      distanceModel: 'graph_plus_snap',
      snapMaxMeters: kReachabilitySnapMaxMeters,
      thresholdsMi: kReachabilityThresholdsMi,
      crossSystemReachability: crossSystemReachability,
      entries: entries,
    );
  }

  /// Generates and encodes the index as JSON text.
  static String generateJson({
    required RiverRoutePlanner planner,
    required List<LaunchPoint> catalog,
    DateTime? generatedAt,
    bool crossSystemReachability = false,
    void Function(String message)? onWarning,
  }) {
    final index = generate(
      planner: planner,
      catalog: catalog,
      generatedAt: generatedAt,
      crossSystemReachability: crossSystemReachability,
      onWarning: onWarning,
    );
    return encodeLaunchReachabilityIndex(index);
  }
}
