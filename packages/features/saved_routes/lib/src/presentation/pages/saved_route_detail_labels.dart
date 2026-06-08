import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_localization/eddyscout_localization.dart';

/// Localized label for a [RouteDifficulty] value.
String savedRouteDifficultyLabel(AppLocalizations l10n, RouteDifficulty d) =>
    switch (d) {
      RouteDifficulty.easy => l10n.savedRoutesDifficultyEasy,
      RouteDifficulty.moderate => l10n.savedRoutesDifficultyModerate,
      RouteDifficulty.hard => l10n.savedRoutesDifficultyHard,
      RouteDifficulty.expert => l10n.savedRoutesDifficultyExpert,
    };

/// Localized label for a [RecommendedSkillLevel] value.
String savedRouteSkillLabel(AppLocalizations l10n, RecommendedSkillLevel s) =>
    switch (s) {
      RecommendedSkillLevel.beginner => l10n.launchDetailSkillBeginner,
      RecommendedSkillLevel.intermediate => l10n.launchDetailSkillIntermediate,
      RecommendedSkillLevel.advanced => l10n.launchDetailSkillAdvanced,
    };

/// Localized label for a [RouteCategory] value.
String savedRouteCategoryLabel(AppLocalizations l10n, RouteCategory category) =>
    switch (category) {
      RouteCategory.scenic => l10n.savedRoutesCategoryScenic,
      RouteCategory.training => l10n.savedRoutesCategoryTraining,
      RouteCategory.commute => l10n.savedRoutesCategoryCommute,
      RouteCategory.overnight => l10n.savedRoutesCategoryOvernight,
    };
