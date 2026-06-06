import 'package:eddyscout_conditions/eddyscout_conditions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('conditionReportsRefreshTokenProvider', () {
    test('starts at zero and increments', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(conditionReportsRefreshTokenProvider), 0);

      container.read(conditionReportsRefreshTokenProvider.notifier).increment();

      expect(container.read(conditionReportsRefreshTokenProvider), 1);
    });
  });
}
