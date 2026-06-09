import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_design_system/eddyscout_design_system.dart';
import 'package:flutter/material.dart';

import 'map_place_bottom_sheet.dart';
import 'map_route_planning_sheet.dart';
import 'map_sheet_provider.dart';

/// Draggable bottom sheet host for place peek and route planning.
class MapBottomSheetHost extends StatelessWidget {
  const MapBottomSheetHost({
    required this.visibility,
    required this.selectedLaunch,
    required this.waypoints,
    required this.routeLengthKm,
    required this.canSave,
    required this.onPlanPaddle,
    required this.onViewConditions,
    required this.onClose,
    required this.onClear,
    required this.onSave,
    required this.onAddStopHint,
    super.key,
  });

  final MapSheetVisibility visibility;
  final LaunchPoint? selectedLaunch;
  final List<LaunchPoint> waypoints;
  final double? routeLengthKm;
  final bool canSave;
  final VoidCallback onPlanPaddle;
  final VoidCallback onViewConditions;
  final VoidCallback onClose;
  final VoidCallback onClear;
  final VoidCallback onSave;
  final VoidCallback onAddStopHint;

  @override
  Widget build(BuildContext context) {
    if (visibility == MapSheetVisibility.hidden) {
      return const SizedBox.shrink();
    }

    final isPlanning = visibility == MapSheetVisibility.planningExpanded;
    final initialSize = isPlanning ? 0.45 : 0.32;
    final minSize = isPlanning ? 0.35 : 0.22;
    final maxSize = isPlanning ? 0.72 : 0.45;

    return Align(
      alignment: Alignment.bottomCenter,
      child: DraggableScrollableSheet(
        key: ValueKey<MapSheetVisibility>(visibility),
        initialChildSize: initialSize,
        minChildSize: minSize,
        maxChildSize: maxSize,
        builder: (context, scrollController) {
          return Material(
            elevation: 8,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            color: Theme.of(context).colorScheme.surfaceContainerLow,
            child: ListView(
              controller: scrollController,
              padding: EdgeInsets.zero,
              children: [
                if (isPlanning)
                  MapRoutePlanningSheet(
                    waypoints: waypoints,
                    routeLengthKm: routeLengthKm,
                    canSave: canSave,
                    onClose: onClose,
                    onClear: onClear,
                    onSave: onSave,
                    onAddStopHint: onAddStopHint,
                  )
                else if (selectedLaunch != null)
                  MapPlaceBottomSheet(
                    launch: selectedLaunch!,
                    onPlanPaddle: onPlanPaddle,
                    onViewConditions: onViewConditions,
                  )
                else
                  const SizedBox(height: Spacing.lg),
              ],
            ),
          );
        },
      ),
    );
  }
}
