// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'EddyScout';

  @override
  String get mapScreenTitle => 'EddyScout';

  @override
  String get mapPlanRouteTooltip => 'Plan river route';

  @override
  String get mapExitPlanningTooltip => 'Exit route planning';

  @override
  String get mapZoomInLabel => 'Zoom in';

  @override
  String get mapZoomOutLabel => 'Zoom out';

  @override
  String get mapShowAllLaunchesLabel => 'Show all launches';

  @override
  String get mapZoomControlsSemantics => 'Map zoom controls';

  @override
  String get mapPickDifferentTakeOut => 'Pick a different launch for take-out.';

  @override
  String get mapRiverDataLoading => 'Still loading river data… try again.';

  @override
  String get mapRiverDataReadFailed => 'River route data could not be read.';

  @override
  String get mapRiverDataUnavailable => 'River route data is unavailable.';

  @override
  String get mapRouteFailureSameLaunch => 'Choose two different launches.';

  @override
  String get mapRouteFailureDifferentSystem =>
      'Pick two launches on the same river system for river routing.';

  @override
  String mapRouteFailureNoBundledLine(String river) {
    return 'No bundled river line for \"$river\" yet — routing is only available where hydro GeoJSON exists.';
  }

  @override
  String get mapRouteFailureNoData => 'River route data is not available yet.';

  @override
  String get mapRouteFailurePutInTooFar =>
      'Put-in is too far from the modeled river line. Try another launch.';

  @override
  String get mapRouteFailureTakeOutTooFar =>
      'Take-out is too far from the modeled river line. Try another launch.';

  @override
  String get mapRouteFailureNoConnectedPath =>
      'No connected river path between these points in the current data.';

  @override
  String get mapRouteFailureDisconnectedReach =>
      'Put-in and take-out are on different river segments in our bundled data. Try launches on the same reach.';

  @override
  String mapRouteFailureDisconnectedReachNamed(
    String putInReach,
    String takeOutReach,
  ) {
    return 'Put-in ($putInReach) and take-out ($takeOutReach) are on different bundled segments. Try launches on the same reach.';
  }

  @override
  String get mapPlanningStepPickPutIn => 'Step 1: Tap a launch for put-in.';

  @override
  String get mapPlanningStepPickTakeOut =>
      'Step 2: Tap another launch for take-out.';

  @override
  String get mapPlanningComputingRoute => 'Calculating route…';

  @override
  String mapPlanningRiverSystem(String system) {
    return 'River system: $system';
  }

  @override
  String mapPlanningRouteReach(String reachId) {
    return 'Bundled reach: $reachId';
  }

  @override
  String get mapPlanningSemanticsLabel => 'River route planning';

  @override
  String get mapPlanningTitleBeta => 'River route (beta)';

  @override
  String get mapPlanningInstructions =>
      'Tap a launch for put-in, then another for take-out. The line follows bundled open hydro data (approximate centerline)—not for navigation. Several downtown launches sit close together; overlapping pins are separate sites. Clear removes the route line and picks so you can start over. Done closes this panel and clears the route.';

  @override
  String mapPlanningPutInName(String name) {
    return 'Put-in: $name';
  }

  @override
  String mapPlanningTakeOutName(String name) {
    return 'Take-out: $name';
  }

  @override
  String mapPlanningRouteLengthKm(String km) {
    return 'Along river (estimate): $km km';
  }

  @override
  String get mapPlanningClearLabel => 'Clear';

  @override
  String get mapPlanningDoneLabel => 'Done';

  @override
  String get mapGpxExportLabel => 'Export GPX';

  @override
  String get mapGpxImportLabel => 'Import GPX';

  @override
  String get mapGpxExportSuccess => 'Route exported.';

  @override
  String get mapGpxImportSuccess => 'Track imported.';

  @override
  String get mapGpxExportNoRoute => 'Plan a route before exporting GPX.';

  @override
  String get mapGpxFailureEmptyInput => 'That GPX file is empty.';

  @override
  String get mapGpxFailureMalformed => 'Could not read that GPX file.';

  @override
  String get mapGpxFailureNoGeometry =>
      'No track or route found in that GPX file.';

  @override
  String get mapGpxFailureTooFewPoints => 'GPX needs at least two points.';

  @override
  String get mapGpxFailureFileRead => 'Could not read the GPX file.';

  @override
  String get mapGpxFailureFileWrite =>
      'Could not prepare the GPX file for sharing.';

  @override
  String get mapGpxFailureShare => 'Sharing is unavailable on this device.';

  @override
  String get mapGpxFailureGeneric => 'GPX action failed. Try again.';

  @override
  String get mapGpxFailureOutsidePnw =>
      'This track is outside our Pacific Northwest focus area.';

  @override
  String get mapGpxFailureLaunchSnapFailed =>
      'Put-in and take-out could not be matched to known launches.';

  @override
  String get commonDash => '—';

  @override
  String get commonBullet => '•';

  @override
  String get commonDotSeparator => ' · ';

  @override
  String get launchDetailConditionsErrorNetwork =>
      'Could not load conditions. Check your connection and try again.';

  @override
  String get launchDetailConditionsErrorGeneric =>
      'Could not load conditions. Pull to refresh or try again later.';

  @override
  String get launchDetailSkillProfileErrorGeneric =>
      'Could not load your skill profile. Restart the app or try again later.';

  @override
  String get launchDetailSkillSectionTitle => 'Skill (wind thresholds)';

  @override
  String launchDetailWindExposureSemantics(String label) {
    return 'Wind exposure $label';
  }

  @override
  String launchDetailRiverSemantics(String river) {
    return 'River $river';
  }

  @override
  String launchDetailTideRelevanceSemantics(String label) {
    return 'Tide $label';
  }

  @override
  String get launchDetailSkillBeginner => 'Beginner';

  @override
  String get launchDetailSkillIntermediate => 'Intermed.';

  @override
  String get launchDetailSkillAdvanced => 'Advanced';

  @override
  String get launchDetailReportSubmitError =>
      'Could not submit report. Try again in a moment.';

  @override
  String get launchDetailDigestError => 'Could not load digest. Try again.';

  @override
  String get launchDetailAiSummaryError =>
      'Could not load AI summary. Try again.';

  @override
  String get launchDetailReportConditionsTitle => 'Report conditions';

  @override
  String get launchDetailReportConditionsSubtitle =>
      'Short note to help others (stored securely)';

  @override
  String get launchDetailConditionsSection => 'Conditions';

  @override
  String get launchDetailDisclaimerTitle => 'Disclaimer';

  @override
  String get launchDetailDisclaimerBody =>
      'EddyScout shows third-party data for planning only. It is not a substitute for your judgment, skill assessment, or on-site scouting. River and marine conditions can change rapidly.';

  @override
  String get launchDetailDataSourcesTitle => 'Data sources';

  @override
  String get launchDetailFirebaseUnavailableIntro =>
      'Firebase did not start, so AI summary and reports are unavailable.';

  @override
  String get launchDetailFirebaseUnavailableBody =>
      'Firebase features need a successful app init and anonymous sign-in. Add google-services.json, enable Anonymous auth, deploy functions, and rebuild with USE_FIREBASE=true in .local.env (make run).';

  @override
  String launchDetailFirebaseErrorLabel(String error) {
    return 'Error: $error';
  }

  @override
  String get launchDetailFirebaseHintMissingNativeConfig =>
      'Add apps/eddyscout/android/app/google-services.json from Firebase Console. In a git worktree, run make dev to symlink from your main clone. Then stop the app fully and rebuild (not hot reload).';

  @override
  String get launchDetailFirebaseHintAnonymousAuth =>
      'Firebase is blocking anonymous sign-in. In Firebase Console open Authentication → Sign-in method → enable Anonymous → Save. If it is already on, open Authentication → Settings and ensure user sign-up is not disabled. Then stop the app fully and run make dev again (not hot reload).';

  @override
  String get launchDetailRiverWillamette => 'Willamette';

  @override
  String get launchDetailRiverColumbia => 'Columbia / regional';

  @override
  String get launchDetailRiverClackamas => 'Clackamas';

  @override
  String get launchDetailRiverSlough => 'Slough / confluence';

  @override
  String get launchDetailReportThanks => 'Thanks—report submitted.';

  @override
  String get launchDetailReportAddMessageFirst => 'Add a short message first.';

  @override
  String launchDetailReportsLoadError(String message) {
    return 'Could not load reports: $message';
  }

  @override
  String get launchDetailReportsUnauthHint =>
      'If this persists: fully stop the app and run again (not hot reload); confirm listConditionReports is deployed with Cloud Run invoker public (see firebase/DEPLOY.md); on emulators, use a Google Play system image.';

  @override
  String get launchDetailTimeJustNow => 'Just now';

  @override
  String launchDetailTimeMinutesAgo(int count) {
    return '${count}m ago';
  }

  @override
  String launchDetailTimeHoursAgo(int count) {
    return '${count}h ago';
  }

  @override
  String launchDetailTimeDaysAgo(int count) {
    return '${count}d ago';
  }

  @override
  String get launchDetailAttributionLaunchList =>
      'Launch list: curated for EddyScout (verify access locally).';

  @override
  String launchDetailAttributionWeather(String source) {
    return 'Weather: $source.';
  }

  @override
  String launchDetailAttributionTides(String station, String datum) {
    return 'Tides: NOAA CO-OPS (station $station, $datum).';
  }

  @override
  String launchDetailAttributionMarine(String zone) {
    return 'Marine: NWS zone $zone.';
  }

  @override
  String launchDetailAttributionFlow(String site) {
    return 'Flow: USGS NWIS (site $site).';
  }

  @override
  String get launchDetailAiSummaryTitle => 'AI summary';

  @override
  String get launchDetailAiSummaryVerifyHint =>
      'Verify against the raw data below—AI can misread or omit details.';

  @override
  String get launchDetailCommunityDigestTitle => 'Community digest (AI)';

  @override
  String get launchDetailCommunityDigestSubtitle =>
      'Paraphrases recent paddler notes below—not official conditions or river status.';

  @override
  String get launchDetailDigestNoReports =>
      'No paddler reports to summarize yet.';

  @override
  String get launchDetailDigestFromCache =>
      'From cache (same reports; regenerate if someone just posted).';

  @override
  String get launchDetailDigestReadIndividualHint =>
      'Read individual reports below—summaries can miss nuance.';

  @override
  String get launchDetailRecentReportsTitle => 'Recent reports';

  @override
  String get launchDetailRecentReportsSubtitle =>
      'Raw messages (newest first). Compare with the digest above.';

  @override
  String get launchDetailNoPaddlerReports => 'No paddler reports yet.';

  @override
  String get launchDetailReportYou => 'You';

  @override
  String get launchDetailReportAnonymous => 'Anonymous paddler';

  @override
  String get launchDetailConditionReportTitle => 'Condition report';

  @override
  String get launchDetailConditionReportHint =>
      'What are you seeing on the water?';

  @override
  String get launchDetailGoNoGoTitle => 'Go / No-go (informational)';

  @override
  String get launchDetailGoNoGoNoWarnings =>
      'No stub warnings from wind, marine text, or flow thresholds for this launch.';

  @override
  String get launchDetailGoNoGoStubDisclaimer =>
      'Stub rules only—not a substitute for your judgment, skill, or scouting on site.';

  @override
  String get launchDetailWeatherTitle => 'Weather';

  @override
  String get launchDetailRiverFlowTitle => 'River flow (USGS)';

  @override
  String launchDetailRiverFlowSubtitle(String cfs, String time) {
    return '$cfs cfs · $time';
  }

  @override
  String get launchDetailTidesTitle => 'Tides';

  @override
  String launchDetailFeetValue(String feet) {
    return '$feet ft';
  }

  @override
  String launchDetailTideEventLine(String type, String height, String time) {
    return '$type $height · $time';
  }

  @override
  String get launchDetailNoTideData => 'No tide data';

  @override
  String launchDetailMarineTitle(String zone) {
    return 'Marine (NWS $zone)';
  }

  @override
  String get launchDetailUnavailable => 'Unavailable';

  @override
  String get launchDetailNoMarineForecast => 'No marine forecast';

  @override
  String get launchDetailWeatherSourceOpenMeteoBackup => 'Open-Meteo (backup)';

  @override
  String get launchDetailWeatherSourceOpenMeteo => 'Open-Meteo';

  @override
  String get launchDetailWeatherSourceNws => 'National Weather Service';

  @override
  String get launchDetailTideMinorReferenceNote =>
      'Reference only — timing/height differs upriver from the station.';

  @override
  String get launchDetailRiverFlowNoData => 'No data';

  @override
  String launchDetailMarineExpandHint(int count) {
    return '$count period(s) · tap to read';
  }

  @override
  String launchDetailMarinePeriodLabel(int number) {
    return 'Period $number';
  }

  @override
  String get launchNotFoundTitle => 'Launch not found';

  @override
  String get launchNotFoundBody => 'That launch is not in the curated list.';

  @override
  String launchDetailWindGust(String speed) {
    return 'Gust $speed mph';
  }

  @override
  String launchDetailWindLine(String details) {
    return 'Wind: $details';
  }

  @override
  String launchDetailWindFromDirection(String direction) {
    return 'from $direction';
  }

  @override
  String launchDetailTemperatureF(String temp) {
    return '$temp°F';
  }

  @override
  String get retryButton => 'Retry';

  @override
  String get regenerateButton => 'Regenerate';

  @override
  String get checkAgainButton => 'Check again';

  @override
  String get summarizeWithAiButton => 'Summarize with AI';

  @override
  String get summarizeRecentReportsButton => 'Summarize recent reports';

  @override
  String get cancelButton => 'Cancel';

  @override
  String get submitButton => 'Submit';

  @override
  String get missingMapboxTokenTitle => 'Mapbox token required';

  @override
  String get missingMapboxTokenDevIntro =>
      'Local dev: create .local.env from the template and run via the script:';

  @override
  String get missingMapboxTokenCompileIntro => 'Or pass at compile time:';

  @override
  String get missingMapboxTokenSecurityNote =>
      'Never commit .local.env. Use a restricted public token in Mapbox.';

  @override
  String get webMapPlaceholderTitle => 'Map on mobile';

  @override
  String get webMapPlaceholderBody =>
      'Use the Android or iOS app for the interactive map.';

  @override
  String get shellTabMap => 'Map';

  @override
  String get shellTabSavedRoutes => 'Saved routes';

  @override
  String get savedRoutesListTitle => 'Saved routes';

  @override
  String get savedRoutesAllTab => 'All';

  @override
  String get savedRoutesFavoritesTab => 'Favorites';

  @override
  String get savedRoutesListEmpty =>
      'No saved routes yet. Plan a route on the Map tab and tap Save.';

  @override
  String get savedRoutesFavoritesEmpty => 'No favorite routes yet.';

  @override
  String get savedRoutesListError => 'Could not load saved routes.';

  @override
  String savedRoutesDistanceKm(String km) {
    return '$km km';
  }

  @override
  String savedRoutesWaypointCount(int count) {
    return '$count stops';
  }

  @override
  String get savedRoutesFavoriteTooltip => 'Add to favorites';

  @override
  String get savedRoutesUnfavoriteTooltip => 'Remove from favorites';

  @override
  String get savedRoutesDetailTitle => 'Route details';

  @override
  String get savedRoutesDetailError => 'Could not load this route.';

  @override
  String get savedRoutesNotFound => 'Route not found.';

  @override
  String get savedRoutesNameLabel => 'Name';

  @override
  String get savedRoutesDescriptionLabel => 'Description';

  @override
  String get savedRoutesNotesLabel => 'Notes';

  @override
  String get savedRoutesDurationLabel => 'Estimated duration (minutes)';

  @override
  String get savedRoutesDurationHint => 'Optional — e.g. distance ÷ 4 km/h';

  @override
  String get savedRoutesDifficultyLabel => 'Difficulty';

  @override
  String get savedRoutesDifficultyNone => 'Not set';

  @override
  String get savedRoutesDifficultyEasy => 'Easy';

  @override
  String get savedRoutesDifficultyModerate => 'Moderate';

  @override
  String get savedRoutesDifficultyHard => 'Hard';

  @override
  String get savedRoutesDifficultyExpert => 'Expert';

  @override
  String get savedRoutesSkillLabel => 'Recommended skill';

  @override
  String get savedRoutesSkillNone => 'Not set';

  @override
  String get savedRoutesCategoriesLabel => 'Categories';

  @override
  String get savedRoutesCategoryScenic => 'Scenic';

  @override
  String get savedRoutesCategoryTraining => 'Training';

  @override
  String get savedRoutesCategoryCommute => 'Commute';

  @override
  String get savedRoutesCategoryOvernight => 'Overnight';

  @override
  String get savedRoutesCustomTagsLabel => 'Custom tags';

  @override
  String get savedRoutesCustomTagHint => 'Add a tag';

  @override
  String get savedRoutesCustomTagAdd => 'Add tag';

  @override
  String get savedRoutesFavoriteError => 'Could not update favorite.';

  @override
  String get savedRoutesLoadOnMapInsufficientWaypoints =>
      'Could not load route — too few known launch points.';

  @override
  String get savedRoutesLoadOnMapDrawError =>
      'Route loaded, but the map could not draw the line.';

  @override
  String get savedRoutesWaypointsTitle => 'Waypoints';

  @override
  String savedRoutesWaypointSemantics(int position, String name) {
    return 'Waypoint $position, $name';
  }

  @override
  String get savedRoutesReorderWaypointHint => 'Drag to reorder';

  @override
  String savedRoutesDeleteWaypointSemantics(int position) {
    return 'Delete waypoint $position';
  }

  @override
  String get savedRoutesUnknownLaunch => 'Unknown launch';

  @override
  String get savedRoutesSaveButton => 'Save changes';

  @override
  String get savedRoutesLoadOnMapButton => 'Load on map';

  @override
  String get savedRoutesDeleteButton => 'Delete route';

  @override
  String get savedRoutesNameRequired => 'Enter a route name.';

  @override
  String get savedRoutesSaveSuccess => 'Route saved.';

  @override
  String get savedRoutesSaveError => 'Could not save route.';

  @override
  String get savedRoutesDeleteConfirmTitle => 'Delete route?';

  @override
  String get savedRoutesDeleteConfirmBody =>
      'This removes the route from your device. This cannot be undone.';

  @override
  String get savedRoutesDeleteError => 'Could not delete route.';

  @override
  String get savedRoutesSaveDialogTitle => 'Save route';

  @override
  String get savedRoutesSaveFromMapButton => 'Save';

  @override
  String get mapPlanningSaveLabel => 'Save route';

  @override
  String mapPlanningWaypointCount(int count) {
    return '$count stops';
  }

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonCancel => 'Cancel';
}
