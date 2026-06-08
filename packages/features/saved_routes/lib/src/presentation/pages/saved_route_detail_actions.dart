import 'dart:async' show unawaited;

import 'package:eddyscout_analytics/eddyscout_analytics.dart';
import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_localization/eddyscout_localization.dart';
import 'package:eddyscout_saved_routes/src/presentation/providers/saved_routes_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Save and delete flows for the saved route detail screen.
abstract final class SavedRouteDetailActions {
  /// Persists edited route fields after validating the name.
  static Future<void> save({
    required BuildContext context,
    required WidgetRef ref,
    required SavedRoute existing,
    required SavedRoute updated,
    required String name,
    required VoidCallback onSaved,
  }) async {
    final l10n = context.l10n;
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.savedRoutesNameRequired)),
      );
      return;
    }
    final result = await ref
        .read(savedRoutesControllerProvider.notifier)
        .update(updated);
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
                  name: AnalyticsEvents.savedRouteUpdateSuccess,
                ),
              ),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.savedRoutesSaveSuccess)),
        );
        onSaved();
      },
      failure: (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.savedRoutesSaveError)),
        );
      },
    );
  }

  /// Prompts for confirmation and deletes the route.
  static Future<void> confirmDelete({
    required BuildContext context,
    required WidgetRef ref,
    required SavedRoute route,
  }) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.savedRoutesDeleteConfirmTitle),
        content: Text(l10n.savedRoutesDeleteConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.savedRoutesDeleteButton),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) {
      return;
    }
    final result = await ref
        .read(savedRoutesControllerProvider.notifier)
        .delete(route.id);
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
                  name: AnalyticsEvents.savedRouteDeleteSuccess,
                ),
              ),
        );
        unawaited(Navigator.of(context).maybePop());
      },
      failure: (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.savedRoutesDeleteError)),
        );
      },
    );
  }
}
