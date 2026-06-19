import 'package:eddyscout_conditions/src/domain/conditions_models.dart';
import 'package:eddyscout_conditions/src/domain/go_no_go_thresholds.dart';
import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'go_no_go.freezed.dart';
part 'go_no_go.g.dart';

/// User skill profile; maps to [GoNoGoThresholds] wind tiers.
enum GoNoGoProfile {
  /// Conservative wind and flow bands.
  beginner,

  /// Default planning bands.
  intermediate,

  /// More lenient wind bands for experienced paddlers.
  advanced,
}

/// Resolves stored skill profile to threshold constants.
extension GoNoGoProfileThresholds on GoNoGoProfile {
  /// Threshold set for this profile.
  GoNoGoThresholds get thresholds => switch (this) {
    GoNoGoProfile.beginner => GoNoGoThresholds.beginner,
    GoNoGoProfile.intermediate => GoNoGoThresholds.intermediate,
    GoNoGoProfile.advanced => GoNoGoThresholds.advanced,
  };
}

/// Planning verdict from deterministic rules (not a safety guarantee).
enum GoNoGoVerdict {
  /// Conditions look acceptable for a planning hint.
  go,

  /// At least one marginal trigger; verify locally.
  marginal,

  /// At least one no-go trigger; verify locally.
  noGo,

  /// Weather missing so wind cannot be assessed.
  insufficientData,
}

/// Machine-readable go/no-go reason codes.
///
/// UI must localize via generated localization strings.
enum GoNoGoReasonCode {
  /// Cold-water season safety reminder (Nov–Apr).
  @JsonValue('cold_water_season')
  coldWaterSeason,

  /// Weather data unavailable for wind assessment.
  @JsonValue('weather_missing')
  weatherMissing,

  /// Wind speed/gust missing from forecast.
  @JsonValue('wind_unknown')
  windUnknown,

  /// Effective wind at or above no-go threshold.
  @JsonValue('wind_high')
  windHigh,

  /// Effective wind at or above marginal threshold.
  @JsonValue('wind_elevated')
  windElevated,

  /// Marine forecast text matches a severe pattern.
  @JsonValue('marine_severe')
  marineSevere,

  /// Marine forecast text matches an advisory pattern.
  @JsonValue('marine_advisory')
  marineAdvisory,

  /// Forecast period starts during low-light hours.
  @JsonValue('forecast_low_light_hours')
  forecastLowLightHours,

  /// Discharge at or above no-go flow band.
  @JsonValue('flow_very_high')
  flowVeryHigh,

  /// Discharge at or above elevated flow band.
  @JsonValue('flow_high')
  flowHigh,

  /// Discharge below launch low-flow cue.
  @JsonValue('flow_low')
  flowLow,
}

/// How a single reason affects the aggregated verdict.
enum GoNoGoReasonSeverity {
  /// Shown in list; does not elevate verdict.
  info,

  /// Contributes to [GoNoGoVerdict.marginal] when no no-go triggers.
  marginal,

  /// Contributes to [GoNoGoVerdict.noGo].
  noGo,
}

/// One typed explanation for a go/no-go outcome.
@freezed
abstract class GoNoGoReason with _$GoNoGoReason {
  /// Creates a stable-coded reason line.
  const factory GoNoGoReason({
    /// Machine-readable reason id for analytics and tests.
    required GoNoGoReasonCode code,

    /// How this reason affects [GoNoGoVerdict].
    required GoNoGoReasonSeverity severity,

    /// Effective wind in mph
    /// ([GoNoGoReasonCode.windHigh], [GoNoGoReasonCode.windElevated]).
    int? windMph,

    /// Wind exposure label, lowercased
    /// ([GoNoGoReasonCode.windHigh], [GoNoGoReasonCode.windElevated]).
    String? exposure,

    /// Matched marine forecast phrase
    /// ([GoNoGoReasonCode.marineSevere], [GoNoGoReasonCode.marineAdvisory]).
    String? pattern,

    /// Formatted discharge
    /// ([GoNoGoReasonCode.flowVeryHigh], [GoNoGoReasonCode.flowHigh],
    /// [GoNoGoReasonCode.flowLow]).
    String? cfs,

    /// USGS site id for flow readings.
    String? siteId,

    /// Weather fetch error code ([GoNoGoReasonCode.weatherMissing]).
    String? weatherError,

    /// True when flow bands come from launch-specific [LaunchFlowBands].
    bool? usesLaunchFlowBands,
  }) = _GoNoGoReason;

  /// Parses a reason from JSON.
  factory GoNoGoReason.fromJson(Map<String, dynamic> json) =>
      _$GoNoGoReasonFromJson(json);
}

