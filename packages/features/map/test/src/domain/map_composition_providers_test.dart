import 'package:eddyscout_map/eddyscout_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('gpxFileGatewayProvider throws when not overridden', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(
      () => container.read(gpxFileGatewayProvider),
      throwsA(isA<Object>()),
    );
  });

  test('mapGpxServiceProvider throws when not overridden', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await expectLater(
      container.read(mapGpxServiceProvider.future),
      throwsA(isA<UnimplementedError>()),
    );
  });

  test('mapRoutePlannerProvider throws when not overridden', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await expectLater(
      container.read(mapRoutePlannerProvider.future),
      throwsA(isA<UnimplementedError>()),
    );
  });
}
