import 'package:eddyscout_design_system/eddyscout_design_system.dart';
import 'package:eddyscout_localization/eddyscout_localization.dart';
import 'package:flutter/material.dart';

/// Bottom preview bar after Done — trip time and actions.
class MapRoutePreviewBar extends StatelessWidget {
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

  static const double _headerIconSize = 24;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final backTooltip = MaterialLocalizations.of(context).backButtonTooltip;
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _PreviewHeaderIconButton(
                    icon: Icons.arrow_back,
                    tooltip: backTooltip,
                    alignment: Alignment.topLeft,
                    onPressed: onBack,
                  ),
                  Expanded(
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
                        if (routeLengthKm != null)
                          Text(
                            l10n.mapPlanningRouteLengthKm(
                              routeLengthKm!.toStringAsFixed(1),
                            ),
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: scheme.onSurfaceVariant),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  _PreviewHeaderIconButton(
                    icon: Icons.close,
                    tooltip: l10n.mapCloseSheetLabel,
                    alignment: Alignment.topRight,
                    onPressed: onDismiss,
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

class _PreviewHeaderIconButton extends StatelessWidget {
  const _PreviewHeaderIconButton({
    required this.icon,
    required this.tooltip,
    required this.alignment,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final Alignment alignment;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: tooltip,
      child: Tooltip(
        message: tooltip,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minWidth: 48,
                minHeight: 48,
              ),
              child: Align(
                alignment: alignment,
                child: Icon(icon, size: MapRoutePreviewBar._headerIconSize),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
