import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'nearby_trips_search_provider.dart';
import 'nearby_trips_search_view.dart';

/// Full-screen overlay for nearby trips search on the map.
class NearbyTripsSearchOverlay extends ConsumerWidget {
  /// Creates the overlay when [originLaunch] is non-null.
  const NearbyTripsSearchOverlay({
    required this.originLaunch,
    required this.onLaunchSelected,
    required this.onClose,
    super.key,
  });

  final LaunchPoint originLaunch;
  final ValueChanged<LaunchPoint> onLaunchSelected;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return NearbyTripsSearchView(
      originLaunch: originLaunch,
      onLaunchSelected: onLaunchSelected,
      onClose: () {
        ref.read(nearbyTripsSearchOriginProvider.notifier).close();
        onClose();
      },
    );
  }
}

/// Pushed route page for nearby trips search (e.g. launch detail).
class NearbyTripsSearchPage extends ConsumerWidget {
  /// Creates a full-screen search page for [originLaunch].
  const NearbyTripsSearchPage({
    required this.originLaunch,
    required this.onLaunchSelected,
    super.key,
  });

  final LaunchPoint originLaunch;
  final ValueChanged<LaunchPoint> onLaunchSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: NearbyTripsSearchView(
        originLaunch: originLaunch,
        onLaunchSelected: onLaunchSelected,
        onClose: () {
          ref.read(nearbyTripsSearchOriginProvider.notifier).close();
          Navigator.of(context).pop();
        },
      ),
    );
  }
}
