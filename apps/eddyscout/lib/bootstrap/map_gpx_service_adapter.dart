import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_hydro_routing/eddyscout_hydro_routing.dart';
import 'package:eddyscout_map/eddyscout_map.dart';

/// Hydro-backed [MapGpxService] wired in the app composition layer.
final class HydroMapGpxService implements MapGpxService {
  const HydroMapGpxService();

  @override
  Result<String, GpxFailure> serialize(PlannedRoute route) =>
      GpxCodec.serialize(route);

  @override
  Result<PlannedRoute, GpxFailure> parse(String gpxXml) =>
      GpxCodec.parse(gpxXml);

  @override
  PlannedRoute snapLaunchEndpoints({
    required PlannedRoute route,
    required List<LaunchPoint> catalog,
  }) => LaunchEndpointSnapper.snapEndpoints(route: route, catalog: catalog);

  @override
  bool isEntirelyOutsidePnw(List<GpxPoint> points) =>
      GpxBounds.isEntirelyOutsidePnw(points);
}
