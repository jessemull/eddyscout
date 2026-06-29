import 'package:eddyscout_design_system/eddyscout_design_system.dart';
import 'package:eddyscout_localization/eddyscout_localization.dart';
import 'package:flutter/material.dart';

/// Top banner while the user picks a custom stop location on the map.
class MapPlanningPickStopBanner extends StatelessWidget {
  /// Creates a banner with [onCancel] to return to edit-stops chrome.
  const MapPlanningPickStopBanner({
    required this.onCancel,
    super.key,
  });

  /// Returns to the edit-stops panel without adding a stop.
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      color: scheme.surface,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.md,
          vertical: Spacing.sm,
        ),
        child: Row(
          children: [
            Icon(Icons.touch_app_outlined, color: scheme.primary, size: 22),
            const SizedBox(width: Spacing.sm),
            Expanded(
              child: Text(
                l10n.mapRoutePickStopPrompt,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            TextButton(
              onPressed: onCancel,
              style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: Spacing.sm),
              ),
              child: Text(l10n.mapRouteNameStopCancel),
            ),
          ],
        ),
      ),
    );
  }
}
