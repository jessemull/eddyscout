import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import '../domain/launch_points.dart';

/// Approximate centroid of `kLaunchPoints` for initial viewport.
Point mapRegionCenter() {
  double lat = 0;
  double lon = 0;
  for (final p in kLaunchPoints) {
    lat += p.latitude;
    lon += p.longitude;
  }
  final n = kLaunchPoints.length.toDouble();
  return Point(coordinates: Position(lon / n, lat / n));
}

/// Stable instance: a new `CameraViewportState` each build re-applied zoom 9.
final ViewportState kInitialMapViewport = CameraViewportState(
  center: mapRegionCenter(),
  zoom: 9,
  pitch: 0,
  bearing: 0,
);

const int kMapMarkerColor = 0xFF0077B6;
const int kMapMarkerStroke = 0xFFFFFFFF;
const int kMapSelectedMarkerFill = 0x330077B6;
const int kMapSelectedMarkerStroke = 0xFF0077B6;
const int kMapRouteLineColor = 0xFFE63946;

const String kMapRouteSourceId = 'eddyscout-route-source';
const String kMapRouteLayerId = 'eddyscout-route-layer';
const String kMapEmptyRouteGeoJson =
    '{"type":"FeatureCollection","features":[]}';

const double kMapMinZoom = 0;
const double kMapMaxZoom = 25.5;
const double kMapMinPitch = 0;
const double kMapMaxPitch = 85;
const double kMapChromeZoomStep = 1.25;

/// Zoom when centering on a selected launch (browse / search pick).
const double kLaunchFocusZoom = 10.5;

/// Bottom inset for map chrome when the route preview bar is visible.
const double kMapPlanningPreviewBottomPadding = 220;

/// Extra bottom inset when the preview bar includes a route go/no-go section.
const double kMapPlanningPreviewGoNoGoExtraPadding = 56;

/// Bottom inset when route preview includes the go/no-go rollup card.
const double kMapPlanningPreviewWithGoNoGoBottomPadding =
    kMapPlanningPreviewBottomPadding + kMapPlanningPreviewGoNoGoExtraPadding;

/// [MapboxMap.addInteraction] id for map-surface tap handling.
const String kMapContentTapInteractionId = 'eddyscout_map_content_tap';
