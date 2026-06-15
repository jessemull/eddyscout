/// Binary min-heap for A* search entries ordered by f-score.
class AStarMinHeap {
  final _vertices = <int>[];
  final _fScores = <double>[];

  /// Whether the heap has no entries.
  bool get isEmpty => _vertices.isEmpty;

  /// Number of entries in the heap.
  int get length => _vertices.length;

  /// Inserts [vertex] with the given f-score priority.
  void add({required int vertex, required double fScore}) {
    _vertices.add(vertex);
    _fScores.add(fScore);
    _bubbleUp(_vertices.length - 1);
  }

  /// Removes and returns the entry with the smallest f-score.
  ({int vertex, double fScore}) removeMin() {
    if (isEmpty) {
      throw StateError('removeMin from empty heap');
    }
    final minVertex = _vertices[0];
    final minF = _fScores[0];
    final last = _vertices.length - 1;
    if (last == 0) {
      _vertices.clear();
      _fScores.clear();
    } else {
      _vertices[0] = _vertices[last];
      _fScores[0] = _fScores[last];
      _vertices.removeLast();
      _fScores.removeLast();
      _bubbleDown(0);
    }
    return (vertex: minVertex, fScore: minF);
  }

  void _bubbleUp(int index) {
    var i = index;
    while (i > 0) {
      final parent = (i - 1) ~/ 2;
      if (_fScores[i] >= _fScores[parent]) {
        break;
      }
      _swap(i, parent);
      i = parent;
    }
  }

  void _bubbleDown(int index) {
    var i = index;
    final n = _vertices.length;
    while (true) {
      final left = 2 * i + 1;
      final right = 2 * i + 2;
      var smallest = i;
      if (left < n && _fScores[left] < _fScores[smallest]) {
        smallest = left;
      }
      if (right < n && _fScores[right] < _fScores[smallest]) {
        smallest = right;
      }
      if (smallest == i) {
        break;
      }
      _swap(i, smallest);
      i = smallest;
    }
  }

  void _swap(int a, int b) {
    final v = _vertices[a];
    _vertices[a] = _vertices[b];
    _vertices[b] = v;
    final f = _fScores[a];
    _fScores[a] = _fScores[b];
    _fScores[b] = f;
  }
}
