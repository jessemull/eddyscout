import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_saved_routes/src/presentation/pages/saved_route_detail_form_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_saved_routes.dart';

void main() {
  test('savedRouteCategoriesFromNames keeps enum values only', () {
    expect(
      savedRouteCategoriesFromNames(['scenic', 'custom-tag']),
      {RouteCategory.scenic},
    );
    expect(
      savedRouteCustomTagsFromNames(['scenic', 'custom-tag']),
      ['custom-tag'],
    );
  });

  test('savedRouteAllCategoryNames merges enum and custom tags', () {
    expect(
      savedRouteAllCategoryNames(
        selectedCategories: {RouteCategory.scenic},
        customTags: const ['sunrise'],
      ),
      ['scenic', 'sunrise'],
    );
  });

  test('savedRouteOrderedWaypoints reindexes order fields', () {
    final waypoints = [
      const RouteWaypoint.catalog(launchId: 'a', order: 9),
      const RouteWaypoint.catalog(launchId: 'b', order: 4),
    ];

    final ordered = savedRouteOrderedWaypoints(waypoints);

    expect(ordered[0].order, 0);
    expect(ordered[1].order, 1);
  });

  test('buildSavedRouteDetailUpdate applies form values', () {
    final existing = testSavedRoute();
    final nameController = TextEditingController(text: 'Updated route');
    final descriptionController = TextEditingController(text: 'Scenic paddle');
    final notesController = TextEditingController(text: 'Bring layers');
    final durationController = TextEditingController(text: '120');
    addTearDown(nameController.dispose);
    addTearDown(descriptionController.dispose);
    addTearDown(notesController.dispose);
    addTearDown(durationController.dispose);

    final updated = buildSavedRouteDetailUpdate(
      existing: existing,
      nameController: nameController,
      descriptionController: descriptionController,
      notesController: notesController,
      durationController: durationController,
      waypoints: existing.waypoints,
      difficulty: RouteDifficulty.moderate,
      skillLevel: RecommendedSkillLevel.intermediate,
      selectedCategories: {RouteCategory.scenic},
      customTags: const ['sunrise'],
      isFavorite: true,
    );

    expect(updated.name, 'Updated route');
    expect(updated.description, 'Scenic paddle');
    expect(updated.notes, 'Bring layers');
    expect(updated.isFavorite, isTrue);
    expect(updated.metadata.difficulty, RouteDifficulty.moderate);
    expect(
      updated.metadata.recommendedSkillLevel,
      RecommendedSkillLevel.intermediate,
    );
    expect(updated.metadata.estimatedDurationMinutes, 120);
    expect(updated.metadata.categories, ['scenic', 'sunrise']);
  });
}
