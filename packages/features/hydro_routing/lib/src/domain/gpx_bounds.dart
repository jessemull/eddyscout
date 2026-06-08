import 'package:eddyscout_hydro_routing/src/domain/planned_route.dart';

/// Pacific Northwest bounding box for GPX import rejection.
abstract final class GpxBounds {
  /// Southern edge of the PNW import rejection bbox (degrees latitude).
  static const minLatitude = 43.0;

  /// Northern edge of the PNW import rejection bbox (degrees latitude).
  static const maxLatitude = 49.5;

  /// Western edge of the PNW import rejection bbox (degrees longitude).
  static const minLongitude = -125.0;

  /// Eastern edge of the PNW import rejection bbox (degrees longitude).
  static const maxLongitude = -116.0;

  /// True when every [points] coordinate lies outside the PNW bbox.
  static bool isEntirelyOutsidePnw(Iterable<GpxPoint> points) {
    final list = points.toList(growable: false);
    if (list.isEmpty) {
      return false;
    }
    return list.every(_isOutsidePnw);
  }

  static bool _isOutsidePnw(GpxPoint point) =>
      point.latitude < minLatitude ||
      point.latitude > maxLatitude ||
      point.longitude < minLongitude ||
      point.longitude > maxLongitude;
}
