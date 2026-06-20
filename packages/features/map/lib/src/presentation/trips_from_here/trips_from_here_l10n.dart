import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_hydro_routing/eddyscout_hydro_routing.dart';
import 'package:eddyscout_localization/eddyscout_localization.dart';

/// Localized river system label for launch rows and peek chrome.
String mapLaunchRiverLabel(AppLocalizations l10n, RiverSystem river) {
  return switch (river) {
    RiverSystem.willamette => l10n.launchDetailRiverWillamette,
    RiverSystem.columbia => l10n.launchDetailRiverColumbia,
    RiverSystem.clackamas => l10n.launchDetailRiverClackamas,
    RiverSystem.slough => l10n.launchDetailRiverSlough,
  };
}

/// Localized label for a [ReachabilityBand].
String reachabilityBandLabel(AppLocalizations l10n, ReachabilityBand band) {
  return switch (band) {
    ReachabilityBand.within5Mi => l10n.tripsFromHereBand5Mi,
    ReachabilityBand.within10Mi => l10n.tripsFromHereBand10Mi,
    ReachabilityBand.within20Mi => l10n.tripsFromHereBand20Mi,
  };
}

/// Localized empty message for a [ReachabilityBand].
String reachabilityBandEmptyMessage(
  AppLocalizations l10n,
  ReachabilityBand band,
) {
  return switch (band) {
    ReachabilityBand.within5Mi => l10n.tripsFromHereBandEmpty5Mi,
    ReachabilityBand.within10Mi => l10n.tripsFromHereBandEmpty10Mi,
    ReachabilityBand.within20Mi => l10n.tripsFromHereBandEmpty20Mi,
  };
}

/// Semantics label for a band header with [count] launches.
String reachabilityBandSemanticsLabel(
  AppLocalizations l10n,
  ReachabilityBand band,
  int count,
) {
  return l10n.tripsFromHereBandSemantics(
    reachabilityBandLabel(l10n, band),
    count,
  );
}
