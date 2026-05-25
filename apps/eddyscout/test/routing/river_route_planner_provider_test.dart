import 'package:eddyscout/routing/river_route_planner_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('riverRoutePlannerProvider', () {
    test('loads bundled hydro geojson', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final planner = await container.read(riverRoutePlannerProvider.future);

      expect(planner, isNotNull);
    });
  });
}
