import 'package:eddyscout_design_system/eddyscout_design_system.dart';
import 'package:eddyscout_localization/eddyscout_localization.dart';
import 'package:flutter/material.dart';

/// Bottom preview bar after Done — trip time, summary placeholder, actions.
class MapRoutePreviewBar extends StatelessWidget {
  const MapRoutePreviewBar({
    required this.tripTimeLabel,
    required this.routeLengthKm,
    required this.canSave,
    required this.onStart,
    required this.onSave,
    required this.onAddStops,
    super.key,
  });

  final String? tripTimeLabel;
  final double? routeLengthKm;
  final bool canSave;
  final VoidCallback onStart;
  final VoidCallback onSave;
  final VoidCallback onAddStops;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    return Material(
      elevation: 8,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      color: scheme.surfaceContainerLow,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            Spacing.md,
            Spacing.sm,
            Spacing.md,
            Spacing.sm,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(Spacing.sm),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  l10n.mapRouteSummaryComingSoon,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(height: Spacing.sm),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (tripTimeLabel != null)
                          Text(
                            tripTimeLabel!,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        if (routeLengthKm != null)
                          Text(
                            l10n.mapPlanningRouteLengthKm(
                              routeLengthKm!.toStringAsFixed(1),
                            ),
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: scheme.onSurfaceVariant),
                          ),
                      ],
                    ),
                  ),
                  OutlinedButton(
                    onPressed: onStart,
                    child: Text(l10n.mapRoutePreviewStart),
                  ),
                  const SizedBox(width: Spacing.xs),
                  if (canSave)
                    FilledButton(
                      onPressed: onSave,
                      child: Text(l10n.mapPlanningSaveLabel),
                    ),
                ],
              ),
              const SizedBox(height: Spacing.xs),
              Align(
                child: TextButton(
                  onPressed: onAddStops,
                  child: Text(l10n.mapRoutePreviewAddStops),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
