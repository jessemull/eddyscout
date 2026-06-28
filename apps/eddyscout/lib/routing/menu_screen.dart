import 'dart:async' show unawaited;

import 'package:eddyscout/routing/app_routes.dart';
import 'package:eddyscout/routing/app_shell.dart';
import 'package:eddyscout_conditions/eddyscout_conditions.dart';
import 'package:eddyscout_localization/eddyscout_localization.dart';
import 'package:eddyscout_map/eddyscout_map.dart';
import 'package:eddyscout_routing/eddyscout_routing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Menu tab for GPX tools and secondary settings.
class MenuScreen extends ConsumerStatefulWidget {
  const MenuScreen({super.key});

  @override
  ConsumerState<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends ConsumerState<MenuScreen> {
  var _gpxBusy = false;

  Future<void> _handleGpxExport() async {
    if (_gpxBusy) {
      return;
    }
    setState(() => _gpxBusy = true);
    try {
      final outcome = await ref.read(gpxActionsProvider.notifier).exportRoute();
      if (!mounted) {
        return;
      }
      _showGpxOutcome(
        outcome,
        successMessage: context.l10n.mapGpxExportSuccess,
      );
    } finally {
      if (mounted) {
        setState(() => _gpxBusy = false);
      }
    }
  }

  Future<void> _handleGpxImport() async {
    if (_gpxBusy) {
      return;
    }
    setState(() => _gpxBusy = true);
    try {
      final outcome = await ref.read(gpxActionsProvider.notifier).importRoute();
      if (!mounted) {
        return;
      }
      _showGpxOutcome(
        outcome,
        successMessage: context.l10n.mapGpxImportSuccess,
      );
      if (outcome is GpxActionSuccess) {
        ref
            .read(mapSheetVisibilityStateProvider.notifier)
            .showPlanningPreview();
        const MapRoute().go(context);
        StatefulNavigationShell.maybeOf(context)?.goBranch(
          AppShellBranches.map,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _gpxBusy = false);
      }
    }
  }

  void _showGpxOutcome(
    GpxActionOutcome outcome, {
    required String successMessage,
  }) {
    switch (outcome) {
      case GpxActionCancelled():
        return;
      case GpxActionSuccess():
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(successMessage)));
      case GpxActionFailure(:final failure):
        final localized = localizeGpxActionFailure(
          l10n: context.l10n,
          failure: failure,
        );
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(localized)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final planning = ref.watch(routePlanningProvider);
    final canExport =
        planning.polylineLonLat != null && planning.polylineLonLat!.length >= 2;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.menuScreenTitle)),
      body: ListTileTheme(
        data: ListTileTheme.of(context).copyWith(
          visualDensity: VisualDensity.compact,
          minVerticalPadding: 0,
        ),
        child: ListView(
          children: [
            ListTile(
              leading: const Icon(Icons.upload_file),
              title: Text(l10n.menuImportGpx),
              enabled: !_gpxBusy,
              onTap: _gpxBusy ? null : () => unawaited(_handleGpxImport()),
            ),
            ListTile(
              leading: const Icon(Icons.download),
              title: Text(l10n.menuExportGpx),
              enabled: canExport && !_gpxBusy,
              onTap: canExport && !_gpxBusy
                  ? () => unawaited(_handleGpxExport())
                  : null,
            ),
            const _ModeratorMenuEntry(),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: Text(l10n.menuSettings),
              onTap: () => unawaited(const SettingsRoute().push<void>(context)),
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: Text(l10n.menuAbout),
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: l10n.appTitle,
                  applicationLegalese: l10n.menuAboutBody,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Moderator-only menu row for the global condition-report review queue.
class _ModeratorMenuEntry extends ConsumerWidget {
  const _ModeratorMenuEntry();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!firebaseCallablesAvailable) {
      return const SizedBox.shrink();
    }
    final accessAsync = ref.watch(moderatorAccessProvider);
    return accessAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (isModerator) {
        if (!isModerator) {
          return const SizedBox.shrink();
        }
        return ListTile(
          key: const Key('menu_moderator_review_queue'),
          leading: const Icon(Icons.rate_review_outlined),
          title: Text(context.l10n.moderationQueueTitle),
          onTap: () => context.push(RoutePaths.moderationReports),
        );
      },
    );
  }
}
