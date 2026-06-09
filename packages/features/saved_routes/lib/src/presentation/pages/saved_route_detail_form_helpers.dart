import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_saved_routes/src/domain/saved_route_update_helpers.dart';
import 'package:flutter/material.dart';

/// Enum category names stored in route metadata.
final Set<String> savedRouteCategoryNames = {
  for (final category in RouteCategory.values) category.name,
};

/// Parses stored category names into [RouteCategory] values.
Set<RouteCategory> savedRouteCategoriesFromNames(List<String> names) => {
  for (final category in RouteCategory.values)
    if (names.contains(category.name)) category,
};

/// Returns custom tag strings from stored category names.
List<String> savedRouteCustomTagsFromNames(List<String> names) =>
    names.where((name) => !savedRouteCategoryNames.contains(name)).toList();

/// Merges enum categories and custom tags for persistence.
List<String> savedRouteAllCategoryNames({
  required Set<RouteCategory> selectedCategories,
  required List<String> customTags,
}) => [
  ...selectedCategories.map((category) => category.name),
  ...customTags,
];

/// Reindexes waypoint order fields from list position.
List<RouteWaypoint> savedRouteOrderedWaypoints(
  List<RouteWaypoint> waypoints,
) => [
  for (var i = 0; i < waypoints.length; i++) waypoints[i].copyWith(order: i),
];

/// Builds an updated [SavedRoute] from detail form state.
SavedRoute buildSavedRouteDetailUpdate({
  required SavedRoute existing,
  required TextEditingController nameController,
  required TextEditingController descriptionController,
  required TextEditingController notesController,
  required TextEditingController durationController,
  required List<RouteWaypoint> waypoints,
  required RouteDifficulty? difficulty,
  required RecommendedSkillLevel? skillLevel,
  required Set<RouteCategory> selectedCategories,
  required List<String> customTags,
  required bool isFavorite,
}) {
  final durationRaw = int.tryParse(durationController.text.trim());
  final orderedWaypoints = savedRouteOrderedWaypoints(waypoints);
  final geometry = savedRouteWaypointsChanged(existing, orderedWaypoints)
      ? null
      : existing.geometrySnapshot;
  return existing.copyWith(
    name: nameController.text.trim(),
    description: descriptionController.text.trim().isEmpty
        ? null
        : descriptionController.text.trim(),
    notes: notesController.text.trim(),
    isFavorite: isFavorite,
    waypoints: orderedWaypoints,
    geometrySnapshot: geometry,
    metadata: existing.metadata.copyWith(
      difficulty: difficulty,
      recommendedSkillLevel: skillLevel,
      estimatedDurationMinutes: durationRaw,
      categories: savedRouteAllCategoryNames(
        selectedCategories: selectedCategories,
        customTags: customTags,
      ),
    ),
    updatedAt: DateTime.now(),
  );
}
