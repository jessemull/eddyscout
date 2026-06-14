import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_design_system/eddyscout_design_system.dart';
import 'package:eddyscout_localization/eddyscout_localization.dart';
import 'package:eddyscout_map/src/domain/map_trip_duration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'map_search_provider.dart';

/// Floating edit-stops card (Google Maps directions style).
class MapRoutePlanningChrome extends ConsumerWidget {
  const MapRoutePlanningChrome({
    required this.waypoints,
    required this.routeLengthKm,
    required this.onBack,
    required this.onDone,
    required this.onRemoveStop,
    required this.onReorderStop,
    super.key,
  });

  final List<LaunchPoint> waypoints;
  final double? routeLengthKm;
  final VoidCallback onBack;
  final VoidCallback onDone;
  final ValueChanged<int> onRemoveStop;
  final void Function(int oldIndex, int newIndex) onReorderStop;

  static const double _chromeInset = Spacing.sm;
  static const double _footerVerticalInset = Spacing.sm;
  static const double _backColumnWidth = 36;
  static const double _timelineWidth = 18;
  static const double _rowHeight = 32;
  static const double _rowGap = 10;
  static const double _actionWidth = 36;
  static const double _actionIconSize = 18;
  static const int _connectorDotCount = 3;
  static const double _backIconSize = 20;
  static const double _backIconInset = (_backColumnWidth - _backIconSize) / 2;
  static const double _actionIconInset = (_actionWidth - _actionIconSize) / 2;

  void _onInlineSearchChanged(WidgetRef ref, String value) {
    ref.read(mapSearchQueryProvider.notifier).changeQuery(value);
    if (value.trim().isEmpty) {
      return;
    }
    ref.read(mapSearchContextStateProvider.notifier).setAddStop();
    ref.read(mapSearchExpandedProvider.notifier).expand();
  }

  String _stopSemanticsLabel(AppLocalizations l10n, int index, String name) {
    if (index == 0) {
      return l10n.mapRouteOriginStopSemantics(name);
    }
    if (waypoints.length >= 2 && index == waypoints.length - 1) {
      return l10n.mapRouteDestinationStopSemantics(name);
    }
    final letter = String.fromCharCode(65 + (index - 1));
    return l10n.mapRouteMiddleStopSemantics(letter, name);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final hasDestination = waypoints.length >= 2;
    final canDone = waypoints.length >= 2;
    final tripMinutes = estimateTripDurationMinutes(distanceKm: routeLengthKm);
    final tripMiles = formatDistanceMiles(routeLengthKm);
    final showTotalTrip = canDone && tripMinutes != null && tripMiles != null;

    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      color: scheme.surface,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              _chromeInset,
              _chromeInset,
              Spacing.xs,
              _rowGap,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PlanningChromeBackButton(onBack: onBack),
                Expanded(
                  child: _PlanningStopListSection(
                    waypoints: waypoints,
                    hasDestination: hasDestination,
                    searchHintText: l10n.mapSearchPlaceholder,
                    stopSemanticsLabel: (index, name) =>
                        _stopSemanticsLabel(l10n, index, name),
                    onRemoveStop: onRemoveStop,
                    onReorderStop: onReorderStop,
                    onInlineSearchChanged: (value) =>
                        _onInlineSearchChanged(ref, value),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          _PlanningChromeFooter(
            showTotalTrip: showTotalTrip,
            totalTripLabel: tripMinutes != null && tripMiles != null
                ? l10n.mapRouteTotalTrip(tripMinutes, tripMiles)
                : null,
            canDone: canDone,
            doneLabel: l10n.mapPlanningDoneLabel,
            onDone: onDone,
          ),
        ],
      ),
    );
  }
}

