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

  static const double _backColumnWidth = 40;
  static const double _timelineWidth = 18;
  static const double _rowHeight = 36;
  static const double _connectorHeight = 8;
  static const double _actionWidth = 40;

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
          if (waypoints.isNotEmpty)
            ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              buildDefaultDragHandles: false,
              itemCount: waypoints.length,
              onReorderItem: onReorderStop,
              itemBuilder: (context, index) {
                final launch = waypoints[index];
                final isFirst = index == 0;
                final canRemove = waypoints.length > 1;
                return Semantics(
                  key: ValueKey('${launch.id}_$index'),
                  label: _stopSemanticsLabel(l10n, index, launch.name),
                  hint: l10n.mapRouteReorderStopHint,
                  child: _EditStopRow(
                    showBack: isFirst,
                    onBack: onBack,
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
            hintText: l10n.mapSearchPlaceholder,
            onChanged: (value) => _onInlineSearchChanged(ref, value),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              Spacing.sm,
              Spacing.xxs,
              Spacing.xs,
              Spacing.xs,
            ),
            child: Row(
              children: [
                if (showTotalTrip)
                  Expanded(
                    child: Text(
                      l10n.mapRouteTotalTrip(tripMinutes, tripMiles),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  )
                else
                  const Spacer(),
                TextButton(
                  onPressed: canDone ? onDone : null,
                  style: TextButton.styleFrom(
                    foregroundColor: scheme.primary,
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(
                      horizontal: Spacing.sm,
                    ),
                  ),
                  child: Text(l10n.mapPlanningDoneLabel),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EditStopRow extends StatelessWidget {
  const _EditStopRow({
    required this.showBack,
    required this.onBack,
    required this.showConnectorBelow,
    required this.indicator,
    required this.label,
    required this.dragIndex,
    required this.reorderHint,
    this.onRemove,
    this.removeSemanticsLabel,
  });

  final bool showBack;
  final VoidCallback onBack;
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
          ? MapRoutePlanningChrome._rowHeight +
                MapRoutePlanningChrome._connectorHeight
          : MapRoutePlanningChrome._rowHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: MapRoutePlanningChrome._backColumnWidth,
            height: MapRoutePlanningChrome._rowHeight,
            child: showBack
                ? IconButton(
                    tooltip: MaterialLocalizations.of(
                      context,
                    ).backButtonTooltip,
                    onPressed: onBack,
                    icon: const Icon(Icons.arrow_back, size: 20),
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                  )
                : null,
          ),
          SizedBox(
            width: MapRoutePlanningChrome._timelineWidth,
            child: Column(
              children: [
                SizedBox(
                  height: MapRoutePlanningChrome._rowHeight,
                  child: Center(child: indicator),
                ),
                if (showConnectorBelow)
                  const SizedBox(
                    height: MapRoutePlanningChrome._connectorHeight,
                    child: _VerticalDotConnector(),
                  ),
              ],
            ),
          ),
          const SizedBox(width: Spacing.xs),
          Expanded(
            child: SizedBox(
              height: MapRoutePlanningChrome._rowHeight,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
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
                  icon: Icon(Icons.close, size: 18, color: scheme.outline),
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                ),
              ),
            )
          else
            const SizedBox(width: MapRoutePlanningChrome._actionWidth),
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
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(
        2,
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
          const SizedBox(width: MapRoutePlanningChrome._backColumnWidth),
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
