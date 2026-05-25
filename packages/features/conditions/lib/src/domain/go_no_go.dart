import 'package:freezed_annotation/freezed_annotation.dart';

import 'conditions_models.dart';
import 'package:eddyscout_map/eddyscout_map.dart';
import 'go_no_go_thresholds.dart';

part 'go_no_go.freezed.dart';
part 'go_no_go.g.dart';

/// User skill profile; maps to [GoNoGoThresholds] wind tiers.
enum GoNoGoProfile { beginner, intermediate, advanced }

extension GoNoGoProfileThresholds on GoNoGoProfile {
  GoNoGoThresholds get thresholds => switch (this) {
    GoNoGoProfile.beginner => GoNoGoThresholds.beginner,
    GoNoGoProfile.intermediate => GoNoGoThresholds.intermediate,
    GoNoGoProfile.advanced => GoNoGoThresholds.advanced,
  };
}

/// Planning verdict from deterministic rules (not a safety guarantee).
enum GoNoGoVerdict { go, marginal, noGo, insufficientData }

extension GoNoGoVerdictUi on GoNoGoVerdict {
  String get headline => switch (this) {
    GoNoGoVerdict.go => 'Go (planning hint)',
    GoNoGoVerdict.marginal => 'Marginal',
    GoNoGoVerdict.noGo => 'No-go (planning hint)',
    GoNoGoVerdict.insufficientData => 'Insufficient data',
  };
}

enum GoNoGoReasonSeverity {
  /// Shown in list; does not elevate verdict.
  info,

  /// Contributes to [GoNoGoVerdict.marginal] when no no-go triggers.
  marginal,

  /// Contributes to [GoNoGoVerdict.noGo].
  noGo,
}

@freezed
abstract class GoNoGoReason with _$GoNoGoReason {
  const factory GoNoGoReason({
    required String code,
    required String message,
    required GoNoGoReasonSeverity severity,
  }) = _GoNoGoReason;

  factory GoNoGoReason.fromJson(Map<String, dynamic> json) =>
      _$GoNoGoReasonFromJson(json);
}

@freezed
abstract class GoNoGoResult with _$GoNoGoResult {
  const factory GoNoGoResult({
    required GoNoGoVerdict verdict,
    required List<GoNoGoReason> reasons,
    required DateTime computedAt,
  }) = _GoNoGoResult;

  factory GoNoGoResult.fromJson(Map<String, dynamic> json) =>
      _$GoNoGoResultFromJson(json);
}

/// Deterministic go / marginal / no-go from [LaunchPoint] + [ConditionsSnapshot].
class GoNoGoEvaluator {
  GoNoGoEvaluator._();

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
          code: 'cold_water_season',
          message:
              'Cold-water season in the PNW—dress for immersion, know hypothermia risk, and carry safety gear.',
          severity: GoNoGoReasonSeverity.info,
        ),
      );
    }

    final weatherMissing = snapshot.weather == null;
    if (weatherMissing) {
      reasons.add(
        GoNoGoReason(
          code: 'weather_missing',
          message: snapshot.weatherError != null
              ? 'Weather data failed to load (${snapshot.weatherError}). Cannot assess wind from forecast.'
              : 'Weather data was not available. Cannot assess wind from forecast.',
          severity: GoNoGoReasonSeverity.info,
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
          code: 'wind_unknown',
          message:
              'Wind speed or gust was not available from the forecast—use caution, especially in open or exposed areas.',
          severity: GoNoGoReasonSeverity.marginal,
        ),
      );
      return;
    }

    final (marginalAt, noGoAt) = t.windMphForExposure(exposure);
    if (eff >= noGoAt) {
      reasons.add(
        GoNoGoReason(
          code: 'wind_high',
          message:
              'Effective wind about $eff mph (${exposure.label.toLowerCase()} site)—our stub rules treat this as strong for paddling.',
          severity: GoNoGoReasonSeverity.noGo,
        ),
      );
    } else if (eff >= marginalAt) {
      reasons.add(
        GoNoGoReason(
          code: 'wind_elevated',
          message:
              'Effective wind about $eff mph (${exposure.label.toLowerCase()} site)—conditions may feel rougher on open water.',
          severity: GoNoGoReasonSeverity.marginal,
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
      buf.write(p.detailedForecast);
      buf.write(' ');
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
            code: 'marine_severe',
            message:
                'Marine forecast text mentions “$pattern”—treat as hazardous until you verify locally.',
            severity: GoNoGoReasonSeverity.noGo,
          ),
        );
        return;
      }
    }
    for (final pattern in marineTextMarginalPatterns) {
      if (text.contains(pattern)) {
        reasons.add(
          GoNoGoReason(
            code: 'marine_advisory',
            message:
                'Marine forecast includes “$pattern”—expect rougher water, current, or advisories near the estuary/coast.',
            severity: GoNoGoReasonSeverity.marginal,
          ),
        );
        return;
      }
    }
  }

  /// Info when the forecast period start falls in typical low-light local hours.
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
          code: 'forecast_low_light_hours',
          message:
              'This forecast period starts during typical low-light hours locally—verify visibility, hazards, and your comfort paddling after dark.',
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
            code: 'flow_very_high',
            message:
                'Discharge about ${_cfsShort(cfs)} cfs at site ${reading.siteId}—above this launch’s curated upper band; verify hazards and skill match.',
            severity: GoNoGoReasonSeverity.noGo,
          ),
        );
        return;
      }
      if (comfortMax != null && cfs >= comfortMax) {
        reasons.add(
          GoNoGoReason(
            code: 'flow_high',
            message:
                'Discharge about ${_cfsShort(cfs)} cfs at site ${reading.siteId}—at or above this launch’s “elevated flow” band; double-check strainers and current.',
            severity: GoNoGoReasonSeverity.marginal,
          ),
        );
        return;
      }
      if (lowMarginal != null && cfs < lowMarginal) {
        reasons.add(
          GoNoGoReason(
            code: 'flow_low',
            message:
                'Discharge about ${_cfsShort(cfs)} cfs at site ${reading.siteId}—below this launch’s low-flow cue; watch for shallow spots and wood.',
            severity: GoNoGoReasonSeverity.marginal,
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
          code: 'flow_very_high',
          message:
              'Discharge about ${_cfsShort(cfs)} cfs at site ${reading.siteId}—stub upper band for this river class suggests very high water; verify hazards and skill match.',
          severity: GoNoGoReasonSeverity.noGo,
        ),
      );
    } else if (marginalAt != null && cfs >= marginalAt) {
      reasons.add(
        GoNoGoReason(
          code: 'flow_high',
          message:
              'Discharge about ${_cfsShort(cfs)} cfs at site ${reading.siteId}—above our placeholder “elevated” band for this river class; double-check strainers and current.',
          severity: GoNoGoReasonSeverity.marginal,
        ),
      );
    }
  }

  static String _cfsShort(double v) {
    final r = v.round();
    if (r >= 10000) return '${(r / 1000).toStringAsFixed(0)}k';
    return '$r';
  }

  /// Any [noGo] reason wins. If weather was missing, [insufficientData] unless a no-go fired.
  /// Otherwise [marginal] if any marginal reason; else [go].
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
