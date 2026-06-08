import 'dart:convert';

import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final computedAt = DateTime.utc(2026, 3, 1, 12);

  group('SavedRoute JSON', () {
    test('round-trips entity with metadata enums and geometry', () {
      final route = SavedRoute(
        id: 'sr_json',
        name: 'JSON Route',
        description: 'desc',
        notes: 'notes',
        isFavorite: true,
        waypoints: const [
          RouteWaypoint(launchId: 'a', order: 0),
          RouteWaypoint(launchId: 'b', order: 1),
        ],
        metadata: const SavedRouteMetadata(
          difficulty: RouteDifficulty.moderate,
          distanceMeters: 8200,
          estimatedDurationMinutes: 180,
          exposure: WindExposure.exposed,
          tideDependency: TideRelevance.major,
          recommendedSkillLevel: RecommendedSkillLevel.intermediate,
          categories: ['scenic', 'family'],
        ),
        geometrySnapshot: RouteGeometrySnapshot(
          polylineLonLat: const [
            [-122.7, 45.56],
            [-122.66, 45.47],
          ],
          lengthMeters: 8200,
          computedAt: computedAt,
        ),
        createdAt: computedAt,
        updatedAt: computedAt,
      );

      final decoded = SavedRoute.fromJson(
        jsonDecode(jsonEncode(route.toJson())) as Map<String, dynamic>,
      );

      expect(decoded.id, route.id);
      expect(decoded.metadata.difficulty, RouteDifficulty.moderate);
      expect(decoded.metadata.exposure, WindExposure.exposed);
      expect(decoded.metadata.tideDependency, TideRelevance.major);
      expect(
        decoded.metadata.recommendedSkillLevel,
        RecommendedSkillLevel.intermediate,
      );
      expect(decoded.metadata.categories, ['scenic', 'family']);
      expect(decoded.geometrySnapshot?.lengthMeters, 8200);
      expect(decoded.waypoints, route.waypoints);
    });

    test('allows null optional metadata fields', () {
      const metadata = SavedRouteMetadata(distanceMeters: 1000);
      final decoded = SavedRouteMetadata.fromJson(metadata.toJson());

      expect(decoded.difficulty, isNull);
      expect(decoded.exposure, isNull);
      expect(decoded.tideDependency, isNull);
      expect(decoded.recommendedSkillLevel, isNull);
      expect(decoded.categories, isEmpty);
    });
  });
}
