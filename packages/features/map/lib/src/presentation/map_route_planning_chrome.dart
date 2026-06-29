import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_design_system/eddyscout_design_system.dart';
import 'package:eddyscout_localization/eddyscout_localization.dart';
import 'package:eddyscout_map/src/domain/map_trip_duration.dart';
import 'package:eddyscout_persistence/eddyscout_persistence.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'map_planning_provider.dart';
import 'map_planning_snap_stop_pending_rename_provider.dart';
import 'map_search_provider.dart';
import 'map_sheet_header_icon_button.dart';
import 'paddle_speed_provider.dart';

/// Maximum length for a custom snap stop label in planning chrome.
const int kSnapStopLabelMaxLength = 40;

/// Floating edit-stops card (Google Maps directions style).
class MapRoutePlanningChrome extends ConsumerWidget {
  const MapRoutePlanningChrome({
    required this.stops,
    required this.routeLengthKm,
    required this.canFinishPlanning,
    required this.onBack,
    required this.onDone,
    required this.onRemoveStop,
    required this.onReorderStop,
    required this.onChooseOnMap,
    super.key,
  });

  final List<RoutePlanningStop> stops;
  final double? routeLengthKm;
  final bool canFinishPlanning;
  final VoidCallback onBack;
  final VoidCallback onDone;
  final ValueChanged<int> onRemoveStop;
  final void Function(int oldIndex, int newIndex) onReorderStop;
  final VoidCallback onChooseOnMap;

  static const double _chromeInset = Spacing.sm;
  static const double _footerVerticalInset = Spacing.sm;
  static const double _backColumnWidth = 36;
  static const double _timelineWidth = 18;
  static const double _rowHeight = 32;
  static const double _rowGap = 10;
  static const double _actionWidth = 30;
  static const double _actionIconSize = MapSheetHeaderIconButton.iconSize;
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

  String _stopSemanticsLabel(
    AppLocalizations l10n,
    int index,
    RoutePlanningStop stop,
  ) {
    final name = stop.displayLabel;
    if (stop.isSnap) {
      return l10n.mapRouteCustomStopSemantics(name);
    }
    if (index == 0) {
      return l10n.mapRouteOriginStopSemantics(name);
    }
    if (stops.length >= 2 && index == stops.length - 1) {
      return l10n.mapRouteDestinationStopSemantics(name);
    }
    final letter = String.fromCharCode(65 + (index - 1));
    return l10n.mapRouteMiddleStopSemantics(letter, name);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final hasDestination = stops.length >= 2;
    final canDone = canFinishPlanning;
    final speedKmh = ref.watch(effectivePaddleSpeedKmhProvider);
    final displayUnits = ref.watch(effectiveDisplayUnitSystemProvider);
    final tripMinutes = estimateTripDurationMinutes(
      distanceKm: routeLengthKm,
      speedKmh: speedKmh,
    );
    final tripDistance = localizedDistanceFromKm(
      l10n,
      routeLengthKm,
      displayUnits,
    );
    final showTotalTrip =
        canDone && tripMinutes != null && tripDistance != null;
    final pendingRenameStopId = ref.watch(
      mapPlanningSnapStopPendingRenameProvider,
    );

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
                    stops: stops,
                    hasDestination: hasDestination,
                    searchHintText: l10n.mapSearchPlaceholder,
                    stopSemanticsLabel: (index, stop) =>
                        _stopSemanticsLabel(l10n, index, stop),
                    onRemoveStop: onRemoveStop,
                    onReorderStop: onReorderStop,
                    onRenameSnapStop: (stopId, newLabel) => ref
                        .read(routePlanningProvider.notifier)
                        .renameSnapStop(stopId, newLabel),
                    onInlineSearchChanged: (value) =>
                        _onInlineSearchChanged(ref, value),
                    onChooseOnMap: onChooseOnMap,
                    pendingRenameStopId: pendingRenameStopId,
                    onClearPendingRename: () => ref
                        .read(mapPlanningSnapStopPendingRenameProvider.notifier)
                        .clear(),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          _PlanningChromeFooter(
            showTotalTrip: showTotalTrip,
            totalTripLabel: tripMinutes != null && tripDistance != null
                ? l10n.mapRouteTotalTrip(tripMinutes, tripDistance)
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
    required this.stops,
    required this.hasDestination,
    required this.searchHintText,
    required this.stopSemanticsLabel,
    required this.onRemoveStop,
    required this.onReorderStop,
    required this.onRenameSnapStop,
    required this.onInlineSearchChanged,
    required this.onChooseOnMap,
    required this.pendingRenameStopId,
    required this.onClearPendingRename,
  });