/// Verdict plus supporting reasons for one evaluation pass.
@freezed
abstract class GoNoGoResult with _$GoNoGoResult {
  /// Creates an evaluation result.
  const factory GoNoGoResult({
    required GoNoGoVerdict verdict,
    required List<GoNoGoReason> reasons,
    required DateTime computedAt,
  }) = _GoNoGoResult;

  /// Parses an evaluation result from JSON.
  factory GoNoGoResult.fromJson(Map<String, dynamic> json) =>
      _$GoNoGoResultFromJson(json);
}

/// Deterministic go / marginal / no-go from [LaunchPoint] + [ConditionsSnapshot].
class GoNoGoEvaluator {
  GoNoGoEvaluator._();

  /// Evaluates rules for one launch and conditions snapshot.
  static GoNoGoResult evaluate(
    LaunchPoint launch,
    ConditionsSnapshot snapshot, {
    GoNoGoProfile profile = GoNoGoProfile.intermediate,
    DateTime? now,
    GoNoGoThresholds? thresholds,
  }) {
    final t = thresholds ?? profile.thresholds;
    final effectiveNow = now ?? DateTime.now();
    final reasons = <GoNoGoReason>[];

    if (coldWaterSeasonMonths.contains(effectiveNow.month)) {
      reasons.add(
        const GoNoGoReason(
          code: GoNoGoReasonCode.coldWaterSeason,
          severity: GoNoGoReasonSeverity.info,
        ),
      );
    }

    final weatherMissing = snapshot.weather == null;
    if (weatherMissing) {
      reasons.add(
        GoNoGoReason(
          code: GoNoGoReasonCode.weatherMissing,
          severity: GoNoGoReasonSeverity.info,
          weatherError: snapshot.weatherError,
        ),
      );
    } else {
      final w = snapshot.weather!;
      _applyWind(launch.windExposure, w, t, reasons);
      _maybeAddForecastTimeInfo(w, reasons);
    }

    if (launch.marineZoneId != null &&
        snapshot.marine != null &&
        snapshot.marine!.periods.isNotEmpty) {
      _applyMarine(snapshot.marine!, reasons);
    }

    if (snapshot.riverFlow != null) {
      _applyFlow(launch, snapshot.riverFlow!, reasons);
    }

    final verdict = _aggregateVerdict(
      weatherMissing: weatherMissing,
      reasons: reasons,
    );

    return GoNoGoResult(
      verdict: verdict,
      reasons: reasons,
      computedAt: effectiveNow,
    );
  }

  static void _applyWind(
    WindExposure exposure,
    WeatherConditions w,
    GoNoGoThresholds t,
    List<GoNoGoReason> reasons,
  ) {
    final eff = _effectiveWindMph(w);
    if (eff == null) {
      reasons.add(
        const GoNoGoReason(
          code: GoNoGoReasonCode.windUnknown,
          severity: GoNoGoReasonSeverity.marginal,
        ),
      );
      return;
    }

    final (marginalAt, noGoAt) = t.windMphForExposure(exposure);
    if (eff >= noGoAt) {
      reasons.add(
        GoNoGoReason(
          code: GoNoGoReasonCode.windHigh,
          severity: GoNoGoReasonSeverity.noGo,
          windMph: eff,
          exposure: exposure.label.toLowerCase(),
        ),
      );
    } else if (eff >= marginalAt) {
      reasons.add(
        GoNoGoReason(
          code: GoNoGoReasonCode.windElevated,
          severity: GoNoGoReasonSeverity.marginal,
          windMph: eff,
          exposure: exposure.label.toLowerCase(),
        ),
      );
    }
  }

  static int? _effectiveWindMph(WeatherConditions w) {
    final a = w.windSpeedMph;
    final b = w.windGustMph;
    if (a == null && b == null) return null;
    if (a == null) return b;
    if (b == null) return a;
    return a > b ? a : b;
  }

  static void _applyMarine(MarineSummary marine, List<GoNoGoReason> reasons) {
    final buf = StringBuffer();
    var n = 0;
    for (final p in marine.periods) {
      if (n >= marineTextScanMaxChars) break;
      buf
        ..write(p.detailedForecast)
        ..write(' ');
      n = buf.length;
      if (n >= marineTextScanMaxChars) break;
    }
    var text = buf.toString().toLowerCase();
    if (text.length > marineTextScanMaxChars) {
      text = text.substring(0, marineTextScanMaxChars);
    }

    for (final pattern in marineTextNoGoPatterns) {
      if (text.contains(pattern)) {
        reasons.add(
          GoNoGoReason(
            code: GoNoGoReasonCode.marineSevere,
            severity: GoNoGoReasonSeverity.noGo,
            pattern: pattern,
          ),
        );
        return;
      }
    }
    for (final pattern in marineTextMarginalPatterns) {
      if (text.contains(pattern)) {
        reasons.add(
          GoNoGoReason(
            code: GoNoGoReasonCode.marineAdvisory,
            severity: GoNoGoReasonSeverity.marginal,
            pattern: pattern,
          ),
        );
        return;
      }
    }
  }

