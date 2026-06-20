import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:gpx/gpx.dart';

/// Parses and serializes GPX 1.1 for planned routes.
abstract final class GpxCodec {
  static const _creator = 'EddyScout';

  /// Serializes [route] to GPX 1.1 XML.
  static Result<String, GpxFailure> serialize(PlannedRoute route) {
    if (route.points.length < 2) {
      return const Result.failure(
        GpxFailure(code: GpxFailureCode.tooFewPoints),
      );
    }

    final gpx = Gpx()
      ..version = '1.1'
      ..creator = _creator
      ..metadata = (Metadata()
        ..name = route.name ?? 'EddyScout route'
        ..desc = 'Planned river route from EddyScout');

    if (route.putIn != null) {
      gpx.wpts.add(_launchWpt(route.putIn!));
    }
    if (route.takeOut != null) {
      gpx.wpts.add(_launchWpt(route.takeOut!));
    }

    gpx.trks.add(
      Trk(
        name: route.name ?? 'EddyScout route',
        trksegs: [
          Trkseg(
            trkpts: route.points.map(_gpxPointToWpt).toList(growable: false),
          ),
        ],
      ),
    );

    final xml = GpxWriter().asString(gpx, pretty: true);
    return Result.success(xml);
  }

  /// Parses GPX XML into a [PlannedRoute].
  ///
  /// Geometry priority: tracks, then routes, then waypoints.
  static Result<PlannedRoute, GpxFailure> parse(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) {
      return const Result.failure(
        GpxFailure(code: GpxFailureCode.emptyInput),
      );
    }

    final Gpx gpx;
    try {
      gpx = GpxReader().fromString(trimmed);
    } on Object {
      return const Result.failure(
        GpxFailure(code: GpxFailureCode.malformedXml),
      );
    }

    return _extractPoints(gpx).when(
      success: (points) {
        final lengthMeters = polylinePathLengthMeters(points);
        return Result.success(
          PlannedRoute(
            points: points,
            lengthMeters: lengthMeters > 0 ? lengthMeters : null,
            name: gpx.metadata?.name ?? gpx.trks.firstOrNull?.name,
            origin: RouteOrigin.imported,
          ),
        );
      },
      failure: Result.failure,
    );
  }

  static Wpt _launchWpt(LaunchPoint launch) => Wpt(
    lat: launch.latitude,
    lon: launch.longitude,
    name: launch.name,
    desc: launch.shortNote,
  );

  static Wpt _gpxPointToWpt(GpxPoint point) => Wpt(
    lat: point.latitude,
    lon: point.longitude,
    ele: point.elevationMeters,
    time: point.timestamp,
  );

  static GpxPoint _wptToGpxPoint(Wpt wpt) {
    final lat = wpt.lat;
    final lon = wpt.lon;
    if (lat == null || lon == null) {
      throw const FormatException('missing lat/lon');
    }
    return GpxPoint(
      latitude: lat,
      longitude: lon,
      elevationMeters: wpt.ele,
      timestamp: wpt.time,
    );
  }

  static Result<List<GpxPoint>, GpxFailure> _extractPoints(Gpx gpx) {
    final fromTracks = _pointsFromTracks(gpx);
    if (fromTracks.isNotEmpty) {
      if (fromTracks.length < 2) {
        return const Result.failure(
          GpxFailure(code: GpxFailureCode.tooFewPoints),
        );
      }
      return Result.success(fromTracks);
    }

    final fromRoutes = _pointsFromRoutes(gpx);
    if (fromRoutes.isNotEmpty) {
      if (fromRoutes.length < 2) {
        return const Result.failure(
          GpxFailure(code: GpxFailureCode.tooFewPoints),
        );
      }
      return Result.success(fromRoutes);
    }

    final fromWaypoints = _pointsFromWaypoints(gpx);
    if (fromWaypoints.isNotEmpty) {
      if (fromWaypoints.length < 2) {
        return const Result.failure(
          GpxFailure(code: GpxFailureCode.tooFewPoints),
        );
      }
      return Result.success(fromWaypoints);
    }

    return const Result.failure(
      GpxFailure(code: GpxFailureCode.noGeometry),
    );
  }

  static List<GpxPoint> _pointsFromTracks(Gpx gpx) {
    final points = <GpxPoint>[];
    for (final trk in gpx.trks) {
      for (final seg in trk.trksegs) {
        for (final pt in seg.trkpts) {
          try {
            points.add(_wptToGpxPoint(pt));
          } on FormatException {
            continue;
          }
        }
      }
    }
    return points;
  }

  static List<GpxPoint> _pointsFromRoutes(Gpx gpx) {
    final points = <GpxPoint>[];
    for (final rte in gpx.rtes) {
      for (final pt in rte.rtepts) {
        try {
          points.add(_wptToGpxPoint(pt));
        } on FormatException {
          continue;
        }
      }
    }
    return points;
  }

  static List<GpxPoint> _pointsFromWaypoints(Gpx gpx) {
    final points = <GpxPoint>[];
    for (final wpt in gpx.wpts) {
      try {
        points.add(_wptToGpxPoint(wpt));
      } on FormatException {
        continue;
      }
    }
    return points;
  }
}
