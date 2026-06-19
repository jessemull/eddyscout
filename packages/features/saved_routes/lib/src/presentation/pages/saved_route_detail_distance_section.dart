import 'package:eddyscout_design_system/eddyscout_design_system.dart';
import 'package:flutter/material.dart';

/// Read-only distance summary for a saved route.
class SavedRouteDetailDistanceSection extends StatelessWidget {
  /// Creates the distance section with a pre-formatted [distanceLabel].
  const SavedRouteDetailDistanceSection({
    required this.label,
    required this.distanceLabel,
    super.key,
  });

  /// Section heading (localized).
  final String label;

  /// Distance with unit (localized).
  final String distanceLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
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
