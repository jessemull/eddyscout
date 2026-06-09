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

/// Peek-height sheet summarizing a selected launch.
class MapPlaceBottomSheet extends StatelessWidget {
  const MapPlaceBottomSheet({
    required this.launch,
    required this.onPlanPaddle,
    required this.onViewConditions,
    super.key,
  });

  final LaunchPoint launch;
  final VoidCallback onPlanPaddle;
  final VoidCallback onViewConditions;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final river = mapLaunchRiverLabel(l10n, launch.riverSystem);
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
          Text(
            launch.name,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: Spacing.xs),
          Text(
            '$river${l10n.commonDotSeparator}${launch.windExposure.label}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: Spacing.sm),
          Text(
            launch.shortNote,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: Spacing.md),
          FilledButton(
            onPressed: onPlanPaddle,
            child: Text(l10n.mapPlanPaddleButton),
          ),
          const SizedBox(height: Spacing.sm),
          OutlinedButton(
            onPressed: onViewConditions,
            child: Text(l10n.mapViewConditionsButton),
          ),
        ],
      ),
    );
  }
}
