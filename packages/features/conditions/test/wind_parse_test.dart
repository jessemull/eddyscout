import 'package:eddyscout_conditions/src/data/parsing/wind_parse.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parseWindMph handles ranges and calm', () {
    expect(parseWindMph('5 mph'), 5);
    expect(parseWindMph('10 to 15 mph'), 15);
    expect(parseWindMph('Calm'), 0);
    expect(parseWindMph(null), null);
  });
}
