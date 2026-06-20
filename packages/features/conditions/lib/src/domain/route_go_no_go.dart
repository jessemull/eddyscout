import 'package:eddyscout_conditions/src/domain/go_no_go.dart';
import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'route_go_no_go.freezed.dart';

/// Per-stop evaluation outcome after conditions fetch and evaluator.
@freezed
abstract class RouteWaypointGoNoGoResult with _$RouteWaypointGoNoGoResult {
  /// Creates a per-waypoint go/no-go result.
  const factory RouteWaypointGoNoGoResult({
    required int orderIndex,
    required String launchId,
    required String launchName,
    required GoNoGoResult result,
  }) = _RouteWaypointGoNoGoResult;
}

/// Per-stop conditions fetch failure (route rollup continues with other stops).
class RouteWaypointGoNoGoFailure {
  /// Creates a failure record for one waypoint.
  const RouteWaypointGoNoGoFailure({
    required this.orderIndex,
    required this.launchId,
    required this.launchName,
    required this.failure,
  });

  /// Zero-based order along the route.
  final int orderIndex;

  /// Catalog launch id for the stop.
  final String launchId;

  /// Display name for the stop.
  final String launchName;

  /// Typed failure from conditions fetch.
  final AppFailure failure;
}

/// Rolled route verdict plus provenance for UI.
@freezed
abstract class RouteGoNoGoResult with _$RouteGoNoGoResult {
  /// Creates a rolled route go/no-go result.
  const factory RouteGoNoGoResult({
    required GoNoGoVerdict verdict,
    required DateTime computedAt,
    required List<RouteWaypointGoNoGoResult> waypointResults,
    required List<RouteWaypointGoNoGoFailure> waypointFailures,
    required List<GoNoGoReason> triggeringReasons,
    RouteWaypointGoNoGoResult? triggeringWaypoint,
  }) = _RouteGoNoGoResult;
}

/// Stable cache key: ordered launch ids for a planned route.
typedef RouteGoNoGoWaypointsKey = List<String>;

/// Pure rollup of per-waypoint [GoNoGoResult] values.
class RouteGoNoGoRollup {
  RouteGoNoGoRollup._();

  /// Rolls up waypoint results using worst-verdict-wins ordering.
  ///
  /// Throws [UnexpectedFailure] when [evaluated] is empty.
  static RouteGoNoGoResult rollUp({
    required List<RouteWaypointGoNoGoResult> evaluated,
    required List<RouteWaypointGoNoGoFailure> failures,
    required DateTime computedAt,
  }) {
    if (evaluated.isEmpty) {
      throw const UnexpectedFailure(
        message: 'No waypoint conditions available for route go/no-go.',
      );
    }

    final sorted = List<RouteWaypointGoNoGoResult>.of(evaluated)
      ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));

    var rolledVerdict = GoNoGoVerdict.go;
    for (final stop in sorted) {
      final rank = _verdictRank(stop.result.verdict);
      if (rank > _verdictRank(rolledVerdict)) {
        rolledVerdict = stop.result.verdict;
      }
    }

    RouteWaypointGoNoGoResult? triggering;
    if (rolledVerdict != GoNoGoVerdict.go) {
      final targetRank = _verdictRank(rolledVerdict);
      for (final stop in sorted) {
        if (_verdictRank(stop.result.verdict) == targetRank) {
          triggering = stop;
          break;
        }
      }
    }

    final triggeringReasons = triggering == null
        ? const <GoNoGoReason>[]
        : triggering.result.reasons
              .where((r) => r.severity != GoNoGoReasonSeverity.info)
              .toList();

    return RouteGoNoGoResult(
      verdict: rolledVerdict,
      computedAt: computedAt,
      waypointResults: sorted,
      waypointFailures: List<RouteWaypointGoNoGoFailure>.unmodifiable(failures),
      triggeringReasons: triggeringReasons,
      triggeringWaypoint: triggering,
    );
  }

  static int _verdictRank(GoNoGoVerdict verdict) => switch (verdict) {
    GoNoGoVerdict.noGo => 4,
    GoNoGoVerdict.marginal => 3,
    GoNoGoVerdict.insufficientData => 2,
    GoNoGoVerdict.go => 1,
  };
}
