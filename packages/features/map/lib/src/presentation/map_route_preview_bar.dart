import 'package:eddyscout_design_system/eddyscout_design_system.dart';
import 'package:eddyscout_localization/eddyscout_localization.dart';
import 'package:eddyscout_persistence/eddyscout_persistence.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'map_sheet_header_icon_button.dart';

/// Bottom preview bar after Done — trip time and actions.
class MapRoutePreviewBar extends ConsumerWidget {
  const MapRoutePreviewBar({
    required this.tripTimeLabel,
    required this.routeLengthKm,
    required this.canSave,
    required this.onBack,
    required this.onDismiss,
    required this.onStart,
    required this.onSave,
    super.key,
  });

  final String? tripTimeLabel;
  final double? routeLengthKm;
  final bool canSave;
  final VoidCallback onBack;
  final VoidCallback onDismiss;
  final VoidCallback onStart;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final backTooltip = MaterialLocalizations.of(context).backButtonTooltip;
    final displayUnits = ref.watch(effectiveDisplayUnitSystemProvider);
    final routeLengthLabel = routeLengthKm == null
        ? null
        : l10n.mapPlanningRouteLength(
            localizedDistanceFromKm(l10n, routeLengthKm, displayUnits)!,
          );

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
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      left: MapSheetHeaderIconButton.compactSlotWidth,
                      right: MapSheetHeaderIconButton.closeSlotWidth,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (tripTimeLabel != null)
                          Text(
                            tripTimeLabel!,
                            style: Theme.of(context).textTheme.titleSmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        if (routeLengthLabel != null)
                          Text(
                            routeLengthLabel,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: scheme.onSurfaceVariant),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 0,
                    bottom: 0,
                    left: 0,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: MapSheetHeaderIconButton(
                        icon: Icons.arrow_back,
                        tooltip: backTooltip,
                        alignment: Alignment.centerLeft,
                        onPressed: onBack,
                        compact: true,
                        contentSized: true,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: MapSheetHeaderIconButton(
                      icon: Icons.close,
                      tooltip: l10n.mapCloseSheetLabel,
                      alignment: Alignment.topRight,
                      onPressed: onDismiss,
                      contentSized: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Spacing.sm),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onStart,
                      child: Text(l10n.mapRoutePreviewStart),
                    ),
                  ),
                  const SizedBox(width: Spacing.sm),
                  Expanded(
                    child: FilledButton(
                      onPressed: canSave ? onSave : null,
                      child: Text(l10n.mapPlanningSaveLabel),
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
