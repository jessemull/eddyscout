import 'dart:async' show unawaited;

import 'package:eddyscout_design_system/eddyscout_design_system.dart';
import 'package:eddyscout_localization/eddyscout_localization.dart';
import 'package:flutter/material.dart';

import 'map_constants.dart';
import 'mapbox/mapbox_map_controller.dart';

/// Zoom controls anchored to the bottom-left of the map.
class MapZoomControls extends StatelessWidget {
  const MapZoomControls({
    required this.controller,
    super.key,
  });

  final MapboxMapController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Semantics(
      container: true,
      label: l10n.mapZoomControlsSemantics,
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(10),
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: l10n.mapZoomInLabel,
              icon: const Icon(Icons.add),
              onPressed: () =>
                  unawaited(controller.nudgeZoomBy(kMapChromeZoomStep)),
            ),
            const Divider(height: 1),
            IconButton(
              tooltip: l10n.mapZoomOutLabel,
              icon: const Icon(Icons.remove),
              onPressed: () =>
                  unawaited(controller.nudgeZoomBy(-kMapChromeZoomStep)),
            ),
            const Divider(height: 1),
            IconButton(
              tooltip: l10n.mapShowAllLaunchesLabel,
              icon: const Icon(Icons.zoom_out_map),
              onPressed: () => unawaited(controller.fitRegionFromChrome()),
            ),
          ],
        ),
      ),
    );
  }
}

/// Locate-me control anchored to the bottom-right of the map.
class MapLocateControl extends StatelessWidget {
  const MapLocateControl({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(10),
      color: Theme.of(context).colorScheme.surfaceContainerHigh,
      child: IconButton(
        tooltip: l10n.mapLocateMeLabel,
        onPressed: () {},
        icon: const Icon(Icons.my_location),
      ),
    );
  }
}

/// Floating zoom and locate controls on the map canvas.
class MapFloatingControls extends StatelessWidget {
  const MapFloatingControls({
    required this.bottomPadding,
    required this.controller,
    required this.showZoomChrome,
    super.key,
  });

  final double bottomPadding;
  final MapboxMapController controller;
  final bool showZoomChrome;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (showZoomChrome)
          Positioned(
            left: Spacing.sm,
            bottom: bottomPadding,
            child: MapZoomControls(controller: controller),
          ),
        Positioned(
          right: Spacing.sm,
          bottom: bottomPadding,
          child: const MapLocateControl(),
        ),
      ],
    );
  }
}
