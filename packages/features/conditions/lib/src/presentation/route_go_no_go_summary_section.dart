import 'package:eddyscout_conditions/src/domain/go_no_go.dart';
import 'package:eddyscout_conditions/src/domain/route_go_no_go.dart';
import 'package:eddyscout_conditions/src/presentation/go_no_go_l10n.dart';
import 'package:eddyscout_conditions/src/presentation/route_go_no_go_rollup_provider.dart';
import 'package:eddyscout_design_system/eddyscout_design_system.dart';
import 'package:eddyscout_localization/eddyscout_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'route_go_no_go_summary_shared.dart';
part 'route_go_no_go_summary_loading.dart';
part 'route_go_no_go_summary_verdict_panel.dart';
part 'route_go_no_go_summary_strip.dart';
part 'route_go_no_go_summary_stop_timeline.dart';

/// Route-level go/no-go rollup for map preview and saved route detail.
class RouteGoNoGoSummarySection extends ConsumerWidget {
  /// Creates a section that loads rollup for [launchIdsInOrder].
  const RouteGoNoGoSummarySection({
    required this.launchIdsInOrder,
    this.catalogStopOrderIndices = const [],
    this.snapStops = const [],
    super.key,
  });

  /// Ordered catalog launch ids along the route.
  final List<String> launchIdsInOrder;

  /// Full-route order index for each entry in [launchIdsInOrder].
  ///
  /// When empty, [RouteWaypointGoNoGoResult.orderIndex] from the rollup is
  /// used.
  final List<int> catalogStopOrderIndices;

  /// Custom snap stops interleaved in the timeline (no conditions data).
  final List<RouteGoNoGoSnapStop> snapStops;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (launchIdsInOrder.length + snapStops.length < 2) {
      return const SizedBox.shrink();
    }

    final l10n = context.l10n;

    if (launchIdsInOrder.isEmpty) {
      return _RouteGoNoGoSummaryStrip(
        result: RouteGoNoGoRollup.snapStopsOnly(computedAt: DateTime.now()),
        catalogStopOrderIndices: catalogStopOrderIndices,
        snapStops: snapStops,
      );
    }

    final waypointsKey = RouteGoNoGoWaypointsKey.fromOrdered(launchIdsInOrder);
    final rollupAsync = ref.watch(routeGoNoGoRollupProvider(waypointsKey));

    return rollupAsync.when(
      loading: () => _RouteGoNoGoLoadingStrip(
        label: l10n.routeGoNoGoLoading,
      ),
      error: (error, _) => _RouteGoNoGoErrorStrip(
        message: localizeRouteGoNoGoRollupErrorMessage(l10n, error),
        onRetry: () => ref.invalidate(routeGoNoGoRollupProvider(waypointsKey)),
      ),
      data: (result) => _RouteGoNoGoSummaryStrip(
        result: result,
        catalogStopOrderIndices: catalogStopOrderIndices,
        snapStops: snapStops,
      ),
    );
  }
}
