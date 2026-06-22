part of 'route_go_no_go_summary_section.dart';

/// Shared header and stop-row layout for every route go/no-go verdict.
class _RouteGoNoGoVerdictPanel extends StatelessWidget {
  const _RouteGoNoGoVerdictPanel({
    required this.size,
    required this.accent,
    required this.icon,
    required this.primaryLabel,
    this.secondaryLabel,
    this.detailText,
    this.trailing,
  });

  final _RouteGoNoGoBlockSize size;
  final Color accent;
  final IconData icon;
  final String primaryLabel;
  final String? secondaryLabel;
  final String? detailText;
  final Widget? trailing;

  TextStyle _primaryStyle(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return switch (size) {
      _RouteGoNoGoBlockSize.header =>
        Theme.of(
          context,
        ).textTheme.titleSmall!.copyWith(
          color: scheme.onSurface,
          fontWeight: FontWeight.w600,
          height: 1.15,
        ),
      _RouteGoNoGoBlockSize.stopRow => Theme.of(context).textTheme.bodyMedium!,
    };
  }

  TextStyle _detailStyle(BuildContext context) =>
      Theme.of(context).textTheme.bodySmall!.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        height: 1.2,
      );

  double get _iconSize => switch (size) {
    _RouteGoNoGoBlockSize.header => _routeGoNoGoHeaderVerdictIconSize,
    _RouteGoNoGoBlockSize.stopRow => _routeGoNoGoRowVerdictIconSize,
  };

  double get _iconTopInset => switch (size) {
    _RouteGoNoGoBlockSize.header => _routeGoNoGoHeaderIconTopInset,
    _RouteGoNoGoBlockSize.stopRow => _routeGoNoGoRowIconTopInset,
  };

  @override
  Widget build(BuildContext context) {
    final detailStyle = _detailStyle(context);
    final primary = size == _RouteGoNoGoBlockSize.stopRow
        ? Transform.translate(
            offset: const Offset(0, -2),
            child: Text(
              primaryLabel,
              style: _primaryStyle(context),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          )
        : Text(
            primaryLabel,
            style: _primaryStyle(context),
          );

    if (size == _RouteGoNoGoBlockSize.header) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _RouteGoNoGoVerdictLeadingIcon(
            accent: accent,
            icon: icon,
            size: _iconSize,
            topInset: _iconTopInset,
          ),
          const SizedBox(width: _routeGoNoGoHeaderIconTextGap),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      primary,
                      if (secondaryLabel != null)
                        Text(
                          secondaryLabel!,
                          style: detailStyle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      if (secondaryLabel != null && detailText != null)
                        const SizedBox(height: _routeGoNoGoSubheaderDetailGap),
                      if (detailText case final detail?)
                        Text(
                          detail,
                          style: detailStyle,
                        ),
                    ],
                  ),
                ),
                ?trailing,
              ],
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        primary,
        if (detailText != null) ...[
          const SizedBox(height: Spacing.xxs),
          _RouteGoNoGoVerdictDetailRow(
            accent: accent,
            icon: icon,
            iconSize: _iconSize,
            iconTopInset: _iconTopInset,
            detailText: detailText!,
            style: detailStyle,
          ),
        ],
      ],
    );
  }
}

class _RouteGoNoGoVerdictLeadingIcon extends StatelessWidget {
  const _RouteGoNoGoVerdictLeadingIcon({
    required this.accent,
    required this.icon,
    required this.size,
    required this.topInset,
  });

  final Color accent;
  final IconData icon;
  final double size;
  final double topInset;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _routeGoNoGoHeaderIconColumnWidth,
      child: Padding(
        padding: EdgeInsets.only(top: topInset),
        child: Icon(
          icon,
          color: accent,
          size: size,
        ),
      ),
    );
  }
}

class _RouteGoNoGoVerdictDetailRow extends StatelessWidget {
  const _RouteGoNoGoVerdictDetailRow({
    required this.accent,
    required this.icon,
    required this.iconSize,
    required this.iconTopInset,
    required this.detailText,
    required this.style,
  });

  final Color accent;
  final IconData icon;
  final double iconSize;
  final double iconTopInset;
  final String detailText;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: iconTopInset),
          child: Icon(
            icon,
            color: accent,
            size: iconSize,
          ),
        ),
        const SizedBox(width: Spacing.xxs),
        Expanded(
          child: Text(
            detailText,
            style: style,
          ),
        ),
      ],
    );
  }
}
