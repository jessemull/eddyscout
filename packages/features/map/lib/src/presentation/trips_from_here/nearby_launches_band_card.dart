import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_design_system/eddyscout_design_system.dart';
import 'package:eddyscout_hydro_routing/eddyscout_hydro_routing.dart';
import 'package:eddyscout_localization/eddyscout_localization.dart';
import 'package:flutter/material.dart';

import 'nearby_launch_row.dart';
import 'trips_from_here_l10n.dart';

/// One exclusive reachability band subsection in trips-from-here UI.
class NearbyLaunchesBandCard extends StatefulWidget {
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

  static const compactMaxRows = 3;

  @override
  State<NearbyLaunchesBandCard> createState() => _NearbyLaunchesBandCardState();
}

class _NearbyLaunchesBandCardState extends State<NearbyLaunchesBandCard> {
  var _expanded = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final bandLabel = reachabilityBandLabel(l10n, widget.band);
    final truncated =
        widget.compact &&
        !_expanded &&
        widget.launches.length > NearbyLaunchesBandCard.compactMaxRows;
    final hiddenCount = truncated
        ? widget.launches.length - NearbyLaunchesBandCard.compactMaxRows
        : 0;
    final visibleLaunches = truncated
        ? widget.launches
              .take(NearbyLaunchesBandCard.compactMaxRows)
              .toList(growable: false)
        : widget.launches;

    return Semantics(
      header: true,
      label: reachabilityBandSemanticsLabel(
        l10n,
        widget.band,
        widget.launches.length,
      ),
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
              if (widget.launches.isEmpty)
                Semantics(
                  label: reachabilityBandEmptyMessage(l10n, widget.band),
                  child: Text(
                    reachabilityBandEmptyMessage(l10n, widget.band),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                )
              else ...[
                for (var i = 0; i < visibleLaunches.length; i++) ...[
                  if (i > 0) const Divider(height: 1),
                  NearbyLaunchRow(
                    launch: visibleLaunches[i],
                    onTap: () => widget.onPlanToLaunch(visibleLaunches[i]),
                  ),
                ],
                if (hiddenCount > 0)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () => setState(() => _expanded = true),
                      child: Text(l10n.tripsFromHereBandShowMore(hiddenCount)),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
