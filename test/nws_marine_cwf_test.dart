import 'package:eddyscout/conditions/parsing/nws_marine_cwf.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('marineSummaryFromCwfProductText extracts zone block until end marker', () {
    const sample = r'''
PZZ251-131115-
Some other zone
line two
$$

PZZ210-131115-
Columbia River Bar-
107 PM PDT Sun Apr 12 2026

.IN THE MAIN CHANNEL...
Seas 4 ft.
$$

PZZ200-131115-
Synopsis...
''';

    final m = marineSummaryFromCwfProductText(sample, 'PZZ210');
    expect(m, isNotNull);
    expect(m!.zoneId, 'PZZ210');
    expect(m.periods, hasLength(1));
    expect(m.periods.single.detailedForecast, contains('Columbia River Bar'));
    expect(m.periods.single.detailedForecast, contains('Seas 4 ft'));
    expect(m.periods.single.detailedForecast, isNot(contains('PZZ251')));
    expect(m.periods.single.detailedForecast, isNot(contains('PZZ200')));
  });

  test('nwsMarineZoneCwaOffice reads cwa', () {
    final office = nwsMarineZoneCwaOffice({
      'properties': {
        'cwa': ['PQR'],
      },
    });
    expect(office, 'PQR');
  });

  test('nwsLatestCwfProductId picks newest issuanceTime', () {
    final id = nwsLatestCwfProductId({
      '@graph': [
        {'id': 'older', 'issuanceTime': '2026-04-11T20:10:00+00:00'},
        {'id': 'newer', 'issuanceTime': '2026-04-12T20:07:00+00:00'},
      ],
    });
    expect(id, 'newer');
  });
}
