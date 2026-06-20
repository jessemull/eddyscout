import 'package:eddyscout_conditions/src/domain/go_no_go.dart';
import 'package:eddyscout_conditions/src/domain/route_go_no_go.dart';
import 'package:eddyscout_conditions/src/presentation/conditions_snapshot_provider.dart';
import 'package:eddyscout_conditions/src/presentation/go_no_go_profile_provider.dart';
import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'route_go_no_go_rollup_provider.g.dart';

/// Evaluates and rolls up go/no-go across ordered route waypoint launch ids.
@Riverpod(retry: disableProviderRetry)
Future<RouteGoNoGoResult> routeGoNoGoRollup(
  Ref ref,
  RouteGoNoGoWaypointsKey launchIdsInOrder,
) async {
  if (launchIdsInOrder.length < 2) {
    throw const UnexpectedFailure(
      message: 'Route go/no-go requires at least two waypoints.',
    );
  }

  final profile = await ref.watch(goNoGoProfileProvider.future);
  final evaluated = <RouteWaypointGoNoGoResult>[];
  final failures = <RouteWaypointGoNoGoFailure>[];

  await Future.wait(
    launchIdsInOrder.asMap().entries.map((entry) async {
      final orderIndex = entry.key;
      final launchId = entry.value;
      final launch = findLaunchPointById(launchId);
      if (launch == null) {
        return;
      }

      try {
        final snapshot = await ref.read(
          conditionsSnapshotProvider(launch).future,
        );
        final result = GoNoGoEvaluator.evaluate(
          launch,
          snapshot,
          profile: profile,
        );
        evaluated.add(
          RouteWaypointGoNoGoResult(
            orderIndex: orderIndex,
            launchId: launchId,
            launchName: launch.name,
            result: result,
          ),
        );
      } on AppFailure catch (failure) {
        failures.add(
          RouteWaypointGoNoGoFailure(
            orderIndex: orderIndex,
            launchId: launchId,
            launchName: launch.name,
            failure: failure,
          ),
        );
      }
    }),
  );

  return RouteGoNoGoRollup.rollUp(
    evaluated: evaluated,
    failures: failures,
    computedAt: DateTime.now(),
  );
}
