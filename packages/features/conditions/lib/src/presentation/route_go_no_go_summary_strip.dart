part of 'route_go_no_go_summary_section.dart';

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
  const _RouteGoNoGoSummaryStrip({
    required this.result,
    this.catalogStopOrderIndices = const [],
    this.snapStops = const [],
  });

  final RouteGoNoGoResult result;
  final List<int> catalogStopOrderIndices;
  final List<RouteGoNoGoSnapStop> snapStops;

  int _routeOrderIndex(int catalogOrderIndex) {
    if (catalogOrderIndex < catalogStopOrderIndices.length) {
      return catalogStopOrderIndices[catalogOrderIndex];
    }
    return catalogOrderIndex;
  }

  bool _hasDetails(AppLocalizations l10n) {
    final timelineCount =
        result.waypointResults.length +
        result.waypointFailures.length +
        snapStops.length;
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
          orderIndex: _routeOrderIndex(stop.orderIndex),
          launchName: stop.launchName,
          verdict: stop.result.verdict,
          detailText: waypointGoNoGoSummaryLine(l10n, stop.result),
        ),
      for (final failure in result.waypointFailures)
        _TimelineStop(
          orderIndex: _routeOrderIndex(failure.orderIndex),
          launchName: failure.launchName,
          detailText: localizeRouteGoNoGoFailureMessage(
            l10n,
            failure.failure,
          ),
          isFailure: true,
        ),
      for (final snap in snapStops)
        _TimelineStop(
          orderIndex: snap.orderIndex,
          launchName: snap.label,
          detailText: l10n.conditionsCustomStopNoData,
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
