import 'package:freezed_annotation/freezed_annotation.dart';

import '../data/launch_models.dart';

part 'go_no_go_thresholds.freezed.dart';

/// Tunable thresholds for [GoNoGoEvaluator]. Values are **placeholders**—tune with
/// local experts; river cfs uses coarse [RiverSystem] bands until per-gauge data exists.

/// Intermediate paddler profile (default v1).
@freezed
abstract class GoNoGoThresholds with _$GoNoGoThresholds {
  const factory GoNoGoThresholds({
    required int windMarginalShelteredMph,
    required int windNoGoShelteredMph,
    required int windMarginalModerateMph,
    required int windNoGoModerateMph,
    required int windMarginalExposedMph,
    required int windNoGoExposedMph,
  }) = _GoNoGoThresholds;

  /// Conservative bands for newer paddlers (flags wind sooner).
  static const GoNoGoThresholds beginner = GoNoGoThresholds(
    windMarginalShelteredMph: 15,
    windNoGoShelteredMph: 25,
    windMarginalModerateMph: 8,
    windNoGoModerateMph: 18,
    windMarginalExposedMph: 6,
    windNoGoExposedMph: 14,
  );

  /// Default comfort bands.
  static const GoNoGoThresholds intermediate = GoNoGoThresholds(
    windMarginalShelteredMph: 22,
    windNoGoShelteredMph: 36,
    windMarginalModerateMph: 15,
    windNoGoModerateMph: 28,
    windMarginalExposedMph: 10,
    windNoGoExposedMph: 20,
  );

  /// More lenient bands for experienced paddlers (still not a safety guarantee).
  static const GoNoGoThresholds advanced = GoNoGoThresholds(
    windMarginalShelteredMph: 28,
    windNoGoShelteredMph: 42,
    windMarginalModerateMph: 20,
    windNoGoModerateMph: 35,
    windMarginalExposedMph: 14,
    windNoGoExposedMph: 26,
  );
}

extension GoNoGoThresholdsWind on GoNoGoThresholds {
  (int marginal, int noGo) windMphForExposure(WindExposure e) => switch (e) {
    WindExposure.sheltered => (windMarginalShelteredMph, windNoGoShelteredMph),
    WindExposure.moderate => (windMarginalModerateMph, windNoGoModerateMph),
    WindExposure.exposed => (windMarginalExposedMph, windNoGoExposedMph),
  };
}

/// Upper (flood-style) cfs hints by river class—**not** survey-grade.
/// Only [marginalCfs] / [noGoCfs] when above; no low-water rule in v1.
@freezed
abstract class RiverFlowThresholds with _$RiverFlowThresholds {
  const factory RiverFlowThresholds({double? marginalCfs, double? noGoCfs}) =
      _RiverFlowThresholds;

  static RiverFlowThresholds forRiverSystem(RiverSystem r) => switch (r) {
    RiverSystem.willamette => const RiverFlowThresholds(
      marginalCfs: 24000,
      noGoCfs: 38000,
    ),
    RiverSystem.clackamas => const RiverFlowThresholds(
      marginalCfs: 12000,
      noGoCfs: 22000,
    ),
    RiverSystem.columbia => const RiverFlowThresholds(
      marginalCfs: 400000,
      noGoCfs: 550000,
    ),
    RiverSystem.slough => const RiverFlowThresholds(
      marginalCfs: 22000,
      noGoCfs: 36000,
    ),
  };
}

/// Longer phrases first so substrings match correctly.
final List<String> marineTextNoGoPatterns = [
  'hurricane force wind',
  'hurricane warning',
  'storm warning',
  'extreme wind',
];

final List<String> marineTextMarginalPatterns = [
  'small craft advisory',
  'small craft',
  'gale warning',
  'gale',
  'hazardous seas',
  'heavy freezing spray',
];

/// Months (1–12) treated as cold-water season for an extra **info** reason only.
const Set<int> coldWaterSeasonMonths = {11, 12, 1, 2, 3, 4};

/// Max characters of marine forecast text to scan (first periods concatenated).
const int marineTextScanMaxChars = 1200;
