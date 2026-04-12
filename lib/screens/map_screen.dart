import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import '../data/launch_points.dart';
import 'launch_detail_screen.dart';

/// Portland core + Columbia / Willamette confluence framing.
final Point _portlandCenter = Point(coordinates: Position(-122.678, 45.515));

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
    await mapboxMap.setCamera(
      CameraOptions(center: _portlandCenter, zoom: 10.5, pitch: 0, bearing: 0),
    );

    final manager = await mapboxMap.annotations.createCircleAnnotationManager();

    final options = kPortlandLaunchPoints
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('EddyScout'),
      ),
      body: MapWidget(
        key: const ValueKey<String>('eddyscout_map'),
        styleUri: MapboxStyles.STANDARD,
        viewport: CameraViewportState(
          center: _portlandCenter,
          zoom: 10.5,
        ),
        onMapCreated: _onMapCreated,
      ),
    );
  }
}
