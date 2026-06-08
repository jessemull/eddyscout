import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_design_system/eddyscout_design_system.dart';
import 'package:eddyscout_localization/eddyscout_localization.dart';
import 'package:eddyscout_saved_routes/src/presentation/providers/saved_routes_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Reorderable waypoint list for route detail.
class SavedRouteDetailWaypointsSection extends ConsumerWidget {
  /// Creates the waypoints section.
  const SavedRouteDetailWaypointsSection({
    required this.waypoints,
    required this.onReorder,
    required this.onDeleteWaypoint,
    super.key,
  });

  /// Waypoints in display order.
  final List<RouteWaypoint> waypoints;

  /// Called when the user reorders waypoints.
  final void Function(int oldIndex, int newIndex) onReorder;

  /// Called when the user deletes a waypoint at the given index.
  final ValueChanged<int> onDeleteWaypoint;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.savedRoutesWaypointsTitle,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: Spacing.sm),
        ReorderableListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: waypoints.length,
          // ignore: deprecated_member_use — onReorderItem not in stable API yet
          onReorder: onReorder,
          itemBuilder: (context, index) {
            final wp = waypoints[index];
            final launch = ref.read(launchPointLookupProvider)(wp.launchId);
            final label = launch?.name ?? l10n.savedRoutesUnknownLaunch;
            return Semantics(
              key: ValueKey('${wp.launchId}_$index'),
              label: l10n.savedRoutesWaypointSemantics(index + 1, label),
              hint: l10n.savedRoutesReorderWaypointHint,
              child: ListTile(
                title: Text('${index + 1}. $label'),
                trailing: Semantics(
                  button: true,
                  enabled: waypoints.length > 2,
                  label: l10n.savedRoutesDeleteWaypointSemantics(index + 1),
                  child: IconButton(
                    tooltip: l10n.savedRoutesDeleteWaypointSemantics(
                      index + 1,
                    ),
                    icon: const Icon(Icons.delete_outline),
                    onPressed: waypoints.length <= 2
                        ? null
                        : () => onDeleteWaypoint(index),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
