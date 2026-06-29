import 'package:dio/dio.dart';
import 'package:eddyscout_conditions/src/domain/conditions_models.dart';
import 'package:eddyscout_conditions/src/domain/conditions_repository_provider.dart';
import 'package:eddyscout_conditions/src/domain/go_no_go.dart';
import 'package:eddyscout_conditions/src/domain/repositories/conditions_repository.dart';
import 'package:eddyscout_conditions/src/domain/route_go_no_go.dart';
import 'package:eddyscout_conditions/src/presentation/conditions_debug_log.dart';
import 'package:eddyscout_conditions/src/presentation/conditions_snapshot_provider.dart';
import 'package:eddyscout_conditions/src/presentation/go_no_go_profile_provider.dart';
import 'package:eddyscout_conditions/src/presentation/provider_result.dart';
import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'route_go_no_go_rollup_provider.g.dart';

/// Loads conditions for one launch during route rollup.
///
/// Reuses a completed [conditionsSnapshotProvider] cache when present;
/// otherwise loads via [ConditionsRepository] with a per-launch cancel token
/// so one waypoint fetch cannot cancel another.
Future<ConditionsSnapshot> _conditionsSnapshotForRouteRollup(
  Ref ref,
  ConditionsRepository repository,
  LaunchPoint launch,
) async {
  final snapshotProvider = conditionsSnapshotProvider(launch);
  if (ref.exists(snapshotProvider)) {
    final cached = ref.read(snapshotProvider);
    if (cached case AsyncData(:final value)) {
      conditionsDebugLog(
        'rollup CACHE HIT launch=${launch.id} '
        'river=${value.riverFlow?.cfs ?? 'null'}',
      );
      return value;
    }
    conditionsDebugLog(
      'rollup CACHE SKIP launch=${launch.id} state=${cached.runtimeType}',
    );
  } else {
    conditionsDebugLog('rollup CACHE MISS launch=${launch.id}');
  }

  final cancelToken = CancelToken();
  try {
    return unwrapResultForAsyncProvider(
      await repository.load(launch, cancelToken: cancelToken),
    );
  } finally {
    if (!cancelToken.isCancelled) {
      cancelToken.cancel('routeGoNoGoRollup launch load complete');
    }
  }
}

/// Evaluates and rolls up go/no-go across ordered route waypoint launch ids.
@Riverpod(retry: disableProviderRetry)
Future<RouteGoNoGoResult> routeGoNoGoRollup(
  Ref ref,
  RouteGoNoGoWaypointsKey waypointsKey,
) async {
  final launchIdsInOrder = waypointsKey.launchIdsInOrder;
  conditionsDebugLog(
    'rollup START waypoints=${launchIdsInOrder.join(' → ')}',
  );
  if (launchIdsInOrder.length < 2) {
    throw const UnexpectedFailure(
      message: 'Route go/no-go requires at least two waypoints.',
    );
  }

  final profile = await ref.watch(goNoGoProfileProvider.future);
  final repository = ref.read(conditionsRepositoryProvider);

  final evaluated = <RouteWaypointGoNoGoResult>[];
  final failures = <RouteWaypointGoNoGoFailure>[];

  // Sequential fetch via repository avoids autoDispose cancel races on
  // [conditionsSnapshotProvider] when read from this async provider.
  for (final entry in launchIdsInOrder.asMap().entries) {
    final orderIndex = entry.key;
    final launchId = entry.value;
    final launch = findLaunchPointById(launchId);
    if (launch == null) {
      failures.add(
        RouteWaypointGoNoGoFailure(
          orderIndex: orderIndex,
          launchId: launchId,
          launchName: launchId,
          failure: NotFoundFailure(message: launchId),
        ),
      );
      continue;
    }

    try {
      final snapshot = await _conditionsSnapshotForRouteRollup(
        ref,
        repository,
        launch,
      );
      final result = GoNoGoEvaluator.evaluate(
        launch,
        snapshot,
        profile: profile,
      );
      conditionsDebugLogGoNoGo('rollup', launch, result);
      evaluated.add(
        RouteWaypointGoNoGoResult(
          orderIndex: orderIndex,
          launchId: launchId,
          launchName: launch.name,
          result: result,
        ),
      );
    } on AppFailure catch (failure) {
      conditionsDebugLog(
        'rollup FAIL launch=${launch.id} failure=${failure.message}',
      );
      failures.add(
        RouteWaypointGoNoGoFailure(
          orderIndex: orderIndex,
          launchId: launchId,
          launchName: launch.name,
          failure: failure,
        ),
      );
    }
  }

  return RouteGoNoGoRollup.rollUp(
    evaluated: evaluated,
    failures: failures,
    computedAt: DateTime.now(),
  );
}
