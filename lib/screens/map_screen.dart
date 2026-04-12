import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import '../data/launch_points.dart';
import 'launch_detail_screen.dart';

/// Approximate centroid of [kLaunchPoints] for initial viewport.
Point get _regionCenter {
  double lat = 0, lon = 0;
  for (final p in kLaunchPoints) {
    lat += p.latitude;
    lon += p.longitude;
  }
  final n = kLaunchPoints.length.toDouble();
  return Point(coordinates: Position(lon / n, lat / n));
}

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  Cancelable? _tapCancelable;

  static const int _markerColor = 0xFF0077B6;
  static const int _markerStroke = 0xFFFFFFFF;

  @override
  void dispose() {
    _tapCancelable?.cancel();
    super.dispose();
  }

  Future<void> _onMapCreated(MapboxMap mapboxMap) async {
    final center = _regionCenter;
    await mapboxMap.setCamera(
      CameraOptions(center: center, zoom: 9, pitch: 0, bearing: 0),
    );

    final manager = await mapboxMap.annotations.createCircleAnnotationManager();

    final coords = kLaunchPoints
        .map(
          (p) => Point(coordinates: Position(p.longitude, p.latitude)),
        )
        .toList();

    final options = kLaunchPoints
        .map(
          (p) => CircleAnnotationOptions(
            geometry: Point(coordinates: Position(p.longitude, p.latitude)),
            circleRadius: 10,
            circleColor: _markerColor,
            circleStrokeWidth: 2,
            circleStrokeColor: _markerStroke,
            customData: <String, Object>{'launchId': p.id},
          ),
        )
        .toList();

    await manager.createMulti(options);

    try {
      final fitted = await mapboxMap.cameraForCoordinatesPadding(
        coords,
        CameraOptions(
          center: center,
          zoom: 9,
          bearing: 0,
          pitch: 0,
        ),
        MbxEdgeInsets(top: 100, left: 40, bottom: 56, right: 40),
        11,
        null,
      );
      await mapboxMap.setCamera(fitted);
    } catch (_) {
      // Keep default camera if padding fit fails on some devices.
    }

    _tapCancelable = manager.tapEvents(
      onTap: (CircleAnnotation annotation) {
        final raw = annotation.customData?['launchId'];
        if (raw is! String) return;
        final launch = launchPointById(raw);
        if (launch == null || !context.mounted) return;
        Navigator.of(context).push<void>(
          MaterialPageRoute<void>(
            builder: (context) => LaunchDetailScreen(launch: launch),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final center = _regionCenter;
    return Scaffold(
      appBar: AppBar(
        title: const Text('EddyScout'),
      ),
      body: MapWidget(
        key: const ValueKey<String>('eddyscout_map'),
        styleUri: MapboxStyles.STANDARD,
        viewport: CameraViewportState(
          center: center,
          zoom: 9,
        ),
        onMapCreated: _onMapCreated,
      ),
    );
  }
}