  final List<RoutePlanningStop> stops;
  final bool hasDestination;
  final String searchHintText;
  final String Function(int index, RoutePlanningStop stop) stopSemanticsLabel;
  final ValueChanged<int> onRemoveStop;
  final void Function(int oldIndex, int newIndex) onReorderStop;
  final void Function(String stopId, String newLabel) onRenameSnapStop;
  final ValueChanged<String> onInlineSearchChanged;
  final VoidCallback onChooseOnMap;
  final String? pendingRenameStopId;
  final VoidCallback onClearPendingRename;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (stops.isNotEmpty)
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            buildDefaultDragHandles: false,
            itemCount: stops.length,
            onReorderItem: onReorderStop,
            itemBuilder: (context, index) {
              final stop = stops[index];
              final canRemove = stops.length > 1;
              return Semantics(
                key: ValueKey('${stop.stopId}_$index'),
                label: stopSemanticsLabel(index, stop),
                hint: l10n.mapRouteReorderStopHint,
                child: _EditStopRow(
                  key: ValueKey('edit_stop_${stop.stopId}'),
                  showConnectorBelow: true,
                  indicator: _StopIndicator(
                    index: index,
                    totalStops: stops.length,
                    isSnap: stop.isSnap,
                  ),
                  label: stop.displayLabel,
                  isSnap: stop.isSnap,
                  stopId: stop.stopId,
                  onRenameSnapStop: stop.isSnap
                      ? (newLabel) => onRenameSnapStop(stop.stopId, newLabel)
                      : null,
                  onRemove: canRemove ? () => onRemoveStop(index) : null,
                  removeSemanticsLabel: l10n.mapRouteDeleteStopSemantics(
                    stop.displayLabel,
                  ),
                  reorderHint: l10n.mapRouteReorderStopHint,
                  dragIndex: index,
                  startInEditMode:
                      stop.isSnap && stop.stopId == pendingRenameStopId,
                  onEditSessionStarted: onClearPendingRename,
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
        const SizedBox(height: Spacing.sm),
        _ChooseOnMapRow(
          label: l10n.mapRouteChooseOnMap,
          semanticsHint: l10n.mapRouteChooseOnMapHint,
          onTap: onChooseOnMap,
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

class _EditStopRow extends StatefulWidget {
  const _EditStopRow({
    required this.showConnectorBelow,
    required this.indicator,
    required this.label,
    required this.isSnap,
    required this.stopId,
    required this.dragIndex,
    required this.reorderHint,
    this.onRenameSnapStop,
    this.onRemove,
    this.removeSemanticsLabel,
    this.startInEditMode = false,
    this.onEditSessionStarted,
    super.key,
  });

  final bool showConnectorBelow;
  final Widget indicator;
  final String label;
  final bool isSnap;
  final String stopId;
  final int dragIndex;
  final String reorderHint;
  final ValueChanged<String>? onRenameSnapStop;
  final VoidCallback? onRemove;
  final String? removeSemanticsLabel;
  final bool startInEditMode;
  final VoidCallback? onEditSessionStarted;

  @override
  State<_EditStopRow> createState() => _EditStopRowState();
}

class _EditStopRowState extends State<_EditStopRow> {
  bool _editing = false;
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  bool get _canRename => widget.isSnap && widget.onRenameSnapStop != null;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.label);
    _focusNode = FocusNode()..addListener(_handleFocusChange);
    if (widget.startInEditMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _maybeStartPendingEdit();
      });
    }
  }

  @override
  void didUpdateWidget(covariant _EditStopRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.label != widget.label && !_focusNode.hasFocus) {
      _controller.text = widget.label;
    }
    if (widget.startInEditMode && !oldWidget.startInEditMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _maybeStartPendingEdit();
      });
    }
  }

  void _maybeStartPendingEdit() {
    if (!mounted || !widget.startInEditMode || _editing || !_canRename) {
      return;
    }
    _startEditing();
    widget.onEditSessionStarted?.call();
  }

  void _handleFocusChange() {
    if (!_focusNode.hasFocus && _editing) {
      _commit();
      setState(() => _editing = false);
    }
  }

  void _startEditing() {
    setState(() => _editing = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _focusNode.requestFocus();
      _controller.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _controller.text.length,
      );
    });
  }

  void _finishEditing() {
    _commit();
    _focusNode.unfocus();
    if (_editing) {
      setState(() => _editing = false);
    }
  }

  void _commit() {
    final trimmed = _controller.text.trim();
    if (trimmed.isEmpty) {
      _controller.text = widget.label;
      return;
    }
    if (trimmed != widget.label) {
      widget.onRenameSnapStop?.call(trimmed);
    }
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_handleFocusChange)
      ..dispose();
    _controller.dispose();
    super.dispose();
  }

  TextStyle? _labelStyle(BuildContext context) {
    return Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.2);
  }

  Widget _labelContent(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final labelStyle = _labelStyle(context);
    if (_canRename && _editing) {
      return TapRegion(
        onTapOutside: (_) => _finishEditing(),
        child: TextField(
          controller: _controller,
          focusNode: _focusNode,
          style: labelStyle,
          maxLength: kSnapStopLabelMaxLength,
          buildCounter:
              (
                context, {
                required currentLength,
                required isFocused,
                maxLength,
              }) => null,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _finishEditing(),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.only(bottom: 6),
            counterText: '',
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: scheme.primary),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: scheme.primary),
            ),
          ),
        ),
      );
    }
    return Text(
      widget.label,
      style: labelStyle,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: widget.showConnectorBelow
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
                  child: Center(child: widget.indicator),
                ),
                const SizedBox(width: Spacing.xs),
                Expanded(child: _labelContent(context)),
                if (_canRename && !_editing)
                  Semantics(
                    button: true,
                    label: context.l10n.mapRouteRenameSnapStop,
                    child: SizedBox(
                      width: MapRoutePlanningChrome._actionWidth,
                      height: MapRoutePlanningChrome._rowHeight,
                      child: IconButton(
                        tooltip: context.l10n.mapRouteRenameSnapStop,
                        onPressed: _startEditing,
                        icon: Icon(
                          Icons.edit_outlined,
                          size: 18,
                          color: scheme.onSurfaceVariant,
                        ),
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  )
                else
                  const SizedBox(width: MapRoutePlanningChrome._actionWidth),
                ReorderableDragStartListener(
                  index: widget.dragIndex,
                  child: Semantics(
                    button: true,
                    label: widget.reorderHint,
                    child: const SizedBox(
                      width: MapRoutePlanningChrome._actionWidth,
                      height: MapRoutePlanningChrome._rowHeight,
                      child: Icon(Icons.drag_handle, size: 18),
                    ),
                  ),
                ),
                if (widget.onRemove != null)
                  Semantics(
                    button: true,
                    label: widget.removeSemanticsLabel,
                    child: SizedBox(
                      width: MapRoutePlanningChrome._actionWidth,
                      height: MapRoutePlanningChrome._rowHeight,
                      child: IconButton(
                        tooltip: MaterialLocalizations.of(
                          context,
                        ).deleteButtonTooltip,
                        onPressed: widget.onRemove,
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
          if (widget.showConnectorBelow)
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
    required this.isSnap,
  });

  final int index;
  final int totalStops;
  final bool isSnap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (isSnap) {
      return Icon(
        Icons.place_outlined,
        size: 16,
        color: scheme.tertiary,
      );
    }
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

class _ChooseOnMapRow extends StatelessWidget {
  const _ChooseOnMapRow({
    required this.label,
    required this.semanticsHint,
    required this.onTap,
  });

  final String label;
  final String semanticsHint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      label: label,
      hint: semanticsHint,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: MapRoutePlanningChrome._rowHeight,
          child: Row(
            children: [
              SizedBox(
                width: MapRoutePlanningChrome._timelineWidth,
                child: Icon(
                  Icons.map_outlined,
                  size: 16,
                  color: scheme.primary,
                ),
              ),
              const SizedBox(width: Spacing.xs),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: scheme.primary,
                  ),
                ),
              ),
              const SizedBox(width: MapRoutePlanningChrome._actionWidth * 3),
            ],
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
          const SizedBox(width: MapRoutePlanningChrome._actionWidth * 3),
        ],
      ),
    );
  }
}
