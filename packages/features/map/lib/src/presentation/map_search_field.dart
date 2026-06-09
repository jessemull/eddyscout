import 'package:eddyscout_design_system/eddyscout_design_system.dart';
import 'package:eddyscout_localization/eddyscout_localization.dart';
import 'package:flutter/material.dart';

/// Compact floating search pill at the top of the map.
class MapSearchField extends StatelessWidget {
  const MapSearchField({
    required this.onTap,
    super.key,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          Spacing.md,
          Spacing.sm,
          Spacing.md,
          0,
        ),
        child: Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(28),
          color: scheme.surfaceContainerHigh.withValues(alpha: 0.94),
          child: InkWell(
            borderRadius: BorderRadius.circular(28),
            onTap: onTap,
            child: Semantics(
              button: true,
              label: l10n.mapSearchPlaceholder,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.md,
                  vertical: Spacing.sm + 2,
                ),
                child: Row(
                  children: [
                    Icon(Icons.search, color: scheme.onSurfaceVariant),
                    const SizedBox(width: Spacing.sm),
                    Expanded(
                      child: Text(
                        l10n.mapSearchPlaceholder,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
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
