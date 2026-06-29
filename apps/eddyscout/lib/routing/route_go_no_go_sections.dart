import 'package:eddyscout_conditions/eddyscout_conditions.dart';
import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_saved_routes/eddyscout_saved_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Catalog and snap stop metadata for route go/no-go timeline display.
typedef RouteGoNoGoStopMetadata = ({
  List<String> catalogLaunchIds,
  List<int> catalogStopOrderIndices,
  List<RouteGoNoGoSnapStop> snapStops,
});

/// Total route stops (catalog launches + custom snap stops).
int routeGoNoGoTotalStopCount(RouteGoNoGoStopMetadata metadata) =>
    metadata.catalogLaunchIds.length + metadata.snapStops.length;

/// Builds stop metadata from ordered [RouteWaypoint]s.
RouteGoNoGoStopMetadata routeGoNoGoStopMetadataFromWaypoints(
  List<RouteWaypoint> waypoints,
) {
  final sorted = List<RouteWaypoint>.of(waypoints)
    ..sort((a, b) => a.order.compareTo(b.order));

  final catalogLaunchIds = <String>[];
  final catalogStopOrderIndices = <int>[];
  final snapStops = <RouteGoNoGoSnapStop>[];

  for (final waypoint in sorted) {
    switch (waypoint) {
      case CatalogRouteWaypoint(:final launchId, :final order):
        catalogLaunchIds.add(launchId);
        catalogStopOrderIndices.add(order);
      case SnapRouteWaypoint(
        :final order,
        :final label,
        :final latitude,
        :final longitude,
      ):
        snapStops.add(
          RouteGoNoGoSnapStop(
            orderIndex: order,
            label:
                label ??
                '${latitude.toStringAsFixed(4)}, '
                    '${longitude.toStringAsFixed(4)}',
          ),
        );
    }
  }

  return (
    catalogLaunchIds: catalogLaunchIds,
    catalogStopOrderIndices: catalogStopOrderIndices,
    snapStops: snapStops,
  );
}

/// Builds stop metadata from ordered [RoutePlanningStop]s.
RouteGoNoGoStopMetadata routeGoNoGoStopMetadataFromPlanningStops(
  List<RoutePlanningStop> stops,
) {
  final catalogLaunchIds = <String>[];
  final catalogStopOrderIndices = <int>[];
  final snapStops = <RouteGoNoGoSnapStop>[];

  for (var i = 0; i < stops.length; i++) {
    final stop = stops[i];
    switch (stop) {
      case CatalogRoutePlanningStop(:final launch):
        catalogLaunchIds.add(launch.id);
        catalogStopOrderIndices.add(i);
      case SnapRoutePlanningStop(:final label):
        snapStops.add(
          RouteGoNoGoSnapStop(orderIndex: i, label: label),
        );
    }
  }

  return (
    catalogLaunchIds: catalogLaunchIds,
    catalogStopOrderIndices: catalogStopOrderIndices,
    snapStops: snapStops,
  );
}

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

    final metadata = routeGoNoGoStopMetadataFromWaypoints(route.waypoints);
    if (routeGoNoGoTotalStopCount(metadata) < 2) {
      return const SizedBox.shrink();
    }

    return RouteGoNoGoSummarySection(
      launchIdsInOrder: metadata.catalogLaunchIds,
      catalogStopOrderIndices: metadata.catalogStopOrderIndices,
      snapStops: metadata.snapStops,
    );
  }
}

/// Builds route go/no-go rollup for map planning preview waypoints.
class MapRouteGoNoGoSection extends ConsumerWidget {
  /// Creates a section for planned route stops.
  const MapRouteGoNoGoSection({
    required this.catalogLaunchIds,
    required this.catalogStopOrderIndices,
    required this.snapStops,
    super.key,
  });

  /// Ordered catalog launch ids for conditions rollup.
  final List<String> catalogLaunchIds;

  /// Full-route order index for each catalog launch.
  final List<int> catalogStopOrderIndices;

  /// Custom snap stops shown in the timeline without conditions data.
  final List<RouteGoNoGoSnapStop> snapStops;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (catalogLaunchIds.length + snapStops.length < 2) {
      return const SizedBox.shrink();
    }

    return RouteGoNoGoSummarySection(
      launchIdsInOrder: catalogLaunchIds,
      catalogStopOrderIndices: catalogStopOrderIndices,
      snapStops: snapStops,
    );
  }
}
