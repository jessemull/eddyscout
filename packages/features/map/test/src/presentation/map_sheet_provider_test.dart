import 'package:eddyscout_map/eddyscout_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

LaunchPoint _launch() {
  return const LaunchPoint(
    id: 'sellwood_riverfront',
    name: 'Sellwood Riverfront Park',
    latitude: 45.466767,
    longitude: -122.663518,
    shortNote: 'Test',
    riverSystem: RiverSystem.willamette,
    windExposure: WindExposure.moderate,
    tideRelevance: TideRelevance.minor,
  );
}

void main() {
  group('MapPlaceSelection', () {
    test('pickLaunch and clear update selection', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final launch = _launch();
      container.read(mapPlaceSelectionProvider.notifier).pickLaunch(launch);
      expect(container.read(mapPlaceSelectionProvider), launch);

      container.read(mapPlaceSelectionProvider.notifier).clear();
      expect(container.read(mapPlaceSelectionProvider), isNull);
    });
  });

  group('MapSheetVisibilityState', () {
    test('transitions through sheet modes and hides', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(mapSheetVisibilityStateProvider.notifier);
      expect(
        container.read(mapSheetVisibilityStateProvider),
        MapSheetVisibility.hidden,
      );

      notifier.showPlacePeek();
      expect(
        container.read(mapSheetVisibilityStateProvider),
        MapSheetVisibility.placePeek,
      );

      notifier.showPlanningEdit();
      expect(
        container.read(mapSheetVisibilityStateProvider),
        MapSheetVisibility.planningEdit,
      );

      notifier.showPlanningPreview();
      expect(
        container.read(mapSheetVisibilityStateProvider),
        MapSheetVisibility.planningPreview,
      );

      notifier.hide();
      expect(
        container.read(mapSheetVisibilityStateProvider),
        MapSheetVisibility.hidden,
      );
    });
  });
}
