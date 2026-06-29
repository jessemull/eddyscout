import 'package:eddyscout_conditions/src/domain/go_no_go.dart';
import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:flutter/foundation.dart';
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
@freezed
abstract class RouteWaypointGoNoGoFailure with _$RouteWaypointGoNoGoFailure {
  /// Creates a failure record for one waypoint.
  const factory RouteWaypointGoNoGoFailure({
    required int orderIndex,
    required String launchId,
    required String launchName,
    required AppFailure failure,
  }) = _RouteWaypointGoNoGoFailure;
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

/// Custom snap stop shown in route go/no-go timeline (no conditions API).
@immutable
final class RouteGoNoGoSnapStop {
  /// Creates metadata for one snap stop row in the go/no-go timeline.
  const RouteGoNoGoSnapStop({
    required this.orderIndex,
    required this.label,
  });

  /// Zero-based position along the full route stop list.
  final int orderIndex;

  /// User-facing stop label.
  final String label;
}

/// Stable cache key: ordered launch ids for a planned route (value equality).
@immutable
final class RouteGoNoGoWaypointsKey {
  /// Creates a key from an unmodifiable ordered launch id list.
  const RouteGoNoGoWaypointsKey(this.launchIdsInOrder);

  /// Builds a key from ordered launch ids.
  factory RouteGoNoGoWaypointsKey.fromOrdered(List<String> launchIdsInOrder) {
    return RouteGoNoGoWaypointsKey(List<String>.unmodifiable(launchIdsInOrder));
  }

  /// Ordered catalog launch ids along the route.
  final List<String> launchIdsInOrder;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! RouteGoNoGoWaypointsKey ||
        launchIdsInOrder.length != other.launchIdsInOrder.length) {
      return false;
    }
    for (var i = 0; i < launchIdsInOrder.length; i++) {
      if (launchIdsInOrder[i] != other.launchIdsInOrder[i]) {
        return false;
      }
    }
    return true;
  }

  @override
  int get hashCode => Object.hashAll(launchIdsInOrder);
}

/// Pure rollup of per-waypoint [GoNoGoResult] values.
class RouteGoNoGoRollup {
  RouteGoNoGoRollup._();

  /// Filters info-only reasons except [GoNoGoReasonCode.weatherMissing] so
  /// insufficient-data rollups still explain missing forecast in the UI.
  static List<GoNoGoReason> _triggeringReasonsFor(
    RouteWaypointGoNoGoResult stop,
  ) {
    return stop.result.reasons
        .where(
          (reason) =>
              reason.severity != GoNoGoReasonSeverity.info ||
              reason.code == GoNoGoReasonCode.weatherMissing,
        )
        .toList();
  }

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
        : _triggeringReasonsFor(triggering);

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
