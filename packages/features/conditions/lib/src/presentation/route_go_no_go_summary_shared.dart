part of 'route_go_no_go_summary_section.dart';

/// Shared with stop timeline rows so verdict icons align with route markers.
const _routeGoNoGoTimelineWidth = 18.0;

const _routeGoNoGoHeaderVerdictIconSize = 30.0;
const _routeGoNoGoRowVerdictIconSize = 14.0;
const _routeGoNoGoHeaderIconTopInset = 0.0;
const _routeGoNoGoRowIconTopInset = 1.0;
const _routeGoNoGoHeaderIconColumnWidth = 18.0;
const _routeGoNoGoExpansionCaretSize = 24.0;
const _routeGoNoGoHeaderIconTextGap = 18.0;
const double _routeGoNoGoSubheaderDetailGap = Spacing.xs + Spacing.xxs;

enum _RouteGoNoGoBlockSize { header, stopRow }

class _TimelineStop {
  const _TimelineStop({
    required this.orderIndex,
    required this.launchName,
    this.verdict,
    this.detailText,
    this.isFailure = false,
  });

  final int orderIndex;
  final String launchName;
  final GoNoGoVerdict? verdict;
  final String? detailText;
  final bool isFailure;
}

Color _verdictAccent(SemanticColors semantic, GoNoGoVerdict verdict) =>
    switch (verdict) {
      GoNoGoVerdict.go => semantic.success,
      GoNoGoVerdict.marginal => semantic.warning,
      GoNoGoVerdict.noGo => semantic.error,
      GoNoGoVerdict.insufficientData => semantic.info,
    };

IconData _verdictIcon(GoNoGoVerdict verdict) => switch (verdict) {
  GoNoGoVerdict.go => Icons.check_circle_outline,
  GoNoGoVerdict.marginal => Icons.warning_amber_outlined,
  GoNoGoVerdict.noGo => Icons.block_flipped,
  GoNoGoVerdict.insufficientData => Icons.info_outline,
};
