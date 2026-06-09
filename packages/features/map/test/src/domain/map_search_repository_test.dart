import 'package:eddyscout_map/src/domain/launch_points.dart';
import 'package:eddyscout_map/src/domain/map_search_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LocalMapSearchRepository', () {
    const repository = LocalMapSearchRepository(kLaunchPoints);

    test('returns empty list for blank query', () {
      expect(repository.searchLaunches('   '), isEmpty);
    });

    test('matches launch name case-insensitively', () {
      final hits = repository.searchLaunches('sellwood');
      expect(hits, isNotEmpty);
      expect(
        hits.any((hit) => hit.launch.id == 'sellwood_riverfront'),
        isTrue,
      );
    });

    test('searchPlaces returns empty until geocoding ships', () async {
      final places = await repository.searchPlaces('Portland');
      expect(places, isEmpty);
    });
  });
}
