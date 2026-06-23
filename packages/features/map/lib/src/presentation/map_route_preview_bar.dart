import 'package:eddyscout_design_system/eddyscout_design_system.dart';
import 'package:eddyscout_localization/eddyscout_localization.dart';
import 'package:eddyscout_persistence/eddyscout_persistence.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'map_sheet_bottom_bar.dart';
import 'map_sheet_header_icon_button.dart';

/// Bottom preview bar after Done — trip time and actions.
class MapRoutePreviewBar extends ConsumerWidget {
  const MapRoutePreviewBar({
    required this.tripTimeLabel,
    required this.routeLengthKm,
    required this.canSave,
    required this.onBack,
    required this.onDismiss,
    required this.onStart,
    required this.onSave,
    this.goNoGoSection,
    super.key,
  });

  final String? tripTimeLabel;
  final double? routeLengthKm;
  final bool canSave;
  final VoidCallback onBack;
  final VoidCallback onDismiss;
  final VoidCallback onStart;
  final VoidCallback onSave;

  /// Optional route go/no-go rollup (injected from app shell).
  final Widget? goNoGoSection;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final backTooltip = MaterialLocalizations.of(context).backButtonTooltip;
    final displayUnits = ref.watch(effectiveDisplayUnitSystemProvider);
    final routeLengthLabel = routeLengthKm == null
        ? null
        : l10n.mapPlanningRouteLength(
            localizedDistanceFromKm(l10n, routeLengthKm, displayUnits)!,
          );

    return MapSheetBottomBarShell(
      header: Stack(
        clipBehavior: Clip.none,
        children: [
          if (tripTimeLabel case final time?)
            MapSheetHeaderTextBlock(
              title: time,
              subtitle: routeLengthLabel,
              leftInset: MapSheetHeaderIconButton.compactSlotWidth,
              rightInset: MapSheetHeaderIconButton.closeSlotWidth,
            ),
          Positioned(
            top: 0,
            bottom: 0,
            left: 0,
            child: Align(
              alignment: Alignment.centerLeft,
              child: MapSheetHeaderIconButton(
                icon: Icons.arrow_back,
                tooltip: backTooltip,
                alignment: Alignment.centerLeft,
                onPressed: onBack,
                compact: true,
                contentSized: true,
              ),
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: MapSheetHeaderIconButton(
              icon: Icons.close,
              tooltip: l10n.mapCloseSheetLabel,
              alignment: Alignment.topRight,
              onPressed: onDismiss,
              contentSized: true,
            ),
          ),
        ],
      ),
      middleSection: goNoGoSection,
      actions: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: onStart,
              child: Text(l10n.mapRoutePreviewStart),
            ),
          ),
          const SizedBox(width: Spacing.sm),
          Expanded(
            child: FilledButton(
              onPressed: canSave ? onSave : null,
              child: Text(l10n.mapPlanningSaveLabel),
            ),
          ),
        ],
      ),
    );
  }
}
