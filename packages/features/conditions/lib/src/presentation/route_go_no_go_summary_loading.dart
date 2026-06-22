part of 'route_go_no_go_summary_section.dart';

const double _routeGoNoGoLoadingPlaceholderHeight = 14;
const double _routeGoNoGoLoadingVerticalInset = Spacing.xs;

/// Placeholder matching loaded verdict header height to avoid layout jump.
class _RouteGoNoGoLoadingStrip extends StatelessWidget {
  const _RouteGoNoGoLoadingStrip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final placeholderColor = Theme.of(
      context,
    ).colorScheme.surfaceContainerHighest;

    return Semantics(
      label: label,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: _routeGoNoGoLoadingVerticalInset,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _RouteGoNoGoLoadingPlaceholderLine(color: placeholderColor),
            const SizedBox(height: _routeGoNoGoSubheaderDetailGap),
            _RouteGoNoGoLoadingPlaceholderLine(color: placeholderColor),
          ],
        ),
      ),
    );
  }
}

class _RouteGoNoGoLoadingPlaceholderLine extends StatelessWidget {
  const _RouteGoNoGoLoadingPlaceholderLine({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _routeGoNoGoLoadingPlaceholderHeight,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
