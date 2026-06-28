import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_hydro_routing/src/domain/launch_reachability_index.dart';

/// Minimum separation from endpoints when accepting intermediate waypoints (m).
const kSuggestedTripEndpointSeparationMeters = 50.0;

/// Ordered launch ids along [polylineLonLat] from [source] to [destination].
///
/// Includes [source] first and [destination] last. Intermediate catalog
/// launches lie within [snapMaxMeters] of the polyline strictly between the
/// endpoints.
List<String> suggestedTripWaypoints({
  required List<List<double>> polylineLonLat,
  required LaunchPoint source,
  required LaunchPoint destination,
  required List<LaunchPoint> catalog,
  double snapMaxMeters = kReachabilitySnapMaxMeters,
}) {
  if (polylineLonLat.length < 2) {
    return [source.id, destination.id];
  }

  final cumulative = _cumulativeSegmentMeters(polylineLonLat);
  final totalMeters = cumulative.last;
  final intermediates = <({String id, double alongMeters})>[];

  for (final candidate in catalog) {
    if (candidate.id == source.id || candidate.id == destination.id) {
      continue;
    }

    final projection = _closestPointAlongPolyline(
      latitude: candidate.routingLatitude,
      longitude: candidate.routingLongitude,
      polylineLonLat: polylineLonLat,
      cumulativeMeters: cumulative,
    );
    if (projection == null) {
      continue;
    }
    if (projection.distanceMeters > snapMaxMeters) {
      continue;
    }
    if (projection.alongMeters <= kSuggestedTripEndpointSeparationMeters) {
      continue;
    }
    if (projection.alongMeters >=
        totalMeters - kSuggestedTripEndpointSeparationMeters) {
      continue;
    }
    intermediates.add((id: candidate.id, alongMeters: projection.alongMeters));
  }

  intermediates.sort((a, b) {
    final byAlong = a.alongMeters.compareTo(b.alongMeters);
    if (byAlong != 0) {
      return byAlong;
    }
    return a.id.compareTo(b.id);
  });

  return [
    source.id,
    ...intermediates.map((e) => e.id),
    destination.id,
  ];
}

List<double> _cumulativeSegmentMeters(List<List<double>> polylineLonLat) {
  final cumulative = <double>[0];
  for (var i = 1; i < polylineLonLat.length; i++) {
    final previous = polylineLonLat[i - 1];
    final current = polylineLonLat[i];
    cumulative.add(
      cumulative.last +
          haversineMeters(
            previous[1],
            previous[0],
            current[1],
            current[0],
          ),
    );
  }
  return cumulative;
}

({double alongMeters, double distanceMeters})? _closestPointAlongPolyline({
  required double latitude,
  required double longitude,
  required List<List<double>> polylineLonLat,
  required List<double> cumulativeMeters,
}) {
  var bestDistance = double.infinity;
  var bestAlong = 0.0;
  var found = false;

  for (var i = 1; i < polylineLonLat.length; i++) {
    final start = polylineLonLat[i - 1];
    final end = polylineLonLat[i];
    final segmentLength = cumulativeMeters[i] - cumulativeMeters[i - 1];
    if (segmentLength <= 0) {
      continue;
    }

    final projection = _projectPointOntoSegment(
      latitude: latitude,
      longitude: longitude,
      startLat: start[1],
      startLon: start[0],
      endLat: end[1],
      endLon: end[0],
      segmentLengthMeters: segmentLength,
    );

    if (projection.distanceMeters < bestDistance) {
      bestDistance = projection.distanceMeters;
      bestAlong = cumulativeMeters[i - 1] + projection.alongSegmentMeters;
      found = true;
    }
  }

  if (!found) {
    return null;
  }
  return (alongMeters: bestAlong, distanceMeters: bestDistance);
}

({double alongSegmentMeters, double distanceMeters}) _projectPointOntoSegment({
  required double latitude,
  required double longitude,
  required double startLat,
  required double startLon,
  required double endLat,
  required double endLon,
  required double segmentLengthMeters,
}) {
  if (segmentLengthMeters <= 0) {
    final distance = haversineMeters(latitude, longitude, startLat, startLon);
    return (alongSegmentMeters: 0, distanceMeters: distance);
  }

  const samples = 32;
  var bestDistance = double.infinity;
  var bestAlong = 0.0;

  for (var step = 0; step <= samples; step++) {
    final t = step / samples;
    final sampleLat = startLat + (endLat - startLat) * t;
    final sampleLon = startLon + (endLon - startLon) * t;
    final distance = haversineMeters(
      latitude,
      longitude,
      sampleLat,
      sampleLon,
    );
    if (distance < bestDistance) {
      bestDistance = distance;
      bestAlong = segmentLengthMeters * t;
    }
  }

  return (alongSegmentMeters: bestAlong, distanceMeters: bestDistance);
}
