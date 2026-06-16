import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_design_system/eddyscout_design_system.dart';
import 'package:eddyscout_localization/eddyscout_localization.dart';
import 'package:eddyscout_persistence/eddyscout_persistence.dart';
import 'package:eddyscout_saved_routes/src/presentation/pages/saved_route_distance_label.dart';
import 'package:eddyscout_saved_routes/src/presentation/providers/saved_routes_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Lists locally saved routes with favorites filter.
class SavedRoutesListScreen extends ConsumerStatefulWidget {
  /// Creates the saved routes list screen.
  const SavedRoutesListScreen({
    required this.onOpenRouteDetail,
    super.key,
  });

  /// Navigates to detail for the given route id.
  final void Function(String routeId) onOpenRouteDetail;

  @override
  ConsumerState<SavedRoutesListScreen> createState() =>
      _SavedRoutesListScreenState();
}

class _SavedRoutesListScreenState extends ConsumerState<SavedRoutesListScreen> {
  var _favoritesOnly = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final routesAsync = _favoritesOnly
        ? ref.watch(savedRoutesFavoritesProvider)
        : ref.watch(savedRoutesListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.savedRoutesListTitle),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(Spacing.md),
            child: SegmentedButton<bool>(
              segments: [
                ButtonSegment(
                  value: false,
                  label: Text(l10n.savedRoutesAllTab),
                ),
                ButtonSegment(
                  value: true,
                  label: Text(l10n.savedRoutesFavoritesTab),
                ),
              ],
              selected: {_favoritesOnly},
              onSelectionChanged: (selection) {
                setState(() => _favoritesOnly = selection.first);
              },
            ),
          ),
          Expanded(
            child: routesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => _ErrorBody(
                message: l10n.savedRoutesListError,
                onRetry: () {
                  if (_favoritesOnly) {
                    ref.invalidate(savedRoutesFavoritesProvider);
                  } else {
                    ref.invalidate(savedRoutesListProvider);
                  }
                },
              ),
              data: (routes) {
                if (routes.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(Spacing.lg),
                      child: Text(
                        _favoritesOnly
                            ? l10n.savedRoutesFavoritesEmpty
                            : l10n.savedRoutesListEmpty,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  );
                }
                return ListView.separated(
                  itemCount: routes.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final route = routes[index];
                    return _SavedRouteListTile(
                      route: route,
                      onTap: () => widget.onOpenRouteDetail(route.id),
                      onToggleFavorite: () => _toggleFavorite(route),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleFavorite(SavedRoute route) async {
    final l10n = context.l10n;
    final result = await ref
        .read(savedRoutesControllerProvider.notifier)
        .toggleFavorite(route.id, isFavorite: !route.isFavorite);
    if (!mounted) {
      return;
    }
    result.when(
      success: (_) {},
      failure: (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.savedRoutesFavoriteError)),
        );
      },
    );
  }
}

class _SavedRouteListTile extends ConsumerWidget {
  const _SavedRouteListTile({
    required this.route,
    required this.onTap,
    required this.onToggleFavorite,
  });

  final SavedRoute route;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final units = ref.watch(effectiveDisplayUnitsProvider);
    final distanceLabel = formatSavedRouteDistanceLabel(
      l10n,
      route.metadata.distanceMeters,
      units,
    );
    final subtitleParts = <String>[
      ?distanceLabel,
      l10n.savedRoutesWaypointCount(route.waypoints.length),
    ];

    return ListTile(
      onTap: onTap,
      title: Text(route.name),
      subtitle: Text(subtitleParts.join(l10n.commonDotSeparator)),
      trailing: IconButton(
        tooltip: route.isFavorite
            ? l10n.savedRoutesUnfavoriteTooltip
            : l10n.savedRoutesFavoriteTooltip,
        icon: Icon(
          route.isFavorite ? Icons.star : Icons.star_border,
          color: route.isFavorite
              ? Theme.of(context).colorScheme.primary
              : null,
        ),
        onPressed: onToggleFavorite,
      ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: Spacing.md),
            FilledButton(
              onPressed: onRetry,
              child: Text(l10n.commonRetry),
            ),
          ],
        ),
      ),
    );
  }
}
