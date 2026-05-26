import 'package:eddyscout_networking/eddyscout_networking.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('networking package is loadable', () {
    expect(true, isTrue);
    // Touch a few exports so coverage counts the libraries.
    expect(EddyScoutDioFactory.defaultUserAgent, contains('EddyScout'));
  });
}
