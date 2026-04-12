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

/// Editorial cfs bands for [GoNoGoEvaluator] tied to the gauge at this launch.
/// Replaces [RiverSystem] fallbacks when non-null; tune with local experts.
class LaunchFlowBands {
  const LaunchFlowBands({
    this.cfsMarginalBelow,
    this.cfsComfortMax,
    this.cfsNoGoAbove,
  });

  /// Below this cfs → marginal (low-water / strainer risk cue).
  final double? cfsMarginalBelow;

  /// At or above → marginal (high, pushy water for this stretch).
  final double? cfsComfortMax;

  /// At or above → no-go (planning hint).
  final double? cfsNoGoAbove;
}

/// Shared bands for launches using the same USGS site (editorial placeholders).
const LaunchFlowBands kFlowBandsUsgs14211720WillamettePortland = LaunchFlowBands(
  cfsMarginalBelow: 2500,
  cfsComfortMax: 23000,
  cfsNoGoAbove: 38000,
);

const LaunchFlowBands kFlowBandsUsgs14211010ClackamasNearOc = LaunchFlowBands(
  cfsMarginalBelow: 600,
  cfsComfortMax: 9500,
  cfsNoGoAbove: 18000,
);

const LaunchFlowBands kFlowBandsUsgs14137000SandyTroutdale = LaunchFlowBands(
  cfsMarginalBelow: 150,
  cfsComfortMax: 6500,
  cfsNoGoAbove: 12000,
);

const LaunchFlowBands kFlowBandsUsgs14144700ColumbiaVancouver = LaunchFlowBands(
  cfsMarginalBelow: null,
  cfsComfortMax: 400000,
  cfsNoGoAbove: 550000,
);

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
    this.flowBands,
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

  /// When set, flow rules use these bands instead of [RiverSystem] defaults.
  final LaunchFlowBands? flowBands;
}