class _PlanningChromeBackButton extends StatelessWidget {
  const _PlanningChromeBackButton({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final backTooltip = MaterialLocalizations.of(context).backButtonTooltip;
    return SizedBox(
      width: MapRoutePlanningChrome._backColumnWidth,
      height: MapRoutePlanningChrome._rowHeight,
      child: Tooltip(
        message: backTooltip,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onBack,
            borderRadius: BorderRadius.circular(20),
            child: Semantics(
              button: true,
              label: backTooltip,
              child: const Center(
                child: Icon(
                  Icons.arrow_back,
                  size: MapRoutePlanningChrome._backIconSize,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PlanningStopListSection extends StatelessWidget {
  const _PlanningStopListSection({
    required this.waypoints,
    required this.hasDestination,
    required this.searchHintText,
    required this.stopSemanticsLabel,
    required this.onRemoveStop,
    required this.onReorderStop,
    required this.onInlineSearchChanged,
  });

  final List<LaunchPoint> waypoints;
  final bool hasDestination;
  final String searchHintText;
  final String Function(int index, String name) stopSemanticsLabel;
  final ValueChanged<int> onRemoveStop;
  final void Function(int oldIndex, int newIndex) onReorderStop;
  final ValueChanged<String> onInlineSearchChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (waypoints.isNotEmpty)
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            buildDefaultDragHandles: false,
            itemCount: waypoints.length,
            onReorderItem: onReorderStop,
            itemBuilder: (context, index) {
              final launch = waypoints[index];
              final canRemove = waypoints.length > 1;
              return Semantics(
                key: ValueKey('${launch.id}_$index'),
                label: stopSemanticsLabel(index, launch.name),
                hint: l10n.mapRouteReorderStopHint,
                child: _EditStopRow(
                  showConnectorBelow: true,
                  indicator: _StopIndicator(
                    index: index,
                    totalStops: waypoints.length,
                  ),
                  label: launch.name,
                  onRemove: canRemove ? () => onRemoveStop(index) : null,
                  removeSemanticsLabel: l10n.mapRouteDeleteStopSemantics(
                    launch.name,
                  ),
                  reorderHint: l10n.mapRouteReorderStopHint,
                  dragIndex: index,
                ),
              );
            },
          ),
        _InlineSearchRow(
          fieldKey: hasDestination
              ? const Key('map_add_stop_search_field')
              : const Key('map_destination_search_field'),
          hintText: searchHintText,
          onChanged: onInlineSearchChanged,
        ),
      ],
    );
  }
}

class _PlanningChromeFooter extends StatelessWidget {
  const _PlanningChromeFooter({
    required this.showTotalTrip,
    required this.totalTripLabel,
    required this.canDone,
    required this.doneLabel,
    required this.onDone,
  });

  final bool showTotalTrip;
  final String? totalTripLabel;
  final bool canDone;
  final String doneLabel;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      key: const Key('map_planning_footer'),
      height:
          MapRoutePlanningChrome._rowHeight +
          (MapRoutePlanningChrome._footerVerticalInset * 2),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          MapRoutePlanningChrome._chromeInset +
              MapRoutePlanningChrome._backIconInset,
          MapRoutePlanningChrome._footerVerticalInset,
          Spacing.xs,
          MapRoutePlanningChrome._footerVerticalInset,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (showTotalTrip && totalTripLabel != null)
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    totalTripLabel!,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(height: 1.2),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
            else
              const Spacer(),
            SizedBox(
              width: MapRoutePlanningChrome._actionWidth * 2,
              child: Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(
                    right: MapRoutePlanningChrome._actionIconInset,
                  ),
                  child: Semantics(
                    button: true,
                    enabled: canDone,
                    label: doneLabel,
                    child: GestureDetector(
                      onTap: canDone ? onDone : null,
                      behavior: HitTestBehavior.opaque,
                      child: Text(
                        doneLabel,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          height: 1,
                          color: canDone
                              ? scheme.primary
                              : scheme.onSurface.withValues(alpha: 0.38),
                        ),
                        softWrap: false,
                        maxLines: 1,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EditStopRow extends StatelessWidget {
  const _EditStopRow({
    required this.showConnectorBelow,
    required this.indicator,
    required this.label,
    required this.dragIndex,
    required this.reorderHint,
    this.onRemove,
    this.removeSemanticsLabel,
  });

  final bool showConnectorBelow;
  final Widget indicator;
  final String label;
  final int dragIndex;
  final String reorderHint;
  final VoidCallback? onRemove;
  final String? removeSemanticsLabel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: showConnectorBelow
          ? MapRoutePlanningChrome._rowHeight + MapRoutePlanningChrome._rowGap
          : MapRoutePlanningChrome._rowHeight,
      child: Column(
        children: [
          SizedBox(
            height: MapRoutePlanningChrome._rowHeight,
            child: Row(
              children: [
                SizedBox(
                  width: MapRoutePlanningChrome._timelineWidth,
                  child: Center(child: indicator),
                ),
                const SizedBox(width: Spacing.xs),
                Expanded(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                ReorderableDragStartListener(
                  index: dragIndex,
                  child: Semantics(
                    button: true,
                    label: reorderHint,
                    child: const SizedBox(
                      width: MapRoutePlanningChrome._actionWidth,
                      height: MapRoutePlanningChrome._rowHeight,
                      child: Icon(Icons.drag_handle, size: 18),
                    ),
                  ),
                ),
                if (onRemove != null)
                  Semantics(
                    button: true,
                    label: removeSemanticsLabel,
                    child: SizedBox(
                      width: MapRoutePlanningChrome._actionWidth,
                      height: MapRoutePlanningChrome._rowHeight,
                      child: IconButton(
                        tooltip: MaterialLocalizations.of(
                          context,
                        ).deleteButtonTooltip,
                        onPressed: onRemove,
                        icon: Icon(
                          Icons.close,
                          size: 18,
                          color: scheme.outline,
                        ),
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  )
                else
                  const SizedBox(width: MapRoutePlanningChrome._actionWidth),
              ],
            ),
          ),
          if (showConnectorBelow)
            const Row(
              children: [
                SizedBox(
                  height: MapRoutePlanningChrome._rowGap,
                  width: MapRoutePlanningChrome._timelineWidth,
                  child: _VerticalDotConnector(),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _StopIndicator extends StatelessWidget {
  const _StopIndicator({
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
      return Icon(
        Icons.location_on,
        size: 16,
        color: scheme.error,
      );
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

class _VerticalDotConnector extends StatelessWidget {
  const _VerticalDotConnector();

  @override
  Widget build(BuildContext context) {
    final dotColor = Theme.of(context).colorScheme.outlineVariant;
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(
        MapRoutePlanningChrome._connectorDotCount,
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

class _InlineSearchRow extends StatelessWidget {
  const _InlineSearchRow({
    required this.fieldKey,
    required this.hintText,
    required this.onChanged,
  });

  final Key fieldKey;
  final String hintText;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: MapRoutePlanningChrome._rowHeight,
      child: Row(
        children: [
          SizedBox(
            width: MapRoutePlanningChrome._timelineWidth,
            child: Icon(
              Icons.location_on_outlined,
              size: 16,
              color: scheme.primary,
            ),
          ),
          const SizedBox(width: Spacing.xs),
          Expanded(
            child: Theme(
              data: Theme.of(context).copyWith(
                inputDecorationTheme: InputDecorationTheme(
                  filled: false,
                  fillColor: Colors.transparent,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                  isCollapsed: true,
                  hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
              child: TextField(
                key: fieldKey,
                decoration: InputDecoration(hintText: hintText),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
                onChanged: onChanged,
              ),
            ),
          ),
          const SizedBox(width: MapRoutePlanningChrome._actionWidth * 2),
        ],
      ),
    );
  }
}
