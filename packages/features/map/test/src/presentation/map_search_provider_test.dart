import 'package:eddyscout_map/eddyscout_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MapSearchQuery', () {
    test('updates and clears query', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(mapSearchQueryProvider.notifier);
      notifier.changeQuery('sellwood');
      expect(container.read(mapSearchQueryProvider), 'sellwood');

      notifier.clear();
      expect(container.read(mapSearchQueryProvider), isEmpty);
    });
  });

  group('MapSearchExpanded', () {
    test('expand and collapse clears query and inline add-stop', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(mapSearchQueryProvider.notifier).changeQuery('test');
      container.read(mapPlanningInlineAddStopProvider.notifier).show();

      container.read(mapSearchExpandedProvider.notifier).expand();
      expect(container.read(mapSearchExpandedProvider), isTrue);

      container.read(mapSearchExpandedProvider.notifier).collapse();
      expect(container.read(mapSearchExpandedProvider), isFalse);
      expect(container.read(mapSearchQueryProvider), isEmpty);
      expect(container.read(mapPlanningInlineAddStopProvider), isFalse);
    });
  });

  group('MapPlanningInlineAddStop', () {
    test('show and hide toggle state', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(
        mapPlanningInlineAddStopProvider.notifier,
      );
      notifier.show();
      expect(container.read(mapPlanningInlineAddStopProvider), isTrue);
      notifier.hide();
      expect(container.read(mapPlanningInlineAddStopProvider), isFalse);
    });
  });

  group('MapSearchContextState', () {
    test('switches between browse and addStop', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(mapSearchContextStateProvider.notifier);
      notifier.setAddStop();
      expect(
        container.read(mapSearchContextStateProvider),
        MapSearchContext.addStop,
      );
      notifier.setBrowse();
      expect(
        container.read(mapSearchContextStateProvider),
        MapSearchContext.browse,
      );
    });
  });

  group('mapSearchLaunchHits', () {
    test('returns launch hits for non-empty query', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(mapSearchQueryProvider.notifier).changeQuery('sellwood');
      final hits = container.read(mapSearchLaunchHitsProvider);
      expect(hits, isNotEmpty);
      expect(
        hits.any((hit) => hit.result.launch.id == 'sellwood_riverfront'),
        isTrue,
      );
    });

    test('returns empty list for blank query', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(mapSearchLaunchHitsProvider), isEmpty);
    });
  });

  group('mapBrowseSearchFullScreen', () {
    test('is false when query is empty', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(mapBrowseSearchFullScreenProvider), isFalse);
    });

    test('is true when launch hits exist', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(mapSearchQueryProvider.notifier).changeQuery('sellwood');
      expect(container.read(mapBrowseSearchFullScreenProvider), isTrue);
    });
  });

  group('mapSearchPlaceHits', () {
    test('returns empty list for blank query', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final hits = await container.read(
        mapSearchPlaceHitsProvider('  ').future,
      );
      expect(hits, isEmpty);
    });
  });
}
