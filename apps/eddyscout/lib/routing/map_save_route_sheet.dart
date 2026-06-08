import 'dart:async' show unawaited;

import 'package:eddyscout_analytics/eddyscout_analytics.dart';
import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_design_system/eddyscout_design_system.dart';
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
  final capture = RoutePlanningSaveCapture.fromState(planning);
  final planningNotifier = ref.read(routePlanningProvider.notifier);

  final suggestedName = suggestedSavedRouteName(capture.waypoints) ?? '';
  final nameController = TextEditingController(text: suggestedName);
  final notesController = TextEditingController();

  try {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: Spacing.md,
          right: Spacing.md,
          top: Spacing.md,
          bottom: MediaQuery.viewInsetsOf(ctx).bottom + Spacing.md,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.savedRoutesSaveDialogTitle,
              style: Theme.of(ctx).textTheme.titleMedium,
            ),
            const SizedBox(height: Spacing.md - Spacing.xs),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: l10n.savedRoutesNameLabel,
              ),
              autofocus: true,
            ),
            const SizedBox(height: Spacing.sm),
            TextField(
              controller: notesController,
              decoration: InputDecoration(
                labelText: l10n.savedRoutesNotesLabel,
              ),
              maxLines: 2,
            ),
            const SizedBox(height: Spacing.md),
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

    final draft = planningNotifier.snapshotForSaveFromCapture(
      capture,
      name: name,
      notes: notes.isEmpty ? null : notes,
    );
    if (draft == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.savedRoutesSaveError)),
      );
      return;
    }

    final Result<SavedRoute, AppFailure> result;
    try {
      result = await ref
          .read(savedRoutesControllerProvider.notifier)
          .create(draft);
    } on Object {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.savedRoutesSaveError)),
      );
      return;
    }
    if (!context.mounted) {
      return;
    }
    result.when(
      success: (_) {
        _restorePlanningAfterSave(ref, capture);
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

/// Keeps the map plan visible after save when async work cleared planning.
void _restorePlanningAfterSave(
  WidgetRef ref,
  RoutePlanningSaveCapture capture,
) {
  ref.read(routePlanningProvider.notifier).restoreCapture(capture);
  final polyline = capture.geometry.polylineLonLat;
  if (polyline.length >= 2) {
    unawaited(
      ref
          .read(mapboxMapControllerProvider.notifier)
          .displayPlannedRoute(polyline),
    );
  }
}

/// Loads a pending saved route onto the map when the map tab mounts.
Future<void> handlePendingSavedRouteLoad(
  BuildContext context,
  WidgetRef ref,
) async {
  final l10n = context.l10n;
  final draft = ref.read(pendingSavedRouteLoadProvider.notifier).take();
  if (draft == null) {
    return;
  }

  final routeId = draft.id;
  try {
    final result = await ref
        .read(savedRouteRepositoryProvider)
        .getById(routeId);
    final persisted = result.when(
      success: (value) => value,
      failure: (failure) => throw failure,
    );
    ref.invalidate(savedRouteByIdProvider(routeId));
    if (persisted == null) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.savedRoutesNotFound)),
      );
      return;
    }
  } on Object {
    ref.invalidate(savedRouteByIdProvider(routeId));
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.savedRoutesDetailError)),
    );
    return;
  }

  final route = draft;
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

  final polyline = route.geometrySnapshot?.polylineLonLat;
  final mapController = ref.read(mapboxMapControllerProvider.notifier);
  if (polyline != null && polyline.length >= 2) {
    await mapController.displayPlannedRoute(polyline);
  } else {
    await mapController.rerunActiveRoute();
  }
}
