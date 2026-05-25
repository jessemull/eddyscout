import 'package:freezed_annotation/freezed_annotation.dart';

part 'launch_models.freezed.dart';
part 'launch_models.g.dart';

/// River system for UI copy and which condition products apply.
enum RiverSystem {
  /// Willamette mainstem and Portland pool.
  willamette,

  /// Lower Columbia and estuary-influenced sites.
  columbia,

  /// Clackamas tributary launches.
  clackamas,

  /// Slough / backwater (e.g. Smith & Bybee).
  slough,
}

/// Static wind exposure at the put-in (not from live weather).
enum WindExposure {
  /// Protected from fetch; light chop typical.
  sheltered,

  /// Partial exposure; gusts possible.
  moderate,

  /// Open fetch or wide river; wind is a primary hazard.
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

/// Human-readable labels for [WindExposure] in UI chips and legends.
extension WindExposureLabel on WindExposure {
  /// Short label for filters and launch detail headers.
  String get label => switch (this) {
    WindExposure.sheltered => 'Sheltered',
    WindExposure.moderate => 'Moderate exposure',
    WindExposure.exposed => 'Exposed',
  };
}

/// Human-readable labels for [TideRelevance] in UI chips and legends.
extension TideRelevanceLabel on TideRelevance {
  /// Compact tide section title for launch detail.
  String get shortLabel => switch (this) {
    TideRelevance.none => 'Tide: not shown',
    TideRelevance.minor => 'Tide: reference only',
    TideRelevance.major => 'Tide',
  };
}

/// Editorial cfs bands for go/no-go flow rules tied to the gauge at this launch.
///
/// Replaces [RiverSystem] fallbacks when non-null; tune with local experts.
@freezed
abstract class LaunchFlowBands with _$LaunchFlowBands {
  /// Creates flow thresholds for a single USGS or editorial gauge context.
  const factory LaunchFlowBands({
    /// Below this cfs → marginal (low-water / strainer risk cue).
    double? cfsMarginalBelow,

    /// At or above → marginal (high, pushy water for this stretch).
    double? cfsComfortMax,

    /// At or above → no-go (planning hint).
    double? cfsNoGoAbove,
  }) = _LaunchFlowBands;

  /// Parses bands from JSON (e.g. cached launch metadata).
  factory LaunchFlowBands.fromJson(Map<String, dynamic> json) =>
      _$LaunchFlowBandsFromJson(json);
}

/// Editorial bands for USGS 14211720 (Willamette at Portland).
const LaunchFlowBands kFlowBandsUsgs14211720WillamettePortland =
    LaunchFlowBands(
      cfsMarginalBelow: 2500,
      cfsComfortMax: 23000,
      cfsNoGoAbove: 38000,
    );

/// Editorial bands for USGS 14211010 (Clackamas near Oregon City).
const LaunchFlowBands kFlowBandsUsgs14211010ClackamasNearOc = LaunchFlowBands(
  cfsMarginalBelow: 600,
  cfsComfortMax: 9500,
  cfsNoGoAbove: 18000,
);

/// Editorial bands for USGS 14137000 (Sandy at Troutdale).
const LaunchFlowBands kFlowBandsUsgs14137000SandyTroutdale = LaunchFlowBands(
  cfsMarginalBelow: 150,
  cfsComfortMax: 6500,
  cfsNoGoAbove: 12000,
);

/// Editorial bands for USGS 14144700 (Columbia at Vancouver).
///
/// No low-flow marginal band — Columbia volume stays high at this gauge.
const LaunchFlowBands kFlowBandsUsgs14144700ColumbiaVancouver = LaunchFlowBands(
  cfsComfortMax: 400000,
  cfsNoGoAbove: 550000,
);

/// Curated kayak / small-craft access point with API linkage metadata.
@freezed
abstract class LaunchPoint with _$LaunchPoint {
  /// Creates a launch used across map, conditions, and routing features.
  const factory LaunchPoint({
    /// Stable id for routing, reports, and deep links.
    required String id,

    /// Display name on map pins and detail screens.
    required String name,

    /// WGS84 latitude for map camera and distance checks.
    required double latitude,

    /// WGS84 longitude for map camera and distance checks.
    required double longitude,

    /// One-line editorial note shown on launch detail.
    required String shortNote,

    /// Drives which hydrology products and copy templates apply.
    required RiverSystem riverSystem,

    /// Static exposure used when live wind is unavailable or ambiguous.
    required WindExposure windExposure,

    /// Whether and how strongly to surface tide predictions.
    required TideRelevance tideRelevance,

    /// NOAA CO-OPS station id when [tideRelevance] is not [TideRelevance.none].
    String? noaaTideStationId,

    /// NWS marine forecast zone (e.g. PZZ210); null when not applicable.
    String? marineZoneId,

    /// USGS NWIS site number for discharge/stage when curated.
    String? usgsSiteId,

    /// When set, flow rules use these bands instead of [RiverSystem] defaults.
    LaunchFlowBands? flowBands,
  }) = _LaunchPoint;

  /// Parses a launch from JSON (e.g. bundled catalog export).
  factory LaunchPoint.fromJson(Map<String, dynamic> json) =>
      _$LaunchPointFromJson(json);
}
