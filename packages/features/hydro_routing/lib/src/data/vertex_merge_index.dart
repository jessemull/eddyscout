import 'dart:math' as math;

import 'package:eddyscout_core/eddyscout_core.dart';

/// Uniform grid for near-duplicate vertex lookup during graph construction.
///
/// Cell size matches [mergeMeters] in a local equirectangular projection so any
/// pair within the merge radius lies in the same cell or a 3×3 neighborhood.
class VertexMergeIndex {
  /// Creates an index with square cells sized to [mergeMeters].
  VertexMergeIndex({
    required this.mergeMeters,
    required double refLatitude,
  }) : _cellLatDeg = mergeMeters / _metersPerDegreeLatitude,
       _cellLonDeg =
           mergeMeters /
           (_metersPerDegreeLatitude *
               math.cos(refLatitude * math.pi / 180).abs().clamp(1e-6, 1.0));

  static const _metersPerDegreeLatitude = 111320.0;

  /// Maximum haversine distance (meters) for merging duplicate vertices.
  final double mergeMeters;
  final double _cellLatDeg;
  final double _cellLonDeg;
  final Map<(int, int), List<int>> _buckets = {};

  /// Returns the lowest existing vertex index within [mergeMeters], if any.
  int? findExisting(
    List<double> lat,
    List<double> lon,
    double la,
    double lo,
  ) {
    int? best;
    for (final i in _neighborVertices(la, lo)) {
      if (haversineMeters(lat[i], lon[i], la, lo) <= mergeMeters) {
        if (best == null || i < best) {
          best = i;
        }
      }
    }
    return best;
  }

  /// Registers [vertexIndex] at ([la], [lo]).
  void add(int vertexIndex, double la, double lo) {
    _buckets.putIfAbsent(_cell(la, lo), () => []).add(vertexIndex);
  }

  Iterable<int> _neighborVertices(double la, double lo) sync* {
    final (row, col) = _cell(la, lo);
    for (var dr = -1; dr <= 1; dr++) {
      for (var dc = -1; dc <= 1; dc++) {
        final bucket = _buckets[(row + dr, col + dc)];
        if (bucket != null) {
          yield* bucket;
        }
      }
    }
  }

  (int, int) _cell(double la, double lo) {
    final row = (la / _cellLatDeg).floor();
    final col = (lo / _cellLonDeg).floor();
    return (row, col);
  }
}
