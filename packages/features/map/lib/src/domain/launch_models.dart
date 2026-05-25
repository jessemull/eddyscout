import 'package:freezed_annotation/freezed_annotation.dart';

part 'launch_models.freezed.dart';
part 'launch_models.g.dart';

/// River system for UI copy and which condition products apply.
enum RiverSystem { willamette, columbia, clackamas, slough }

/// Static wind exposure at the put-in (not from live weather).
enum WindExposure { sheltered, moderate, exposed }

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

/// Editorial cfs bands for go/no-go flow rules tied to the gauge at this launch.
/// Replaces [RiverSystem] fallbacks when non-null; tune with local experts.
@freezed
abstract class LaunchFlowBands with _$LaunchFlowBands {
  const factory LaunchFlowBands({
    /// Below this cfs → marginal (low-water / strainer risk cue).
    double? cfsMarginalBelow,

    /// At or above → marginal (high, pushy water for this stretch).
    double? cfsComfortMax,

    /// At or above → no-go (planning hint).
    double? cfsNoGoAbove,
  }) = _LaunchFlowBands;

  factory LaunchFlowBands.fromJson(Map<String, dynamic> json) =>
      _$LaunchFlowBandsFromJson(json);
}

/// Shared bands for launches using the same USGS site (editorial placeholders).
const LaunchFlowBands kFlowBandsUsgs14211720WillamettePortland =
    LaunchFlowBands(
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
@freezed
abstract class LaunchPoint with _$LaunchPoint {
  const factory LaunchPoint({
    required String id,
    required String name,
    required double latitude,
    required double longitude,
    required String shortNote,
    required RiverSystem riverSystem,
    required WindExposure windExposure,
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

  factory LaunchPoint.fromJson(Map<String, dynamic> json) =>
      _$LaunchPointFromJson(json);
}
