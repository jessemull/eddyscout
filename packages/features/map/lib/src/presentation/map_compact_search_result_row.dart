import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_design_system/eddyscout_design_system.dart';
import 'package:flutter/material.dart';

/// Layout metrics aligned with route go/no-go header rows.
const kMapCompactListLeadingIconSize = 30.0;
const kMapCompactListLeadingColumnWidth = 18.0;
const kMapCompactListLeadingTextGap = 18.0;

/// Accent color for launch icons in map search result lists.
Color mapSearchLaunchIconColor(BuildContext context, RiverSystem river) {
  final scheme = Theme.of(context).colorScheme;
  final semantic = SemanticColors.of(context);
  return switch (river) {
    RiverSystem.willamette => scheme.primary,
    RiverSystem.columbia => scheme.secondary,
    RiverSystem.clackamas => scheme.tertiary,
    RiverSystem.slough => semantic.info,
  };
}

/// Accent color for geocoded place icons in map search result lists.
Color mapSearchPlaceIconColor(BuildContext context) {
  return Theme.of(context).colorScheme.secondary;
}

/// Section label above compact search result lists (e.g. "Launches").
class MapSearchSectionHeader extends StatelessWidget {
  /// Creates a primary-colored section header.
  const MapSearchSectionHeader({required this.title, super.key});

  final String title;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(
      Spacing.md,
      Spacing.sm,
      Spacing.md,
      Spacing.xs,
    ),
    child: Text(
      title,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
        color: Theme.of(context).colorScheme.primary,
      ),
    ),
  );
}

/// Dense two-line search result row matching route go/no-go tile metrics.
class MapCompactSearchResultRow extends StatelessWidget {
  /// Creates a tappable search result row.
  const MapCompactSearchResultRow({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    this.onTap,
    this.semanticsLabel,
    super.key,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final VoidCallback? onTap;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final titleStyle = Theme.of(context).textTheme.titleSmall!.copyWith(
      color: scheme.onSurface,
      fontWeight: FontWeight.w600,
      height: 1.15,
    );
    final subtitleStyle = Theme.of(context).textTheme.bodySmall!.copyWith(
      color: scheme.onSurfaceVariant,
      height: 1.2,
    );

    final content = Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.md,
        vertical: Spacing.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: kMapCompactListLeadingColumnWidth,
            child: Icon(
              icon,
              size: kMapCompactListLeadingIconSize,
              color: iconColor,
            ),
          ),
          const SizedBox(width: kMapCompactListLeadingTextGap),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: titleStyle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  subtitle,
                  style: subtitleStyle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (onTap == null) {
      return Semantics(
        label: semanticsLabel ?? '$title. $subtitle',
        child: content,
      );
    }

    return Semantics(
      button: true,
      label: semanticsLabel ?? '$title. $subtitle',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: content,
        ),
      ),
    );
  }
}
