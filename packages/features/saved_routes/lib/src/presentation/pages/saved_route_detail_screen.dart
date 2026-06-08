import 'dart:async' show unawaited;

import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_design_system/eddyscout_design_system.dart';
import 'package:eddyscout_localization/eddyscout_localization.dart';
import 'package:eddyscout_saved_routes/src/presentation/pages/saved_route_detail_actions.dart';
import 'package:eddyscout_saved_routes/src/presentation/pages/saved_route_detail_form_helpers.dart';
import 'package:eddyscout_saved_routes/src/presentation/pages/saved_route_detail_metadata_form.dart';
import 'package:eddyscout_saved_routes/src/presentation/pages/saved_route_detail_tags_section.dart';
import 'package:eddyscout_saved_routes/src/presentation/pages/saved_route_detail_waypoints_section.dart';
import 'package:eddyscout_saved_routes/src/presentation/providers/saved_routes_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    _selectedCategories = savedRouteCategoriesFromNames(
      route.metadata.categories,
    );
    _customTags = savedRouteCustomTagsFromNames(route.metadata.categories);
    _customTagController.clear();
    _isFavorite = route.isFavorite;
    _dirty = false;
  }

  void _scheduleBindFromRoute(SavedRoute route) {
    if (_dirty || _boundRouteId == route.id) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _dirty || _boundRouteId == route.id) {
        return;
      }
      setState(() {
        _bindFromRoute(route);
        _boundRouteId = route.id;
      });
    });
  }

  SavedRoute _buildUpdated(SavedRoute existing) => buildSavedRouteDetailUpdate(
    existing: existing,
    nameController: _nameController,
    descriptionController: _descriptionController,
    notesController: _notesController,
    durationController: _durationController,
    waypoints: _waypoints,
    difficulty: _difficulty,
    skillLevel: _skillLevel,
    selectedCategories: _selectedCategories,
    customTags: _customTags,
    isFavorite: _isFavorite,
  );

  void _addCustomTag() {
    final tag = _customTagController.text.trim();
    if (tag.isEmpty ||
        savedRouteCategoryNames.contains(tag) ||
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

  Future<void> _toggleFavorite(SavedRoute route) async {
    final l10n = context.l10n;
    final nextFavorite = !_isFavorite;
    final result = await ref
        .read(savedRoutesControllerProvider.notifier)
        .toggleFavorite(route.id, isFavorite: nextFavorite);
    if (!mounted) {
      return;
    }
    result.when(
      success: (updated) => setState(() => _isFavorite = updated.isFavorite),
      failure: (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.savedRoutesFavoriteError)),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
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

        _scheduleBindFromRoute(route);

        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.savedRoutesDetailTitle),
            actions: [
              IconButton(
                tooltip: _isFavorite
                    ? l10n.savedRoutesUnfavoriteTooltip
                    : l10n.savedRoutesFavoriteTooltip,
                icon: Icon(_isFavorite ? Icons.star : Icons.star_border),
                onPressed: () => unawaited(_toggleFavorite(route)),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(Spacing.md),
            children: [
              SavedRouteDetailMetadataForm(
                nameController: _nameController,
                descriptionController: _descriptionController,
                notesController: _notesController,
                durationController: _durationController,
                difficulty: _difficulty,
                skillLevel: _skillLevel,
                onFieldChanged: () => _dirty = true,
                onDifficultyChanged: (value) => setState(() {
                  _difficulty = value;
                  _dirty = true;
                }),
                onSkillChanged: (value) => setState(() {
                  _skillLevel = value;
                  _dirty = true;
                }),
              ),
              const SizedBox(height: Spacing.md),
              SavedRouteDetailTagsSection(
                selectedCategories: _selectedCategories,
                customTags: _customTags,
                customTagController: _customTagController,
                onCategorySelected: (category, {required selected}) {
                  setState(() {
                    if (selected) {
                      _selectedCategories.add(category);
                    } else {
                      _selectedCategories.remove(category);
                    }
                    _dirty = true;
                  });
                },
                onCustomTagDeleted: (tag) => setState(() {
                  _customTags.remove(tag);
                  _dirty = true;
                }),
                onAddCustomTag: _addCustomTag,
              ),
              const SizedBox(height: Spacing.lg),
              SavedRouteDetailWaypointsSection(
                waypoints: _waypoints,
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
                onDeleteWaypoint: (index) {
                  setState(() {
                    _waypoints.removeAt(index);
                    _dirty = true;
                  });
                },
              ),
              const SizedBox(height: Spacing.lg),
              FilledButton(
                onPressed: () => unawaited(
                  SavedRouteDetailActions.save(
                    context: context,
                    ref: ref,
                    existing: route,
                    updated: _buildUpdated(route),
                    name: _nameController.text.trim(),
                    onSaved: () => setState(() => _dirty = false),
                  ),
                ),
                child: Text(l10n.savedRoutesSaveButton),
              ),
              const SizedBox(height: Spacing.sm),
              OutlinedButton(
                onPressed: () => widget.onLoadOnMap(_buildUpdated(route)),
                child: Text(l10n.savedRoutesLoadOnMapButton),
              ),
              const SizedBox(height: Spacing.sm),
              TextButton(
                onPressed: () => unawaited(
                  SavedRouteDetailActions.confirmDelete(
                    context: context,
                    ref: ref,
                    route: route,
                  ),
                ),
                child: Text(l10n.savedRoutesDeleteButton),
              ),
            ],
          ),
        );
      },
    );
  }
}
