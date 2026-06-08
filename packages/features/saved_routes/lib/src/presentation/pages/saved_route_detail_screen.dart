import 'dart:async' show unawaited;

import 'package:eddyscout_analytics/eddyscout_analytics.dart';
import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_design_system/eddyscout_design_system.dart';
import 'package:eddyscout_localization/eddyscout_localization.dart';
import 'package:eddyscout_saved_routes/src/presentation/providers/saved_routes_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final Set<String> _routeCategoryNames = {
  for (final category in RouteCategory.values) category.name,
};

/// Detail and edit screen for a single saved route.
class SavedRouteDetailScreen extends ConsumerStatefulWidget {
  /// Creates the detail screen for [routeId].
  const SavedRouteDetailScreen({
    required this.routeId,
    required this.onLoadOnMap,
    super.key,
  });

  /// Saved route id to load and edit.
  final String routeId;

  /// Loads this route onto the map tab.
  final void Function(SavedRoute route) onLoadOnMap;

  @override
  ConsumerState<SavedRouteDetailScreen> createState() =>
      _SavedRouteDetailScreenState();
}

class _SavedRouteDetailScreenState
    extends ConsumerState<SavedRouteDetailScreen> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _notesController = TextEditingController();
  final _durationController = TextEditingController();
  final _customTagController = TextEditingController();
  var _dirty = false;
  String? _boundRouteId;
  List<RouteWaypoint> _waypoints = [];
  RouteDifficulty? _difficulty;
  RecommendedSkillLevel? _skillLevel;
  Set<RouteCategory> _selectedCategories = {};
  List<String> _customTags = [];
  var _isFavorite = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _notesController.dispose();
    _durationController.dispose();
    _customTagController.dispose();
    super.dispose();
  }

  void _bindFromRoute(SavedRoute route) {
    _nameController.text = route.name;
    _descriptionController.text = route.description ?? '';
    _notesController.text = route.notes;
    _durationController.text =
        route.metadata.estimatedDurationMinutes?.toString() ?? '';
    _waypoints = List.of(route.waypoints)
      ..sort((a, b) => a.order.compareTo(b.order));
    _difficulty = route.metadata.difficulty;
    _skillLevel = route.metadata.recommendedSkillLevel;
    _selectedCategories = _categoriesFromNames(route.metadata.categories);
    _customTags = _customTagsFromNames(route.metadata.categories);
    _customTagController.clear();
    _isFavorite = route.isFavorite;
    _dirty = false;
  }

  Set<RouteCategory> _categoriesFromNames(List<String> names) => {
    for (final category in RouteCategory.values)
      if (names.contains(category.name)) category,
  };

  List<String> _customTagsFromNames(List<String> names) =>
      names.where((name) => !_routeCategoryNames.contains(name)).toList();

  List<String> _allCategoryNames() => [
    ..._selectedCategories.map((category) => category.name),
    ..._customTags,
  ];

  void _addCustomTag() {
    final tag = _customTagController.text.trim();
    if (tag.isEmpty ||
        _routeCategoryNames.contains(tag) ||
        _customTags.contains(tag)) {
      _customTagController.clear();
      return;
    }
    setState(() {
      _customTags.add(tag);
      _customTagController.clear();
      _dirty = true;
    });
  }

  SavedRoute _buildUpdated(SavedRoute existing) {
    final durationRaw = int.tryParse(_durationController.text.trim());
    return existing.copyWith(
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      notes: _notesController.text.trim(),
      isFavorite: _isFavorite,
      waypoints: [
        for (var i = 0; i < _waypoints.length; i++)
          _waypoints[i].copyWith(order: i),
      ],
      metadata: existing.metadata.copyWith(
        difficulty: _difficulty,
        recommendedSkillLevel: _skillLevel,
        estimatedDurationMinutes: durationRaw,
        categories: _allCategoryNames(),
      ),
      updatedAt: DateTime.now(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    ref.listen(savedRouteByIdProvider(widget.routeId), (previous, next) {
      next.whenData((route) {
        if (route == null || _dirty) {
          return;
        }
        if (_boundRouteId != route.id) {
          _bindFromRoute(route);
          _boundRouteId = route.id;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {});
            }
          });
        }
      });
    });

    final routeAsync = ref.watch(savedRouteByIdProvider(widget.routeId));

    return routeAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: Text(l10n.savedRoutesDetailTitle)),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(title: Text(l10n.savedRoutesDetailTitle)),
        body: Center(child: Text(l10n.savedRoutesDetailError)),
      ),
      data: (route) {
        if (route == null) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.savedRoutesDetailTitle)),
            body: Center(child: Text(l10n.savedRoutesNotFound)),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.savedRoutesDetailTitle),
            actions: [
              IconButton(
                tooltip: _isFavorite
                    ? l10n.savedRoutesUnfavoriteTooltip
                    : l10n.savedRoutesFavoriteTooltip,
                icon: Icon(_isFavorite ? Icons.star : Icons.star_border),
                onPressed: () => setState(() => _isFavorite = !_isFavorite),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(Spacing.md),
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: l10n.savedRoutesNameLabel,
                ),
                onChanged: (_) => _dirty = true,
              ),
              const SizedBox(height: Spacing.sm),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: l10n.savedRoutesDescriptionLabel,
                ),
                onChanged: (_) => _dirty = true,
              ),
              const SizedBox(height: Spacing.sm),
              TextField(
                controller: _notesController,
                decoration: InputDecoration(
                  labelText: l10n.savedRoutesNotesLabel,
                ),
                maxLines: 3,
                onChanged: (_) => _dirty = true,
              ),
              const SizedBox(height: Spacing.sm),
              TextField(
                controller: _durationController,
                decoration: InputDecoration(
                  labelText: l10n.savedRoutesDurationLabel,
                  helperText: l10n.savedRoutesDurationHint,
                ),
                keyboardType: TextInputType.number,
                onChanged: (_) => _dirty = true,
              ),
              const SizedBox(height: Spacing.md),
              DropdownButtonFormField<RouteDifficulty?>(
                initialValue: _difficulty,
                decoration: InputDecoration(
                  labelText: l10n.savedRoutesDifficultyLabel,
                ),
                items: [
                  DropdownMenuItem(
                    child: Text(l10n.savedRoutesDifficultyNone),
                  ),
                  ...RouteDifficulty.values.map(
                    (d) => DropdownMenuItem(
                      value: d,
                      child: Text(_difficultyLabel(l10n, d)),
                    ),
                  ),
                ],
                onChanged: (value) => setState(() {
                  _difficulty = value;
                  _dirty = true;
                }),
              ),
              const SizedBox(height: Spacing.sm),
              DropdownButtonFormField<RecommendedSkillLevel?>(
                initialValue: _skillLevel,
                decoration: InputDecoration(
                  labelText: l10n.savedRoutesSkillLabel,
                ),
                items: [
                  DropdownMenuItem(child: Text(l10n.savedRoutesSkillNone)),
                  ...RecommendedSkillLevel.values.map(
                    (s) => DropdownMenuItem(
                      value: s,
                      child: Text(_skillLabel(l10n, s)),
                    ),
                  ),
                ],
                onChanged: (value) => setState(() {
                  _skillLevel = value;
                  _dirty = true;
                }),
              ),
              const SizedBox(height: Spacing.md),
              Text(
                l10n.savedRoutesCategoriesLabel,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: Spacing.sm),
              Wrap(
                spacing: Spacing.sm,
                runSpacing: Spacing.sm,
                children: RouteCategory.values.map((category) {
                  final selected = _selectedCategories.contains(category);
                  return FilterChip(
                    label: Text(_categoryLabel(l10n, category)),
                    selected: selected,
                    onSelected: (value) => setState(() {
                      if (value) {
                        _selectedCategories.add(category);
                      } else {
                        _selectedCategories.remove(category);
                      }
                      _dirty = true;
                    }),
                  );
                }).toList(),
              ),
              const SizedBox(height: Spacing.md),
              Text(
                l10n.savedRoutesCustomTagsLabel,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: Spacing.sm),
              if (_customTags.isNotEmpty)
                Wrap(
                  spacing: Spacing.sm,
                  runSpacing: Spacing.sm,
                  children: _customTags.map((tag) {
                    return InputChip(
                      label: Text(tag),
                      onDeleted: () => setState(() {
                        _customTags.remove(tag);
                        _dirty = true;
                      }),
                    );
                  }).toList(),
                ),
              if (_customTags.isNotEmpty) const SizedBox(height: Spacing.sm),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextField(
                      key: const Key('saved_route_custom_tag_field'),
                      controller: _customTagController,
                      decoration: InputDecoration(
                        labelText: l10n.savedRoutesCustomTagHint,
                      ),
                      onSubmitted: (_) => _addCustomTag(),
                    ),
                  ),
                  IconButton(
                    tooltip: l10n.savedRoutesCustomTagAdd,
                    icon: const Icon(Icons.add),
                    onPressed: _addCustomTag,
                  ),
                ],
              ),
              const SizedBox(height: Spacing.lg),
              Text(
                l10n.savedRoutesWaypointsTitle,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: Spacing.sm),
              ReorderableListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _waypoints.length,
                // ignore: deprecated_member_use — onReorderItem not in stable API yet
                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    var targetIndex = newIndex;
                    if (targetIndex > oldIndex) {
                      targetIndex -= 1;
                    }
                    final item = _waypoints.removeAt(oldIndex);
                    _waypoints.insert(targetIndex, item);
                    _dirty = true;
                  });
                },
                itemBuilder: (context, index) {
                  final wp = _waypoints[index];
                  final launch = ref.read(launchPointLookupProvider)(
                    wp.launchId,
                  );
                  final label = launch?.name ?? l10n.savedRoutesUnknownLaunch;
                  return ListTile(
                    key: ValueKey('${wp.launchId}_$index'),
                    title: Text('${index + 1}. $label'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: _waypoints.length <= 2
                          ? null
                          : () {
                              setState(() {
                                _waypoints.removeAt(index);
                                _dirty = true;
                              });
                            },
                    ),
                  );
                },
              ),
              const SizedBox(height: Spacing.lg),
              FilledButton(
                onPressed: () => _save(context, route),
                child: Text(l10n.savedRoutesSaveButton),
              ),
              const SizedBox(height: Spacing.sm),
              OutlinedButton(
                onPressed: () => widget.onLoadOnMap(_buildUpdated(route)),
                child: Text(l10n.savedRoutesLoadOnMapButton),
              ),
              const SizedBox(height: Spacing.sm),
              TextButton(
                onPressed: () => _confirmDelete(context, route),
                child: Text(l10n.savedRoutesDeleteButton),
              ),
            ],
          ),
        );
      },
    );
  }

  String _difficultyLabel(AppLocalizations l10n, RouteDifficulty d) =>
      switch (d) {
        RouteDifficulty.easy => l10n.savedRoutesDifficultyEasy,
        RouteDifficulty.moderate => l10n.savedRoutesDifficultyModerate,
        RouteDifficulty.hard => l10n.savedRoutesDifficultyHard,
        RouteDifficulty.expert => l10n.savedRoutesDifficultyExpert,
      };

  String _skillLabel(AppLocalizations l10n, RecommendedSkillLevel s) =>
      switch (s) {
        RecommendedSkillLevel.beginner => l10n.launchDetailSkillBeginner,
        RecommendedSkillLevel.intermediate =>
          l10n.launchDetailSkillIntermediate,
        RecommendedSkillLevel.advanced => l10n.launchDetailSkillAdvanced,
      };

  String _categoryLabel(AppLocalizations l10n, RouteCategory category) =>
      switch (category) {
        RouteCategory.scenic => l10n.savedRoutesCategoryScenic,
        RouteCategory.training => l10n.savedRoutesCategoryTraining,
        RouteCategory.commute => l10n.savedRoutesCategoryCommute,
        RouteCategory.overnight => l10n.savedRoutesCategoryOvernight,
      };

  Future<void> _save(BuildContext context, SavedRoute existing) async {
    final l10n = context.l10n;
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.savedRoutesNameRequired)),
      );
      return;
    }
    final updated = _buildUpdated(existing);
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
        _dirty = false;
      },
      failure: (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.savedRoutesSaveError)),
        );
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context, SavedRoute route) async {
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
