import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('disableProviderRetry returns null', () {
    expect(disableProviderRetry(1, StateError('test')), isNull);
  });
}
