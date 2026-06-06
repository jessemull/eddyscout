import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_design_system/eddyscout_design_system.dart';
import 'package:eddyscout_localization/eddyscout_localization.dart';
import 'package:flutter/material.dart';

/// Route-planning instructions and put-in / take-out summary over the map.
class MapPlanningOverlay extends StatelessWidget {
  const MapPlanningOverlay({
    required this.putIn,
    required this.takeOut,
    required this.routeLengthKm,
    required this.onClear,
    required this.onDone,
    super.key,
  });

  final LaunchPoint? putIn;
  final LaunchPoint? takeOut;
  final double? routeLengthKm;
  final VoidCallback onClear;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;
    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            Spacing.md - Spacing.xs,
            Spacing.sm,
            Spacing.md - Spacing.xs,
            0,
          ),
          child: Semantics(
            container: true,
            label: l10n.mapPlanningSemanticsLabel,
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(12),
              color: scheme.surfaceContainerHighest,
              child: Padding(
                padding: const EdgeInsets.all(Spacing.md - Spacing.xs),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.mapPlanningTitleBeta,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: Spacing.sm - 2),
                    Text(
                      l10n.mapPlanningInstructions,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    if (putIn != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        l10n.mapPlanningPutInName(putIn!.name),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                    if (takeOut != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        l10n.mapPlanningTakeOutName(takeOut!.name),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                    if (routeLengthKm != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        l10n.mapPlanningRouteLengthKm(
                          routeLengthKm!.toStringAsFixed(1),
                        ),
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      alignment: WrapAlignment.end,
                      children: [
                        TextButton(
                          onPressed: onClear,
                          child: Text(l10n.mapPlanningClearLabel),
                        ),
                        TextButton(
                          onPressed: onDone,
                          child: Text(l10n.mapPlanningDoneLabel),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
