import 'package:eddyscout_conditions/src/domain/go_no_go.dart';
import 'package:eddyscout_conditions/src/domain/route_go_no_go.dart';
import 'package:eddyscout_conditions/src/presentation/go_no_go_l10n.dart';
import 'package:eddyscout_conditions/src/presentation/route_go_no_go_rollup_provider.dart';
import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_design_system/eddyscout_design_system.dart';
import 'package:eddyscout_localization/eddyscout_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Shared with stop timeline rows so verdict icons align with route markers.
const _routeGoNoGoTimelineWidth = 18.0;

/// Fits the timeline column; paired with [Spacing.sm] before header text.
const _routeGoNoGoHeaderVerdictIconSize = 26.0;

const _routeGoNoGoExpansionCaretSize = 24.0;

/// Gap between accordion verdict icon and title block.
const _routeGoNoGoHeaderIconTextGap = 14.0;

/// Route-level go/no-go rollup for map preview and saved route detail.
class RouteGoNoGoSummarySection extends ConsumerWidget {
  /// Creates a section that loads rollup for [launchIdsInOrder].
  const RouteGoNoGoSummarySection({
    required this.launchIdsInOrder,
    super.key,
  });

  /// Ordered catalog launch ids along the route.
  final List<String> launchIdsInOrder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (launchIdsInOrder.length < 2) {
      return const SizedBox.shrink();
    }

    final waypointsKey = RouteGoNoGoWaypointsKey.fromOrdered(launchIdsInOrder);
    final rollupAsync = ref.watch(routeGoNoGoRollupProvider(waypointsKey));

    return rollupAsync.when(
      loading: () => Semantics(
        label: context.l10n.routeGoNoGoLoading,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: Spacing.xxs),
          child: Row(
            children: [
              SizedBox(
                height: 16,
                width: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: Spacing.sm),
              Text(
                context.l10n.routeGoNoGoLoading,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
      error: (error, _) => _RouteGoNoGoErrorStrip(
        message: error is AppFailure
            ? error.message
            : context.l10n.routeGoNoGoErrorGeneric,
        onRetry: () => ref.invalidate(routeGoNoGoRollupProvider(waypointsKey)),
      ),
      data: (result) => _RouteGoNoGoSummaryStrip(result: result),
    );
  }
}

class _RouteGoNoGoErrorStrip extends StatelessWidget {
  const _RouteGoNoGoErrorStrip({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    return _VerdictHeaderRow(
      accent: scheme.error,
      icon: Icons.error_outline,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              message,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: scheme.onSurface),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            style: TextButton.styleFrom(
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(l10n.retryButton),
          ),
        ],
      ),
    );
  }
}

class _RouteGoNoGoSummaryStrip extends StatelessWidget {
  const _RouteGoNoGoSummaryStrip({required this.result});

  final RouteGoNoGoResult result;

  bool _hasDetails(AppLocalizations l10n) {
    final timelineCount =
        result.waypointResults.length + result.waypointFailures.length;
    return result.triggeringReasons.length > 1 ||
        (result.verdict == GoNoGoVerdict.go &&
            result.triggeringReasons.isEmpty &&
            timelineCount > 1) ||
        result.waypointFailures.isNotEmpty ||
        timelineCount > 1;
  }

