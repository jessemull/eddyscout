import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_design_system/eddyscout_design_system.dart';
import 'package:eddyscout_localization/eddyscout_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'map_sheet_bottom_bar.dart';
import 'map_sheet_header_icon_button.dart';
import 'trips_from_here/nearby_launches_provider.dart';
import 'trips_from_here/suggested_trips_entry_tile.dart';
import 'trips_from_here/trips_from_here_l10n.dart';

/// Compact bottom card for a selected launch (Plan paddle / View conditions).
class MapPlacePeekBar extends ConsumerWidget {
  const MapPlacePeekBar({
    required this.launch,
    required this.onPlanPaddle,
    required this.onViewConditions,
    required this.onDismiss,
    required this.onOpenSuggestedTrips,
    super.key,
  });

  final LaunchPoint launch;
  final VoidCallback onPlanPaddle;
  final VoidCallback onViewConditions;
  final VoidCallback onDismiss;
  final VoidCallback onOpenSuggestedTrips;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final river = mapLaunchRiverLabel(l10n, launch.riverSystem);
    final groupedAsync = ref.watch(nearbyLaunchesGroupedProvider(launch.id));

    final middleSection = groupedAsync.maybeWhen(
      data: (grouped) {
        final count = grouped.values.fold<int>(
          0,
          (sum, launches) => sum + launches.length,
        );
        if (count == 0) {
          return null;
        }
        return SuggestedTripsEntryRow(
          key: const Key('suggested_trips_entry_tile'),
          title: l10n.tripsFromHereSuggestedTitle,
          subtitle: l10n.tripsFromHereSuggestedEntrySubtitle(count),
          onTap: onOpenSuggestedTrips,
        );
      },
      orElse: () => null,
    );

    return MapSheetBottomBarShell(
      header: Stack(
        clipBehavior: Clip.none,
        children: [
          MapSheetHeaderTextBlock(
            title: launch.name,
            subtitle:
                '$river${l10n.commonDotSeparator}${launch.windExposure.label}',
            rightInset: MapSheetHeaderIconButton.closeSlotWidth,
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
      middleSection: middleSection,
      actions: Row(
        children: [
          Expanded(
            child: FilledButton(
              onPressed: onPlanPaddle,
              child: Text(l10n.mapPlanPaddleButton),
            ),
          ),
          const SizedBox(width: Spacing.sm),
          Expanded(
            child: OutlinedButton(
              onPressed: onViewConditions,
              child: Text(l10n.mapViewConditionsButton),
            ),
          ),
        ],
      ),
    );
  }
}
