import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:flutter/material.dart';

/// Suggested trips list (v2 — hidden until suggested trips index lands).
class SuggestedTripsSection extends StatelessWidget {
  /// Creates the suggested trips subsection (disabled in v1).
  const SuggestedTripsSection({
    required this.originLaunch,
    required this.onPlanToLaunch,
    super.key,
  });

  final LaunchPoint originLaunch;
  final void Function(LaunchPoint destination) onPlanToLaunch;

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
