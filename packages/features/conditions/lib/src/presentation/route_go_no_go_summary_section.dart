import 'package:eddyscout_conditions/src/domain/go_no_go.dart';
import 'package:eddyscout_conditions/src/domain/route_go_no_go.dart';
import 'package:eddyscout_conditions/src/presentation/go_no_go_l10n.dart';
import 'package:eddyscout_conditions/src/presentation/route_go_no_go_rollup_provider.dart';
import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_design_system/eddyscout_design_system.dart';
import 'package:eddyscout_localization/eddyscout_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Shared with stop timeline rows so verdict icons align with route markers.
const _routeGoNoGoTimelineWidth = 18.0;

const _routeGoNoGoHeaderVerdictIconSize = 26.0;
const _routeGoNoGoRowVerdictIconSize = 14.0;
const _routeGoNoGoHeaderIconTopInset = 0.0;
const _routeGoNoGoRowIconTopInset = 1.0;
const _routeGoNoGoHeaderIconColumnWidth = 18.0;
const _routeGoNoGoExpansionCaretSize = 24.0;
const _routeGoNoGoHeaderIconTextGap = 14.0;
const double _routeGoNoGoSubheaderDetailGap = Spacing.xs;

enum _RouteGoNoGoBlockSize { header, stopRow }

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
    return _RouteGoNoGoVerdictPanel(
      size: _RouteGoNoGoBlockSize.header,
      accent: scheme.error,
      icon: Icons.error_outline,
      primaryLabel: message,
      trailing: TextButton(
        onPressed: onRetry,
        style: TextButton.styleFrom(
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(l10n.retryButton),
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
          detailText: waypointGoNoGoSummaryLine(l10n, stop.result),
        ),
      for (final failure in result.waypointFailures)
        _TimelineStop(
          orderIndex: failure.orderIndex,
          launchName: failure.launchName,
          detailText: localizeRouteGoNoGoFailureMessage(
            l10n,
            failure.failure,
          ),
          isFailure: true,
        ),
    ]..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
    return stops;
  }

  String? _headerDetailText(AppLocalizations l10n) {
    if (result.triggeringReasons.isNotEmpty) {
      return localizeGoNoGoReasonRouteSummary(
        l10n,
        result.triggeringReasons.first,
      );
    }
    if (result.verdict == GoNoGoVerdict.go) {
      return l10n.launchDetailGoNoGoNoWarnings;
    }
    return null;
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
    final detailText = _headerDetailText(l10n);
    final timelineStops = _timelineStops(l10n);

    final semanticsLabel = stopName == null
        ? l10n.routeGoNoGoSemanticsVerdictOnly(verdictLabel)
        : l10n.routeGoNoGoSemanticsVerdictWithStop(verdictLabel, stopName);

    final header = _RouteGoNoGoVerdictPanel(
      size: _RouteGoNoGoBlockSize.header,
      accent: accent,
      icon: icon,
      primaryLabel: verdictLabel,
      secondaryLabel: stopName,
      detailText: detailText,
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
          showTrailingIcon: false,
          title: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: header),
              Icon(
                Icons.expand_more,
                color: scheme.onSurfaceVariant,
                size: _routeGoNoGoExpansionCaretSize,
              ),
            ],
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
                            localizeGoNoGoReasonRouteSummary(l10n, reason),
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                  height: 1.2,
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

/// Read-only stop row for route go/no-go (matches map planning timeline visuals).
class _RouteGoNoGoStopTimeline extends StatefulWidget {
  const _RouteGoNoGoStopTimeline({
    required this.stops,
    required this.l10n,
  });

  final List<_TimelineStop> stops;
  final AppLocalizations l10n;

  @override
  State<_RouteGoNoGoStopTimeline> createState() =>
      _RouteGoNoGoStopTimelineState();
}

class _RouteGoNoGoStopTimelineState extends State<_RouteGoNoGoStopTimeline> {
  static const double _estimatedHeightWithSummary = 48;
  static const double _estimatedHeightCompact = 24;
  static const double _connectorMinHeight = 28;
  static const double _stopGap = 12;
  static const double _connectorInset = Spacing.sm;

