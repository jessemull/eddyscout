import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_design_system/eddyscout_design_system.dart';
import 'package:eddyscout_localization/eddyscout_localization.dart';
import 'package:flutter/material.dart';

String mapLaunchRiverLabel(AppLocalizations l10n, RiverSystem river) {
  return switch (river) {
    RiverSystem.willamette => l10n.launchDetailRiverWillamette,
    RiverSystem.columbia => l10n.launchDetailRiverColumbia,
    RiverSystem.clackamas => l10n.launchDetailRiverClackamas,
    RiverSystem.slough => l10n.launchDetailRiverSlough,
  };
}

/// Compact bottom card for a selected launch (Plan paddle / View conditions).
class MapPlacePeekBar extends StatelessWidget {
  const MapPlacePeekBar({
    required this.launch,
    required this.onPlanPaddle,
    required this.onViewConditions,
    required this.onDismiss,
    super.key,
  });

  final LaunchPoint launch;
  final VoidCallback onPlanPaddle;
  final VoidCallback onViewConditions;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final river = mapLaunchRiverLabel(l10n, launch.riverSystem);
    return Material(
      elevation: 8,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      color: scheme.surfaceContainerLow,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            Spacing.md,
            Spacing.xs,
            Spacing.md,
            Spacing.sm,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: scheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: Spacing.sm),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          launch.name,
                          style: Theme.of(context).textTheme.titleSmall,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '$river${l10n.commonDotSeparator}'
                          '${launch.windExposure.label}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: scheme.onSurfaceVariant),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: l10n.mapCloseSheetLabel,
                    onPressed: onDismiss,
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: Spacing.sm),
              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: onPlanPaddle,
                      child: Text(l10n.mapPlanPaddleButton),
                    ),
                  ),
                  const SizedBox(width: Spacing.sm),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onViewConditions,
                      child: Text(l10n.mapViewConditionsButton),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
