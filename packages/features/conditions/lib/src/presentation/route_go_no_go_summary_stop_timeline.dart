part of 'route_go_no_go_summary_section.dart';

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
