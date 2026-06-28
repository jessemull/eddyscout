import 'package:freezed_annotation/freezed_annotation.dart';

part 'waterway_snap_point.freezed.dart';

/// Result of snapping a map point to bundled hydro graph geometry.
@freezed
abstract class WaterwaySnapPoint with _$WaterwaySnapPoint {
  /// Creates a snapped waterway point.
  const factory WaterwaySnapPoint({
    required double latitude,
    required double longitude,
    required double distanceMeters,
    String? reachId,
  }) = _WaterwaySnapPoint;
}