  List<_TimelineStop> _timelineStops(AppLocalizations l10n) {
    final stops = <_TimelineStop>[
      for (final stop in result.waypointResults)
        _TimelineStop(
          orderIndex: stop.orderIndex,
          launchName: stop.launchName,
          verdict: stop.result.verdict,
          summaryLine: waypointGoNoGoSummaryLine(l10n, stop.result),
        ),
      for (final failure in result.waypointFailures)
        _TimelineStop(
          orderIndex: failure.orderIndex,
          launchName: failure.launchName,
          summaryLine: localizeRouteGoNoGoFailureMessage(
            l10n,
            failure.failure,
          ),
          isFailure: true,
        ),
    ]..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
    return stops;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final semantic = SemanticColors.of(context);
    final accent = _verdictAccent(semantic, result.verdict);
    final icon = _verdictIcon(result.verdict);
    final verdictLabel = localizeGoNoGoVerdict(l10n, result.verdict);
    final stopName = result.triggeringWaypoint?.launchName;
    final primaryReason = result.triggeringReasons.isEmpty
        ? null
        : localizeGoNoGoReason(l10n, result.triggeringReasons.first);
    final timelineStops = _timelineStops(l10n);

    final semanticsLabel = stopName == null
        ? l10n.routeGoNoGoSemanticsVerdictOnly(verdictLabel)
        : l10n.routeGoNoGoSemanticsVerdictWithStop(verdictLabel, stopName);

    final header = _VerdictHeaderRow(
      accent: accent,
      icon: icon,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            verdictLabel,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: scheme.onSurface,
              fontWeight: FontWeight.w600,
              height: 1.15,
            ),
          ),
          if (stopName != null) ...[
            const SizedBox(height: Spacing.xxs),
            Text(
              l10n.routeGoNoGoTriggeringStop(stopName),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
                height: 1.2,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (primaryReason != null) ...[
            Text(
              primaryReason,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
                height: 1.2,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ] else if (result.verdict == GoNoGoVerdict.go)
            Text(
              l10n.launchDetailGoNoGoNoWarnings,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
                height: 1.2,
              ),
            ),
        ],
      ),
    );

    if (!_hasDetails(l10n)) {
      return Semantics(label: semanticsLabel, child: header);
    }

    return Semantics(
      label: semanticsLabel,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.zero,
          childrenPadding: const EdgeInsets.only(top: Spacing.sm),
          visualDensity: VisualDensity.compact,
          collapsedShape: const RoundedRectangleBorder(),
          shape: const RoundedRectangleBorder(),
          title: header,
          trailing: Icon(
            Icons.expand_more,
            color: scheme.onSurfaceVariant,
            size: _routeGoNoGoExpansionCaretSize,
          ),
          children: [
            if (result.triggeringReasons.length > 1)
              Padding(
                padding: const EdgeInsets.only(bottom: Spacing.xxs),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: result.triggeringReasons
                      .skip(1)
                      .map(
                        (reason) => Padding(
                          padding: const EdgeInsets.only(bottom: Spacing.xxs),
                          child: Text(
                            localizeGoNoGoReason(l10n, reason),
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            if (timelineStops.length > 1)
              _RouteGoNoGoStopTimeline(stops: timelineStops, l10n: l10n),
            const SizedBox(height: Spacing.md),
            Text(
              l10n.routeGoNoGoRouteDisclaimer,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Read-only stop row for route go/no-go (matches map planning timeline visuals).
class _RouteGoNoGoStopTimeline extends StatelessWidget {
  const _RouteGoNoGoStopTimeline({
    required this.stops,
    required this.l10n,
  });

  final List<_TimelineStop> stops;
  final AppLocalizations l10n;

  static const double _timelineWidth = _routeGoNoGoTimelineWidth;
  static const double _rowGap = 10;
  static const int _connectorDotCount = 3;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < stops.length; i++)
          _RouteGoNoGoStopRow(
            index: i,
            totalStops: stops.length,
            stop: stops[i],
            l10n: l10n,
            showConnectorBelow: i < stops.length - 1,
          ),
      ],
    );
  }
}

class _RouteGoNoGoStopRow extends StatelessWidget {
  const _RouteGoNoGoStopRow({
    required this.index,
    required this.totalStops,
    required this.stop,
    required this.l10n,
    required this.showConnectorBelow,
  });

  final int index;
  final int totalStops;
  final _TimelineStop stop;
  final AppLocalizations l10n;
  final bool showConnectorBelow;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final semantic = SemanticColors.of(context);
    final accent = stop.isFailure
        ? semantic.error
        : stop.verdict == null
        ? scheme.onSurfaceVariant
        : _verdictAccent(semantic, stop.verdict!);
    final icon = stop.isFailure
        ? Icons.error_outline
        : stop.verdict == null
        ? null
        : _verdictIcon(stop.verdict!);
    final verdictLabel = stop.verdict == null
        ? null
        : localizeGoNoGoVerdict(l10n, stop.verdict!);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: _RouteGoNoGoStopTimeline._timelineWidth,
              child: Align(
                alignment: Alignment.topCenter,
                child: _RouteGoNoGoStopIndicator(
                  index: index,
                  totalStops: totalStops,
                ),
              ),
            ),
            const SizedBox(width: Spacing.xs),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Transform.translate(
                    offset: const Offset(0, -2),
                    child: Text(
                      stop.launchName,
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (stop.summaryLine != null) ...[
                    const SizedBox(height: Spacing.xxs),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (icon != null) ...[
                          Semantics(
                            label: verdictLabel ?? stop.summaryLine,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 1),
                              child: Icon(icon, color: accent, size: 14),
                            ),
                          ),
                          const SizedBox(width: Spacing.xxs),
                        ],
                        Expanded(
                          child: Text(
                            stop.summaryLine!,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        if (showConnectorBelow)
          const Row(
            children: [
              SizedBox(
                height: _RouteGoNoGoStopTimeline._rowGap,
                width: _RouteGoNoGoStopTimeline._timelineWidth,
                child: _RouteGoNoGoVerticalDotConnector(),
              ),
            ],
          ),
      ],
    );
  }
}

class _RouteGoNoGoStopIndicator extends StatelessWidget {
  const _RouteGoNoGoStopIndicator({
    required this.index,
    required this.totalStops,
  });

  final int index;
  final int totalStops;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (index == 0) {
      return SizedBox(
        width: 14,
        height: 14,
        child: Stack(
          alignment: Alignment.center,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: scheme.primary.withValues(alpha: 0.35),
                  width: 3,
                ),
              ),
              child: const SizedBox(width: 14, height: 14),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: scheme.primary,
              ),
              child: const SizedBox(width: 6, height: 6),
            ),
          ],
        ),
      );
    }
    if (totalStops >= 2 && index == totalStops - 1) {
      return Icon(Icons.location_on, size: 16, color: scheme.error);
    }
    final letter = String.fromCharCode(65 + (index - 1));
    return SizedBox(
      width: 16,
      height: 16,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: scheme.outline, width: 1.5),
        ),
        child: Center(
          child: Text(
            letter,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              height: 1,
              color: scheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}

class _RouteGoNoGoVerticalDotConnector extends StatelessWidget {
  const _RouteGoNoGoVerticalDotConnector();

  @override
  Widget build(BuildContext context) {
    final dotColor = Theme.of(context).colorScheme.outlineVariant;
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(
        _RouteGoNoGoStopTimeline._connectorDotCount,
        (_) => Container(
          width: 2,
          height: 2,
          decoration: BoxDecoration(
            color: dotColor,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

class _TimelineStop {
  const _TimelineStop({
    required this.orderIndex,
    required this.launchName,
    this.verdict,
    this.summaryLine,
    this.isFailure = false,
  });

  final int orderIndex;
  final String launchName;
  final GoNoGoVerdict? verdict;
  final String? summaryLine;
  final bool isFailure;
}

class _VerdictHeaderRow extends StatelessWidget {
  const _VerdictHeaderRow({
    required this.accent,
    required this.icon,
    required this.child,
  });

  final Color accent;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        children: [
          SizedBox(
            width: _routeGoNoGoTimelineWidth,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Icon(
                icon,
                color: accent,
                size: _routeGoNoGoHeaderVerdictIconSize,
              ),
            ),
          ),
          const SizedBox(width: _routeGoNoGoHeaderIconTextGap),
          Expanded(child: child),
        ],
      ),
    );
  }
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
