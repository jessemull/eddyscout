import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_saved_routes.dart';

void main() {
  test('copyWith preserves custom category tags in metadata', () {
    final route = testSavedRoute().copyWith(
      metadata: const SavedRouteMetadata(
        distanceMeters: 5200,
        categories: ['scenic', 'summer paddle'],
      ),
    );

    expect(route.metadata.categories, ['scenic', 'summer paddle']);
  });

  test('splits enum and custom category names', () {
    final enumNames = {
      for (final category in RouteCategory.values) category.name,
    };
    final categories = ['scenic', 'summer paddle', 'training'];
    final custom = categories
        .where((name) => !enumNames.contains(name))
        .toList();

    expect(custom, ['summer paddle']);
  });
}