  late List<double> _contentHeights;

  @override
  void initState() {
    super.initState();
    _contentHeights = _initialHeights();
  }

  @override
  void didUpdateWidget(covariant _RouteGoNoGoStopTimeline oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.stops.length != widget.stops.length) {
      _contentHeights = _initialHeights();
    }
  }

  List<double> _initialHeights() => List.generate(
    widget.stops.length,
    (index) =>
        _estimatedHeightFor(widget.stops[index]) +
        (index < widget.stops.length - 1 ? _stopGap : 0),
  );

  static double _estimatedHeightFor(_TimelineStop stop) =>
      stop.detailText != null
      ? _estimatedHeightWithSummary
      : _estimatedHeightCompact;

  static double _indicatorHeight(int index) => index == 0 ? 14 : 16;

  void _onContentSized(int index, Size size) {
    if (index >= _contentHeights.length || size.height <= 0) {
      return;
    }
    final stop = widget.stops[index];
    final resolved = stop.detailText != null
        ? size.height.clamp(_estimatedHeightWithSummary, double.infinity)
        : size.height;
    if ((_contentHeights[index] - resolved).abs() <= 0.5) {
      return;
    }
    setState(() {
      _contentHeights[index] = resolved;
    });
  }

  double _connectorHeight(int index) {
    final gap = _contentHeights[index] - _indicatorHeight(index);
    return gap.clamp(_connectorMinHeight, double.infinity);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: _routeGoNoGoTimelineWidth,
          child: Column(
            children: [
              for (var i = 0; i < widget.stops.length; i++) ...[
                _RouteGoNoGoStopIndicator(
                  index: i,
                  totalStops: widget.stops.length,
                ),
                if (i < widget.stops.length - 1)
                  SizedBox(
                    height: _connectorHeight(i),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: _RouteGoNoGoStopTimelineState._connectorInset,
                      ),
                      child: _RouteGoNoGoVerticalDotConnector(),
                    ),
                  ),
              ],
            ],
          ),
        ),
        const SizedBox(width: Spacing.xxs),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < widget.stops.length; i++)
                _MeasureSize(
                  onChange: (size) => _onContentSized(i, size),
                  child: Padding(
                    padding: EdgeInsets.only(
                      bottom: i < widget.stops.length - 1 ? _stopGap : 0,
                    ),
                    child: _RouteGoNoGoStopContent(
                      stop: widget.stops[i],
                      l10n: widget.l10n,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Reports [child] size after layout so timeline connectors track height.
class _MeasureSize extends SingleChildRenderObjectWidget {
  const _MeasureSize({
    required this.onChange,
    required super.child,
  });

  final ValueChanged<Size> onChange;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderMeasureSize(onChange);

  @override
  void updateRenderObject(
    BuildContext context,
    covariant _RenderMeasureSize renderObject,
  ) {
    renderObject.onChange = onChange;
  }
}

class _RenderMeasureSize extends RenderProxyBox {
  _RenderMeasureSize(this.onChange);

  ValueChanged<Size> onChange;
  Size? _oldSize;

  @override
  void performLayout() {
    super.performLayout();
    if (_oldSize == size) {
      return;
    }
    _oldSize = size;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      onChange(size);
    });
  }
}

class _RouteGoNoGoStopContent extends StatelessWidget {
  const _RouteGoNoGoStopContent({
    required this.stop,
    required this.l10n,
  });

  final _TimelineStop stop;
  final AppLocalizations l10n;

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
        ? Icons.info_outline
        : _verdictIcon(stop.verdict!);

    return _RouteGoNoGoVerdictPanel(
      size: _RouteGoNoGoBlockSize.stopRow,
      accent: accent,
      icon: icon,
      primaryLabel: stop.launchName,
      detailText: stop.detailText,
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

const _routeGoNoGoConnectorDotCount = 3;

class _RouteGoNoGoVerticalDotConnector extends StatelessWidget {
  const _RouteGoNoGoVerticalDotConnector();

  @override
  Widget build(BuildContext context) {
    final dotColor = Theme.of(context).colorScheme.outlineVariant;
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(
        _routeGoNoGoConnectorDotCount,
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
