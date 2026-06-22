import 'package:eddyscout_conditions/eddyscout_conditions.dart';
import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_saved_routes/eddyscout_saved_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Builds route go/no-go rollup for a saved route when it has enough stops.
class SavedRouteGoNoGoSection extends ConsumerWidget {
  /// Creates a section for [routeId].
  const SavedRouteGoNoGoSection({required this.routeId, super.key});

  /// Saved route id.
  final String routeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final route = switch (ref.watch(savedRouteByIdProvider(routeId))) {
      AsyncData(:final value) => value,
      _ => null,
    };
    if (route == null || route.waypoints.length < 2) {
      return const SizedBox.shrink();
    }

    final launchIds = List<RouteWaypoint>.of(route.waypoints)
      ..sort((a, b) => a.order.compareTo(b.order));

    return RouteGoNoGoSummarySection(
      launchIdsInOrder: launchIds.map((w) => w.launchId).toList(),
    );
  }
}

/// Builds route go/no-go rollup for map planning preview waypoints.
class MapRouteGoNoGoSection extends ConsumerWidget {
  /// Creates a section for [launchIdsInOrder].
  const MapRouteGoNoGoSection({
    required this.launchIdsInOrder,
    super.key,
  });

  /// Ordered launch ids along the planned route.
  final List<String> launchIdsInOrder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (launchIdsInOrder.length < 2) {
      return const SizedBox.shrink();
    }

    return RouteGoNoGoSummarySection(launchIdsInOrder: launchIdsInOrder);
  }
}
