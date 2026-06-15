@Tags(['benchmark'])
library;

import 'package:flutter_test/flutter_test.dart';

import '../helpers/synthetic_grid_graph.dart';

void main() {
  group('A* benchmarks', () {
    test('route computation under 200 ms at 50k nodes', () {
      final graph = buildSyntheticGridGraph(50000);
      expect(graph.vertexCount, greaterThanOrEqualTo(49000));

      final last = graph.vertexCount - 1;
      final sw = Stopwatch()..start();
      final path = graph.astarForTesting(0, last);
      sw.stop();

      expect(path, isNotNull);
      expect(sw.elapsedMilliseconds, lessThan(200));
    });

    test('route computation scales at 5k and 20k nodes', () {
      for (final target in [5000, 20000]) {
        final graph = buildSyntheticGridGraph(target);
        final last = graph.vertexCount - 1;
        expect(graph.dijkstraReference(0, last), isNotNull);
        final sw = Stopwatch()..start();
        final path = graph.astarForTesting(0, last);
        sw.stop();
        expect(path, isNotNull);
        expect(sw.elapsedMilliseconds, lessThan(200));
      }
    });
  });
}
