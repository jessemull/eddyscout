import 'package:eddyscout_map/eddyscout_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('readLaunchPointIfExists returns catalog launch on Ref', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final launch = container.read(
      Provider((ref) => ref.readLaunchPointIfExists('cathedral_park')),
    );
    expect(launch, isNotNull);
    expect(launch!.id, 'cathedral_park');
  });

  test('readLaunchPointIfExists returns null for unknown id on Ref', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final launch = container.read(
      Provider((ref) => ref.readLaunchPointIfExists('missing-launch')),
    );
    expect(launch, isNull);
  });
}
