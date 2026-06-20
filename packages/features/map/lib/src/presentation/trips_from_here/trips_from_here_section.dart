import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_design_system/eddyscout_design_system.dart';
import 'package:eddyscout_hydro_routing/eddyscout_hydro_routing.dart';
import 'package:eddyscout_localization/eddyscout_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'nearby_launches_band_card.dart';
import 'nearby_launches_provider.dart';
import 'suggested_trips_section.dart';
import 'trips_from_here_loading_skeleton.dart';

/// Nearby launches and (v2) suggested trips from a source launch.
class TripsFromHereSection extends ConsumerWidget {
  /// Creates trips-from-here discovery UI for [originLaunch].
  const TripsFromHereSection({
    required this.originLaunch,
    required this.onPlanToLaunch,
    this.compact = false,
    super.key,
  });

  final LaunchPoint originLaunch;
  final void Function(LaunchPoint destination) onPlanToLaunch;
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final groupedAsync = ref.watch(
      nearbyLaunchesGroupedProvider(originLaunch.id),
    );
    final showSuggested = ref.watch(suggestedTripsIndexAvailableProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          header: true,
          child: Text(
            l10n.tripsFromHereSectionTitle,
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
        const SizedBox(height: Spacing.sm),
        groupedAsync.when(
          loading: () => const TripsFromHereLoadingSkeleton(),
          error: (_, _) => _TripsFromHereErrorBody(
            onRetry: () {
              ref
                ..invalidate(launchReachabilityIndexProvider)
                ..invalidate(nearbyLaunchesGroupedProvider(originLaunch.id));
            },
          ),
          data: (grouped) {
            if (_allBandsEmpty(grouped)) {
              return Semantics(
                label: l10n.tripsFromHereNoNearbyLaunches,
                child: Text(
                  l10n.tripsFromHereNoNearbyLaunches,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (
                  var i = 0;
                  i < kReachabilityBandsDisplayOrder.length;
                  i++
                ) ...[
                  if (i > 0) const SizedBox(height: Spacing.sm),
                  NearbyLaunchesBandCard(
                    band: kReachabilityBandsDisplayOrder[i],
                    launches:
                        grouped[kReachabilityBandsDisplayOrder[i]] ?? const [],
                    onPlanToLaunch: onPlanToLaunch,
                    compact: compact,
                  ),
                ],
              ],
            );
          },
        ),
        if (showSuggested) ...[
          const SizedBox(height: Spacing.md),
          SuggestedTripsSection(
            originLaunch: originLaunch,
            onPlanToLaunch: onPlanToLaunch,
          ),
        ],
      ],
    );
  }

  bool _allBandsEmpty(Map<ReachabilityBand, List<LaunchPoint>> grouped) {
    for (final band in kReachabilityBandsDisplayOrder) {
      if (grouped[band]?.isNotEmpty ?? false) {
        return false;
      }
    }
    return true;
  }
}

class _TripsFromHereErrorBody extends StatelessWidget {
  const _TripsFromHereErrorBody({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.tripsFromHereLoadError,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.error,
          ),
        ),
        const SizedBox(height: Spacing.sm),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            onPressed: onRetry,
            child: Text(l10n.commonRetry),
          ),
        ),
      ],
    );
  }
}
