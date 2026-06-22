import 'package:eddyscout_design_system/eddyscout_design_system.dart';
import 'package:flutter/material.dart';

/// Trailing caret size for compact middle rows (matches route go/no-go).
const double kMapSheetMiddleRowCaretSize = 24;

/// Vertical gap between header, optional middle section, and actions.
const double kMapSheetSectionSpacing = Spacing.sm;

/// Shared shell for map place peek and route preview bottom bars.
class MapSheetBottomBarShell extends StatelessWidget {
  /// Creates the elevated sheet container.
  const MapSheetBottomBarShell({
    required this.header,
    required this.actions,
    this.middleSection,
    super.key,
  });

  /// Header row (title, subtitle, sheet icon buttons).
  final Widget header;

  /// Optional compact row between header and actions (go/no-go, suggested trips).
  final Widget? middleSection;

  /// Primary action buttons.
  final Widget actions;

  static const EdgeInsets _padding = EdgeInsets.fromLTRB(
    Spacing.md,
    Spacing.xs,
    Spacing.md,
    Spacing.sm,
  );

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      elevation: 8,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      color: scheme.surfaceContainerLow,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: _padding,
          child: MapSheetBottomBarSections(
            header: header,
            middleSection: middleSection,
            actions: actions,
          ),
        ),
      ),
    );
  }
}

/// Drag handle, header, optional middle section, and actions with shared
/// spacing.
class MapSheetBottomBarSections extends StatelessWidget {
  /// Creates the section column used by map bottom sheets.
  const MapSheetBottomBarSections({
    required this.header,
    required this.actions,
    this.middleSection,
    super.key,
  });

  final Widget header;
  final Widget? middleSection;
  final Widget actions;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        const SizedBox(height: kMapSheetSectionSpacing),
        header,
        if (middleSection != null) ...[
          const SizedBox(height: kMapSheetSectionSpacing),
          middleSection!,
        ],
        const SizedBox(height: kMapSheetSectionSpacing),
        actions,
      ],
    );
  }
}

/// Title and subtitle block with line heights aligned to route go/no-go rows.
class MapSheetHeaderTextBlock extends StatelessWidget {
  /// Creates a compact header text column.
  const MapSheetHeaderTextBlock({
    required this.title,
    this.subtitle,
    this.leftInset = 0,
    this.rightInset = 0,
    super.key,
  });

  final String title;
  final String? subtitle;
  final double leftInset;
  final double rightInset;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.only(left: leftInset, right: rightInset),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              height: 1.15,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (subtitle case final line?)
            Text(
              line,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
                height: 1.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
    );
  }
}

/// Collapsed middle-row tile matching route go/no-go [ExpansionTile] metrics.
class MapSheetCompactMiddleRow extends StatelessWidget {
  /// Creates a tappable middle row with go/no-go tile metrics.
  const MapSheetCompactMiddleRow({
    required this.semanticsLabel,
    required this.onTap,
    required this.content,
    super.key,
  });

  final String semanticsLabel;
  final VoidCallback onTap;
  final Widget content;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticsLabel,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: Spacing.sm),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            key: const Key('map_sheet_middle_section'),
            onTap: onTap,
            child: content,
          ),
        ),
      ),
    );
  }
}
