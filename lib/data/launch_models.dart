/// River system for UI copy and which condition products apply.
enum RiverSystem {
  willamette,
  columbia,
  clackamas,
  slough,
}

/// Static wind exposure at the put-in (not from live weather).
enum WindExposure {
  sheltered,
  moderate,
  exposed,
}

/// How much Columbia estuary tide matters at this site.
enum TideRelevance {
  /// No tide block; pool stage may still lag Columbia far upstream.
  none,

  /// Show reference station with short caveat (e.g. upper Willamette pool).
  minor,

  /// Show tide predictions prominently (estuary / confluence / lower Columbia).
  major,
}

extension WindExposureLabel on WindExposure {
  String get label => switch (this) {
        WindExposure.sheltered => 'Sheltered',
        WindExposure.moderate => 'Moderate exposure',
        WindExposure.exposed => 'Exposed',
      };
}

extension TideRelevanceLabel on TideRelevance {
  String get shortLabel => switch (this) {
        TideRelevance.none => 'Tide: not shown',
        TideRelevance.minor => 'Tide: reference only',
        TideRelevance.major => 'Tide',
      };
}

/// Curated kayak / small-craft access point with API linkage metadata.
class LaunchPoint {
  const LaunchPoint({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.shortNote,
    required this.riverSystem,
    required this.windExposure,
    required this.tideRelevance,
    this.noaaTideStationId,
    this.marineZoneId,
    this.usgsSiteId,
  });

  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final String shortNote;
  final RiverSystem riverSystem;
  final WindExposure windExposure;
  final TideRelevance tideRelevance;

  /// NOAA CO-OPS station id when [tideRelevance] is not [TideRelevance.none].
  final String? noaaTideStationId;

  /// NWS marine forecast zone (e.g. PZZ210); null when not applicable.
  final String? marineZoneId;

  /// USGS NWIS site number for discharge/stage when curated.
  final String? usgsSiteId;
}
