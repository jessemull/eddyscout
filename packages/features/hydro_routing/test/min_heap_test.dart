import 'package:eddyscout_hydro_routing/src/data/min_heap.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AStarMinHeap', () {
    test('removeMin on empty heap throws', () {
      final heap = AStarMinHeap();
      expect(heap.isEmpty, isTrue);
      expect(heap.removeMin, throwsStateError);
    });

    test('returns entries in ascending fScore order', () {
      final heap = AStarMinHeap();
      heap.add(vertex: 3, fScore: 10);
      heap.add(vertex: 1, fScore: 2);
      heap.add(vertex: 2, fScore: 5);

      expect(heap.removeMin(), (vertex: 1, fScore: 2));
      expect(heap.removeMin(), (vertex: 2, fScore: 5));
      expect(heap.removeMin(), (vertex: 3, fScore: 10));
      expect(heap.isEmpty, isTrue);
    });

    test('handles duplicate fScores', () {
      final heap = AStarMinHeap();
      heap.add(vertex: 0, fScore: 1);
      heap.add(vertex: 1, fScore: 1);
      heap.add(vertex: 2, fScore: 1);

      final seen = <int>{};
      while (!heap.isEmpty) {
        final entry = heap.removeMin();
        expect(entry.fScore, 1);
        seen.add(entry.vertex);
      }
      expect(seen, {0, 1, 2});
    });

    test('large random insert order still yields min first', () {
      final heap = AStarMinHeap();
      final scores = <int, double>{};
      for (var i = 0; i < 500; i++) {
        final f = (i * 37 % 1000).toDouble();
        scores[i] = f;
        heap.add(vertex: i, fScore: f);
      }

      var prev = -1.0;
      while (!heap.isEmpty) {
        final entry = heap.removeMin();
        expect(entry.fScore, greaterThanOrEqualTo(prev));
        expect(entry.fScore, scores[entry.vertex]);
        prev = entry.fScore;
      }
    });
  });
}
