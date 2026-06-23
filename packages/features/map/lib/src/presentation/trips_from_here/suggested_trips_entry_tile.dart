import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_localization/eddyscout_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../map_compact_search_result_row.dart';
import '../map_sheet_bottom_bar.dart';
import 'nearby_launches_provider.dart';

/// Entry row that opens nearby trips search for [originLaunch].
class SuggestedTripsEntryTile extends ConsumerWidget {
  /// Creates the suggested trips entry row.
  const SuggestedTripsEntryTile({
    required this.originLaunch,
    required this.onOpen,
    super.key,
  });

  final LaunchPoint originLaunch;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final groupedAsync = ref.watch(
      nearbyLaunchesGroupedProvider(originLaunch.id),
    );

    return groupedAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (grouped) {
        final count = grouped.values.fold<int>(
          0,
          (sum, launches) => sum + launches.length,
        );
        if (count == 0) {
          return const SizedBox.shrink();
        }

        return SuggestedTripsEntryRow(
          key: const Key('suggested_trips_entry_tile'),
          title: l10n.tripsFromHereSuggestedTitle,
          subtitle: l10n.tripsFromHereSuggestedEntrySubtitle(count),
          onTap: onOpen,
        );
      },
    );
  }
}

/// Compact suggested-trips row matching route go/no-go [ExpansionTile] layout.
class SuggestedTripsEntryRow extends StatelessWidget {
  /// Creates the row.
  const SuggestedTripsEntryRow({
    required this.title,
    required this.subtitle,
    required this.onTap,
    super.key,
  });

  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final titleStyle = Theme.of(context).textTheme.titleSmall!.copyWith(
      color: scheme.onSurface,
      fontWeight: FontWeight.w600,
      height: 1.15,
    );
    final subtitleStyle = Theme.of(context).textTheme.bodySmall!.copyWith(
      color: scheme.onSurfaceVariant,
      height: 1.2,
    );

    return MapSheetCompactMiddleRow(
      semanticsLabel: '$title. $subtitle',
      onTap: onTap,
      content: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: kMapCompactListLeadingColumnWidth,
                  child: Icon(
                    Icons.route_outlined,
                    size: kMapCompactListLeadingIconSize,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: kMapCompactListLeadingTextGap),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: titleStyle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        subtitle,
                        style: subtitleStyle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: scheme.onSurfaceVariant,
            size: kMapSheetMiddleRowCaretSize,
          ),
        ],
      ),
    );
  }
}
