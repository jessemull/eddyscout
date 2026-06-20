import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_design_system/eddyscout_design_system.dart';
import 'package:eddyscout_hydro_routing/eddyscout_hydro_routing.dart';
import 'package:eddyscout_localization/eddyscout_localization.dart';
import 'package:eddyscout_map/src/presentation/trips_from_here/nearby_launch_row.dart';
import 'package:eddyscout_map/src/presentation/trips_from_here/trips_from_here_l10n.dart';
import 'package:flutter/material.dart';

/// One exclusive reachability band subsection in trips-from-here UI.
class NearbyLaunchesBandCard extends StatelessWidget {
  /// Creates a band card for [band] with [launches].
  const NearbyLaunchesBandCard({
    required this.band,
    required this.launches,
    required this.onPlanToLaunch,
    this.compact = false,
    super.key,
  });

  final ReachabilityBand band;
  final List<LaunchPoint> launches;
  final void Function(LaunchPoint destination) onPlanToLaunch;
  final bool compact;

  static const _compactMaxRows = 3;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final bandLabel = reachabilityBandLabel(l10n, band);
    final visibleLaunches = compact && launches.length > _compactMaxRows
        ? launches.take(_compactMaxRows).toList(growable: false)
        : launches;

    return Semantics(
      header: true,
      label: reachabilityBandSemanticsLabel(l10n, band, launches.length),
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            Spacing.md,
            Spacing.sm,
            Spacing.md,
            Spacing.sm,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                bandLabel,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: Spacing.xs),
              if (launches.isEmpty)
                Semantics(
                  label: reachabilityBandEmptyMessage(l10n, band),
                  child: Text(
                    reachabilityBandEmptyMessage(l10n, band),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                )
              else
                for (var i = 0; i < visibleLaunches.length; i++) ...[
                  if (i > 0) const Divider(height: 1),
                  NearbyLaunchRow(
                    launch: visibleLaunches[i],
                    onTap: () => onPlanToLaunch(visibleLaunches[i]),
                  ),
                ],
            ],
          ),
        ),
      ),
    );
  }
}
