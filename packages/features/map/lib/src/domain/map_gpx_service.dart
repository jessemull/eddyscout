import 'package:eddyscout_core/eddyscout_core.dart';

/// GPX parse/serialize and launch snapping without coupling map to hydro.
abstract class MapGpxService {
  /// Serializes [route] to GPX 1.1 XML.
  Result<String, GpxFailure> serialize(PlannedRoute route);

  /// Parses GPX XML into a [PlannedRoute].
  Result<PlannedRoute, GpxFailure> parse(String gpxXml);

  /// Snaps route endpoints to nearest catalog launches when within threshold.
  PlannedRoute snapLaunchEndpoints({
    required PlannedRoute route,
    required List<LaunchPoint> catalog,
  });

  /// True when every point lies outside Pacific Northwest import bounds.
  bool isEntirelyOutsidePnw(List<GpxPoint> points);
}
