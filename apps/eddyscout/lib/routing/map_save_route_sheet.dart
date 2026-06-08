import 'dart:async' show unawaited;

import 'package:eddyscout_analytics/eddyscout_analytics.dart';
import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_localization/eddyscout_localization.dart';
import 'package:eddyscout_map/eddyscout_map.dart';
import 'package:eddyscout_saved_routes/eddyscout_saved_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Bottom sheet to name and save the current map plan locally.
Future<void> showMapSaveRouteSheet(BuildContext context, WidgetRef ref) async {
  final l10n = context.l10n;
  final planning = ref.read(routePlanningProvider);
  if (!planning.hasRunnableRoute || planning.activeGeometry == null) {
    return;
  }

  final nameController = TextEditingController();
  final notesController = TextEditingController();

  try {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.viewInsetsOf(ctx).bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.savedRoutesSaveDialogTitle,
              style: Theme.of(ctx).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: l10n.savedRoutesNameLabel,
              ),
              autofocus: true,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: notesController,
              decoration: InputDecoration(
                labelText: l10n.savedRoutesNotesLabel,
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l10n.savedRoutesSaveFromMapButton),
            ),
          ],
        ),
      ),
    );

    if (saved != true || !context.mounted) {
      return;
    }

    final name = nameController.text.trim();
    final notes = notesController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.savedRoutesNameRequired)),
      );
      return;
    }

    final draft = ref
        .read(routePlanningProvider.notifier)
        .snapshotForSave(
          name: name,
          notes: notes.isEmpty ? null : notes,
        );
    if (draft == null) {
      return;
    }

    final result = await ref
        .read(savedRoutesControllerProvider.notifier)
        .create(draft);
    if (!context.mounted) {
      return;
    }
    result.when(
      success: (_) {
        unawaited(
          ref
              .read(analyticsClientProvider)
              .logEvent(
                const AnalyticsEvent(
                  name: AnalyticsEvents.savedRouteCreateSuccess,
                ),
              ),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.savedRoutesSaveSuccess)),
        );
      },
      failure: (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.savedRoutesSaveError)),
        );
      },
    );
  } finally {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      nameController.dispose();
      notesController.dispose();
    });
  }
}

/// Loads a pending saved route onto the map when the map tab mounts.
Future<void> handlePendingSavedRouteLoad(
  BuildContext context,
  WidgetRef ref,
) async {
  final l10n = context.l10n;
  final routeId = ref.read(pendingSavedRouteLoadProvider.notifier).take();
  if (routeId == null) {
    return;
  }
  final route = await ref.read(savedRouteByIdProvider(routeId).future);
  if (route == null) {
    return;
  }
  final lookup = ref.read(launchPointLookupProvider);
  final launches = <LaunchPoint>[];
  final sorted = List<RouteWaypoint>.of(route.waypoints)
    ..sort((a, b) => a.order.compareTo(b.order));
  for (final wp in sorted) {
    final launch = lookup(wp.launchId);
    if (launch != null) {
      launches.add(launch);
    }
  }
  if (launches.length < 2) {
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.savedRoutesLoadOnMapInsufficientWaypoints)),
    );
    return;
  }
  ref.read(routePlanningProvider.notifier).loadFromSavedRoute(route, launches);
  await ref.read(mapboxMapControllerProvider.notifier).rerunActiveRoute();
}
