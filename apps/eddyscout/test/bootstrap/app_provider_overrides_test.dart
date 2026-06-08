import 'package:eddyscout/bootstrap/app_provider_overrides.dart';
import 'package:eddyscout_conditions/eddyscout_conditions.dart';
import 'package:eddyscout_map/eddyscout_map.dart';
import 'package:eddyscout_map/eddyscout_map_data.dart';
import 'package:eddyscout_persistence/eddyscout_persistence.dart';
import 'package:eddyscout_routing/eddyscout_routing.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late KeyValueStore store;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    store = await SharedPreferencesKeyValueStore.open();
  });

  test('buildAppProviderOverrides wires core repository tokens', () {
    final container = ProviderContainer(
      overrides: buildAppProviderOverrides(keyValueStore: store),
    );
    addTearDown(container.dispose);

    expect(container.read(conditionsRepositoryProvider), isNotNull);
    expect(container.read(conditionReportsRepositoryProvider), isNotNull);
    expect(container.read(conditionsAiSummaryRepositoryProvider), isNotNull);
    expect(container.read(conditionReportSubmitRepositoryProvider), isNotNull);
    expect(container.read(goNoGoProfileRepositoryProvider), isNotNull);
    expect(container.read(gpxFileGatewayProvider), isA<GpxFileGatewayImpl>());
  });

  test('buildAppProviderOverrides applies optional map overrides', () {
    final overrides = buildAppProviderOverrides(
      keyValueStore: store,
      mapboxTokenOverride: 'pk.test',
      mapInteractiveOverride: false,
    );
    final container = ProviderContainer(overrides: overrides);
    addTearDown(container.dispose);

    expect(container.read(mapboxAccessTokenProvider), 'pk.test');
    expect(container.read(mapInteractiveProvider), isFalse);
  });

  test('routesProvider override is supplied for goRouterProvider', () {
    final container = ProviderContainer(
      overrides: buildAppProviderOverrides(keyValueStore: store),
    );
    addTearDown(container.dispose);

    expect(
      () => container.read(routesProvider),
      returnsNormally,
    );
  });
}
