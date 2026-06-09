import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_design_system/eddyscout_design_system.dart';
import 'package:eddyscout_localization/eddyscout_localization.dart';
import 'package:flutter/material.dart';

import 'map_stop_row.dart';

/// Expanded sheet for paddle route planning with stops list.
class MapRoutePlanningSheet extends StatelessWidget {
  const MapRoutePlanningSheet({
    required this.waypoints,
    required this.routeLengthKm,
    required this.canSave,
    required this.onClose,
    required this.onClear,
    required this.onSave,
    required this.onAddStopHint,
    super.key,
  });

  final List<LaunchPoint> waypoints;
  final double? routeLengthKm;
  final bool canSave;
  final VoidCallback onClose;
  final VoidCallback onClear;
  final VoidCallback onSave;
  final VoidCallback onAddStopHint;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final start = waypoints.isNotEmpty ? waypoints.first : null;
    final destination = waypoints.length >= 2 ? waypoints.last : null;
    final middleStops = waypoints.length > 2
        ? waypoints.sublist(1, waypoints.length - 1)
        : const <LaunchPoint>[];

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Spacing.md,
        Spacing.xs,
        Spacing.md,
        Spacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.mapRoutePlanningTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              IconButton(
                tooltip: l10n.mapCloseSheetLabel,
                onPressed: onClose,
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          MapStopRow(
            icon: Icons.trip_origin,
            label: l10n.mapRouteStopStart,
            value: start?.name,
            placeholder: l10n.mapRouteChooseDestination,
          ),
          for (var i = 0; i < middleStops.length; i++)
            MapStopRow(
              icon: Icons.radio_button_unchecked,
              label: l10n.mapRouteStopMiddle(i + 1),
              value: middleStops[i].name,
            ),
          MapStopRow(
            icon: Icons.location_on_outlined,
            label: l10n.mapRouteStopDestination,
            value: destination?.name,
            placeholder: l10n.mapRouteChooseDestination,
            onTap: onAddStopHint,
          ),
          TextButton.icon(
            onPressed: onAddStopHint,
            icon: const Icon(Icons.add),
            label: Text(l10n.mapRouteAddStop),
          ),
          if (routeLengthKm != null) ...[
            const SizedBox(height: Spacing.xs),
            Text(
              l10n.mapPlanningRouteLengthKm(routeLengthKm!.toStringAsFixed(1)),
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ],
          if (waypoints.length > 2) ...[
            const SizedBox(height: Spacing.xs),
            Text(
              l10n.mapPlanningWaypointCount(waypoints.length),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          const SizedBox(height: Spacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: onClear,
                child: Text(l10n.mapPlanningClearLabel),
              ),
              if (canSave) ...[
                const SizedBox(width: Spacing.sm),
                FilledButton(
                  onPressed: onSave,
                  child: Text(l10n.mapPlanningSaveLabel),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