  /// Info when forecast period start is during typical low-light hours.
  static void _maybeAddForecastTimeInfo(
    WeatherConditions w,
    List<GoNoGoReason> reasons,
  ) {
    final start = w.periodStart;
    if (start == null) return;
    final local = start.toLocal();
    final h = local.hour;
    if (h >= 20 || h < 6) {
      reasons.add(
        const GoNoGoReason(
          code: GoNoGoReasonCode.forecastLowLightHours,
          severity: GoNoGoReasonSeverity.info,
        ),
      );
    }
  }

  static void _applyFlow(
    LaunchPoint launch,
    RiverFlowReading reading,
    List<GoNoGoReason> reasons,
  ) {
    final cfs = reading.cfs;
    final bands = launch.flowBands;
    if (bands != null) {
      final noGoAt = bands.cfsNoGoAbove;
      final comfortMax = bands.cfsComfortMax;
      final lowMarginal = bands.cfsMarginalBelow;
      if (noGoAt != null && cfs >= noGoAt) {
        reasons.add(
          GoNoGoReason(
            code: GoNoGoReasonCode.flowVeryHigh,
            severity: GoNoGoReasonSeverity.noGo,
            cfs: _cfsShort(cfs),
            siteId: reading.siteId,
            usesLaunchFlowBands: true,
          ),
        );
        return;
      }
      if (comfortMax != null && cfs >= comfortMax) {
        reasons.add(
          GoNoGoReason(
            code: GoNoGoReasonCode.flowHigh,
            severity: GoNoGoReasonSeverity.marginal,
            cfs: _cfsShort(cfs),
            siteId: reading.siteId,
            usesLaunchFlowBands: true,
          ),
        );
        return;
      }
      if (lowMarginal != null && cfs < lowMarginal) {
        reasons.add(
          GoNoGoReason(
            code: GoNoGoReasonCode.flowLow,
            severity: GoNoGoReasonSeverity.marginal,
            cfs: _cfsShort(cfs),
            siteId: reading.siteId,
            usesLaunchFlowBands: true,
          ),
        );
      }
      return;
    }

    final band = RiverFlowThresholds.forRiverSystem(launch.riverSystem);
    final noGoAt = band.noGoCfs;
    final marginalAt = band.marginalCfs;
    if (noGoAt != null && cfs >= noGoAt) {
      reasons.add(
        GoNoGoReason(
          code: GoNoGoReasonCode.flowVeryHigh,
          severity: GoNoGoReasonSeverity.noGo,
          cfs: _cfsShort(cfs),
          siteId: reading.siteId,
          usesLaunchFlowBands: false,
        ),
      );
    } else if (marginalAt != null && cfs >= marginalAt) {
      reasons.add(
        GoNoGoReason(
          code: GoNoGoReasonCode.flowHigh,
          severity: GoNoGoReasonSeverity.marginal,
          cfs: _cfsShort(cfs),
          siteId: reading.siteId,
          usesLaunchFlowBands: false,
        ),
      );
    }
  }

  static String _cfsShort(double v) {
    final r = v.round();
    if (r >= 10000) return '${(r / 1000).toStringAsFixed(0)}k';
    return '$r';
  }

  /// Any [GoNoGoReasonSeverity.noGo] reason wins.
  ///
  /// If weather was missing, returns [GoNoGoVerdict.insufficientData] unless a
  /// no-go fired. Otherwise marginal if any marginal reason; else go.
  static GoNoGoVerdict _aggregateVerdict({
    required bool weatherMissing,
    required List<GoNoGoReason> reasons,
  }) {
    final hasNoGo = reasons.any((r) => r.severity == GoNoGoReasonSeverity.noGo);
    if (hasNoGo) return GoNoGoVerdict.noGo;

    if (weatherMissing) {
      return GoNoGoVerdict.insufficientData;
    }

    final hasMarginal = reasons.any(
      (r) => r.severity == GoNoGoReasonSeverity.marginal,
    );
    if (hasMarginal) return GoNoGoVerdict.marginal;

    return GoNoGoVerdict.go;
  }
}
