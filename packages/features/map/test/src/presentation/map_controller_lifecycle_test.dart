import 'package:eddyscout_map/eddyscout_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('mapboxMapControllerProvider stays alive while watched', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final sub = container.listen(mapboxMapControllerProvider, (_, _) {});
    expect(container.read(mapboxMapControllerProvider.notifier), isNotNull);
    sub.close();
  });
}
