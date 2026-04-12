/// Portland-area kayak launch seed data for the map milestone.
class LaunchPoint {
  const LaunchPoint({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.shortNote,
  });

  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final String shortNote;
}

/// Stable ids match [CircleAnnotationOptions.customData] `launchId` on the map.
const List<LaunchPoint> kPortlandLaunchPoints = [
  LaunchPoint(
    id: 'cathedral_park',
    name: 'Cathedral Park Boat Ramp',
    latitude: 45.5868,
    longitude: -122.7576,
    shortNote: 'Willamette put-in under St. Johns Bridge; motorboat traffic.',
  ),
  LaunchPoint(
    id: 'sellwood_riverfront',
    name: 'Sellwood Riverfront Park',
    latitude: 45.4710,
    longitude: -122.6520,
    shortNote: 'Popular flatwater stretch of the Willamette.',
  ),
  LaunchPoint(
    id: 'willamette_park_sw',
    name: 'Willamette Park (SW)',
    latitude: 45.4510,
    longitude: -122.6770,
    shortNote: 'Sheltered access on the Willamette corridor.',
  ),
  LaunchPoint(
    id: 'tom_mccall_waterfront',
    name: 'Tom McCall Waterfront Park',
    latitude: 45.5120,
    longitude: -122.6750,
    shortNote: 'Urban launch; events and river traffic.',
  ),
  LaunchPoint(
    id: 'kelley_point',
    name: 'Kelley Point Park',
    latitude: 45.5910,
    longitude: -122.7260,
    shortNote: 'Columbia / Willamette confluence zone; currents and wind.',
  ),
];

LaunchPoint? launchPointById(String id) {
  for (final p in kPortlandLaunchPoints) {
    if (p.id == id) return p;
  }
  return null;
}
