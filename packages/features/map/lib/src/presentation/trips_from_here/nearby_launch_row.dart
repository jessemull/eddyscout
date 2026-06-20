import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_localization/eddyscout_localization.dart';
import 'package:flutter/material.dart';

import 'trips_from_here_l10n.dart';

/// One tappable nearby launch row in trips-from-here lists.
class NearbyLaunchRow extends StatelessWidget {
  /// Creates a row for [launch] that invokes [onTap] when selected.
  const NearbyLaunchRow({
    required this.launch,
    required this.onTap,
    super.key,
  });

  final LaunchPoint launch;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final river = mapLaunchRiverLabel(l10n, launch.riverSystem);
    return Semantics(
      button: true,
      label: l10n.tripsFromHerePlanToLaunchSemantics(launch.name, river),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        visualDensity: VisualDensity.compact,
        title: Text(
          launch.name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          river,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: scheme.onSurfaceVariant,
        ),
        onTap: onTap,
      ),
    );
  }
}
