import 'package:eddyscout_design_system/eddyscout_design_system.dart';
import 'package:eddyscout_localization/eddyscout_localization.dart';
import 'package:flutter/material.dart';

/// Read-only distance summary for saved route detail.
class SavedRouteDetailDistanceSection extends StatelessWidget {
  /// Creates the distance summary when [distanceLabel] is available.
  const SavedRouteDetailDistanceSection({
    required this.distanceLabel,
    super.key,
  });

  /// Pre-formatted distance including units.
  final String distanceLabel;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.savedRoutesDistanceLabel,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: Spacing.xs),
        Text(
          distanceLabel,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ],
    );
  }
}
