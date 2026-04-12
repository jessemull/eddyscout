import '../data/launch_models.dart';

/// Tunable thresholds for [GoNoGoEvaluator]. Values are **placeholders**—tune with
/// local experts; river cfs uses coarse [RiverSystem] bands until per-gauge data exists.

/// Intermediate paddler profile (default v1).
class GoNoGoThresholds {
  const GoNoGoThresholds({
    required this.windMarginalShelteredMph,
    required this.windNoGoShelteredMph,
    required this.windMarginalModerateMph,
    required this.windNoGoModerateMph,
    required this.windMarginalExposedMph,
    required this.windNoGoExposedMph,
  });

  /// Sheltered ramp: allow higher wind before flagging.
  final int windMarginalShelteredMph;
  final int windNoGoShelteredMph;

  /// Moderate exposure.
  final int windMarginalModerateMph;
  final int windNoGoModerateMph;

  /// Open fetch / exposed.
  final int windMarginalExposedMph;
  final int windNoGoExposedMph;

  /// Default “intermediate” comfort bands.
  static const GoNoGoThresholds intermediate = GoNoGoThresholds(
    windMarginalShelteredMph: 22,
    windNoGoShelteredMph: 36,
    windMarginalModerateMph: 15,
    windNoGoModerateMph: 28,
    windMarginalExposedMph: 10,
    windNoGoExposedMph: 20,
  );

  (int marginal, int noGo) windMphForExposure(WindExposure e) => switch (e) {
        WindExposure.sheltered => (windMarginalShelteredMph, windNoGoShelteredMph),
        WindExposure.moderate => (windMarginalModerateMph, windNoGoModerateMph),
        WindExposure.exposed => (windMarginalExposedMph, windNoGoExposedMph),
      };
}

/// Upper (flood-style) cfs hints by river class—**not** survey-grade.
/// Only [marginalCfs] / [noGoCfs] when above; no low-water rule in v1.
class RiverFlowThresholds {
  const RiverFlowThresholds({this.marginalCfs, this.noGoCfs});

  final double? marginalCfs;
  final double? noGoCfs;

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
