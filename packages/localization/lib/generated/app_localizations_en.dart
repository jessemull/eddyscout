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
      'No connected river path between these river systems in bundled data.';

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
  String mapPlanningRouteLength(String distance) {
    return 'Along river (estimate): $distance';
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
  String get launchDetailReportPendingReview =>
      'Thanks—your report is being reviewed and will appear once approved.';

  @override
  String get launchDetailReportsPendingReviewHint =>
      'You have a report pending review for this launch.';

  @override
  String get launchDetailReportsModerationTrustLine =>
      'Community notes are reviewed before they appear—not official conditions or river status.';

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
      'Approved paddler messages (newest first). Compare with the digest above.';

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
  String get launchDetailGoNoGoTitle => 'Conditions check (informational)';

  @override
  String get launchDetailGoNoGoNoWarnings => 'No warnings';

  @override
  String get launchDetailGoNoGoStubDisclaimer =>
      'Not a substitute for your judgment, skill, or scouting on site.';

  @override
  String get launchDetailGoNoGoVerdictGo => 'Favorable conditions';

  @override
  String get launchDetailGoNoGoVerdictMarginal => 'Moderate conditions';

  @override
  String get launchDetailGoNoGoVerdictNoGo => 'Poor conditions';

  @override
  String get launchDetailGoNoGoVerdictInsufficientData => 'Unknown conditions';

  @override
  String get launchDetailGoNoGoReasonColdWaterSeason =>
      'Cold-water season in the PNW—dress for immersion, know hypothermia risk, and carry safety gear.';

  @override
  String get launchDetailGoNoGoReasonWeatherMissing =>
      'Weather data was not available. Cannot assess wind from forecast.';

  @override
  String launchDetailGoNoGoReasonWeatherMissingWithError(String error) {
    return 'Weather data failed to load ($error). Cannot assess wind from forecast.';
  }

  @override
  String get launchDetailGoNoGoReasonWindUnknown =>
      'Wind speed or gust was not available from the forecast. Use caution, especially in open or exposed areas.';

  @override
  String launchDetailGoNoGoReasonWindHigh(int mph, String exposure) {
    return 'Effective wind about $mph mph ($exposure site)—our stub rules treat this as strong for paddling.';
  }

  @override
  String launchDetailGoNoGoReasonWindElevated(int mph, String exposure) {
    return 'Effective wind about $mph mph ($exposure site)—conditions may feel rougher on open water.';
  }

  @override
  String launchDetailGoNoGoReasonWindElevatedExposure(String exposure) {
    return '$exposure site.';
  }

  @override
  String launchDetailGoNoGoReasonWindElevatedSpeed(int mph) {
    return 'Effective wind speed $mph mph.';
  }

  @override
  String get launchDetailGoNoGoReasonWindElevatedRoughWater =>
      'Conditions may feel rougher on the open water.';

  @override
  String get launchDetailGoNoGoReasonWindHighTooStrong =>
      'Too strong for paddling.';

  @override
  String launchDetailGoNoGoReasonMarineSevere(String pattern) {
    return 'Marine forecast includes $pattern.';
  }

  @override
  String launchDetailGoNoGoReasonMarineAdvisory(String pattern) {
    return 'Marine forecast includes “$pattern”—expect rougher water, current, or advisories near the estuary/coast.';
  }

  @override
  String get launchDetailGoNoGoReasonForecastLowLight =>
      'This forecast period starts during typical low-light hours locally—verify visibility, hazards, and your comfort paddling after dark.';

  @override
  String launchDetailGoNoGoReasonFlowVeryHigh(String cfs, String siteId) {
    return 'Discharge is approximately $cfs at site $siteId.';
  }

  @override
  String launchDetailGoNoGoReasonFlowApproximate(String cfs) {
    return 'Discharge is approximately $cfs.';
  }

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
  String get shellTabHome => 'Home';

  @override
  String get shellTabMenu => 'Menu';

  @override
  String get mapSearchPlaceholder => 'Search rivers, launches, places…';

  @override
  String get mapSearchLaunchesSection => 'Launches';

  @override
  String get mapSearchPlacesSection => 'Places';

  @override
  String get mapSearchNoResults => 'No results found.';

  @override
  String get mapPlanPaddleButton => 'Plan paddle';

  @override
  String get mapViewConditionsButton => 'View conditions';

  @override
  String get mapRoutePlanningTitle => 'Plan paddle';

  @override
  String get mapRouteStopStart => 'Start';

  @override
  String get mapRouteStopDestination => 'Destination';

  @override
  String mapRouteStopMiddle(int number) {
    return 'Stop $number';
  }

  @override
  String get mapRouteAddStop => 'Add stop';

  @override
  String get mapRouteChooseDestination => 'Choose destination';

  @override
  String get mapRouteChooseOnMap => 'Choose on map';

  @override
  String get mapRouteChooseOnMapHint =>
      'Tap the river on the map to add a custom stop';

  @override
  String get mapRoutePickStopPrompt => 'Tap the river to add a stop';

  @override
  String get mapRouteRenameSnapStop => 'Rename custom stop';

  @override
  String get mapRouteAddStopHint =>
      'Tap another launch on the map to set your destination or add a stop.';

  @override
  String get mapRouteEditStopsTitle => 'Edit stops';

  @override
  String get mapRoutePreviewStart => 'Start';

  @override
  String get mapRoutePreviewAddStops => 'Add stops';

  @override
  String get mapRouteSummaryComingSoon =>
      'Route conditions summary coming soon.';

  @override
  String mapRouteTripTime(int minutes) {
    return '$minutes min';
  }

  @override
  String mapRouteTotalTrip(int minutes, String distance) {
    return 'Total trip: $minutes min ($distance)';
  }

  @override
  String get mapRouteReorderStopHint => 'Drag to reorder stop';

  @override
  String mapRouteDeleteStopSemantics(String name) {
    return 'Remove stop $name';
  }

  @override
  String mapRouteOriginStopSemantics(String name) {
    return 'Starting location, $name';
  }

  @override
  String mapRouteDestinationStopSemantics(String name) {
    return 'Destination, $name';
  }

  @override
  String mapRouteMiddleStopSemantics(String letter, String name) {
    return 'Stop $letter, $name';
  }

  @override
  String mapRouteCustomStopLabel(int index) {
    return 'Custom stop $index';
  }

  @override
  String mapRouteCustomStopSemantics(String name) {
    return 'Custom stop, $name';
  }

  @override
  String get mapRouteNameStopTitle => 'Name this stop';

  @override
  String get mapRouteNameStopHint => 'e.g. Lunch spot, Fishing hole';

  @override
  String get mapRouteNameStopSave => 'Save';

  @override
  String get mapRouteNameStopCancel => 'Cancel';

  @override
  String get mapRouteStartComingSoon => 'On-water navigation is coming soon.';

  @override
  String get mapLocateMeLabel => 'Locate me';

  @override
  String get mapCloseSheetLabel => 'Close';

  @override
  String get homePlaceholderTitle => 'Home';

  @override
  String get homePlaceholderBody =>
      'Featured paddles and discovery experiences are coming soon.';

  @override
  String get homeExploreMapButton => 'Explore map';

  @override
  String get menuScreenTitle => 'Menu';

  @override
  String get menuImportGpx => 'Import GPX';

  @override
  String get menuExportGpx => 'Export GPX';

  @override
  String get menuSettings => 'Settings';

  @override
  String get menuAbout => 'About';

  @override
  String get menuSettingsComingSoon => 'Settings coming soon.';

  @override
  String get menuAboutBody =>
      'EddyScout — your Pacific Northwest paddling companion.';

  @override
  String get settingsScreenTitle => 'Settings';

  @override
  String get settingsPaddleSpeedLabel => 'Paddling speed';

  @override
  String settingsPaddleSpeedValue(String speed) {
    return '$speed km/h';
  }

  @override
  String get settingsPaddleSpeedDescription =>
      'Your average paddling speed for trip-time estimates.';

  @override
  String get settingsPaddleSpeedReset => 'Reset';

  @override
  String get settingsUnitsSectionTitle => 'Units';

  @override
  String get settingsUnitsDescription =>
      'Choose how distance and speed are shown in route planning and saved routes.';

  @override
  String get settingsUnitsMetricLabel => 'Metric (km, km/h)';

  @override
  String get settingsUnitsImperialLabel => 'Imperial (mi, mph)';

  @override
  String get settingsUnitsLoadError => 'Could not load unit preferences.';

  @override
  String get settingsPaddleSpeedLoadError =>
      'Could not load paddling speed preference.';

  @override
  String displayDistanceKm(String value) {
    return '$value km';
  }

  @override
  String displayDistanceMi(String value) {
    return '$value mi';
  }

  @override
  String displaySpeedKmh(String value) {
    return '$value km/h';
  }

  @override
  String displaySpeedMph(String value) {
    return '$value mph';
  }

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
  String savedRoutesDistance(String distance) {
    return '$distance';
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
  String get savedRoutesDetailDistanceLabel => 'Distance';

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
  String get savedRoutesDurationHint =>
      'Optional — estimated paddling time in minutes';

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

  @override
  String get tripsFromHereSectionTitle => 'Trips from here';

  @override
  String get tripsFromHereBand5Mi => 'Within 5 mi';

  @override
  String get tripsFromHereBand10Mi => 'Within 10 mi';

  @override
  String get tripsFromHereBand20Mi => 'Within 20 mi';

  @override
  String get tripsFromHereBandEmpty5Mi =>
      'No launches within 5 mi along the river';

  @override
  String get tripsFromHereBandEmpty10Mi =>
      'No launches within 10 mi along the river';

  @override
  String get tripsFromHereBandEmpty20Mi =>
      'No launches within 20 mi along the river';

  @override
  String get tripsFromHereNoNearbyLaunches =>
      'No nearby launches found along the river from here.';

  @override
  String get tripsFromHereLoadError => 'Couldn\'t load nearby launches.';

  @override
  String tripsFromHereBandShowMore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Show $count more launches',
      one: 'Show 1 more launch',
    );
    return '$_temp0';
  }

  @override
  String tripsFromHerePlanToLaunchSemantics(
    String launchName,
    String riverName,
  ) {
    return 'Plan route to $launchName, $riverName';
  }

  @override
  String tripsFromHereBandSemantics(String bandLabel, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count launches',
      one: '1 launch',
      zero: 'no launches',
    );
    return '$bandLabel, $_temp0';
  }

  @override
  String get tripsFromHereSuggestedTitle => 'Suggested trips';

  @override
  String get tripsFromHereFilterShort => 'Short';

  @override
  String get tripsFromHereFilterMedium => 'Medium';

  @override
  String get tripsFromHereFilterLong => 'Long';

  @override
  String tripsFromHereSuggestedTripSemantics(
    String launchName,
    String distanceMi,
    int minutes,
  ) {
    return 'Suggested trip to $launchName, $distanceMi miles, about $minutes minutes';
  }

  @override
  String get tripsFromHereSuggestedEmpty =>
      'No suggested trips match this filter.';

  @override
  String get tripsFromHereSuggestedSearchPlaceholder =>
      'Search nearby launches...';

  @override
  String get tripsFromHereMaxDistanceLabel => 'Within';

  @override
  String get tripsFromHereMaxDistance5Miles => '5 Miles';

  @override
  String get tripsFromHereMaxDistance10Miles => '10 Miles';

  @override
  String get tripsFromHereMaxDistance20Miles => '20 Miles';

  @override
  String tripsFromHereSuggestedEntrySubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count nearby launches',
      one: '1 nearby launch',
    );
    return '$_temp0';
  }

  @override
  String get routeGoNoGoReasonWeatherMissingSummary =>
      'Weather data failed to load. Cannot assess wind from forecast.';

  @override
  String get routeGoNoGoLoading => 'Loading route conditions…';

  @override
  String get routeGoNoGoErrorGeneric => 'Route conditions could not be loaded.';

  @override
  String routeGoNoGoTriggeringStop(String stopName) {
    return 'Worst at $stopName';
  }

  @override
  String get routeGoNoGoAllStopsTitle => 'All stops';

  @override
  String routeGoNoGoStopLine(int position, String name, String verdict) {
    return '$position. $name — $verdict';
  }

  @override
  String get routeGoNoGoPartialFailuresTitle =>
      'Some stops could not load conditions:';

  @override
  String get routeGoNoGoLaunchNotFound => 'Launch not found in catalog.';

  @override
  String get routeGoNoGoStopConditionsUnavailable =>
      'Conditions could not be loaded for this stop.';

  @override
  String get conditionsCustomStopNoData => 'No conditions data available';

  @override
  String routeGoNoGoStopFailureLine(int position, String name, String message) {
    return '$position. $name: $message';
  }

  @override
  String get routeGoNoGoRouteDisclaimer =>
      'Not a substitute for your judgment, skill, or scouting on site.';

  @override
  String routeGoNoGoSemanticsVerdictOnly(String verdict) {
    return 'Route conditions: $verdict';
  }

  @override
  String routeGoNoGoSemanticsVerdictWithStop(String verdict, String stopName) {
    return 'Route conditions: $verdict. $stopName.';
  }

  @override
  String get moderationQueueTitle => 'Review Reports';

  @override
  String get moderationQueueEmpty => 'No reports waiting for review.';

  @override
  String get moderationQueueLoadError => 'Could not load the review queue.';

  @override
  String get moderationApprove => 'Approve';

  @override
  String get moderationReject => 'Reject';

  @override
  String get moderationActionError =>
      'Could not update that report. Try again.';

  @override
  String get moderationTabPending => 'Pending';

  @override
  String get moderationTabHistory => 'History';

  @override
  String get moderationHistoryEmpty => 'No moderation history yet.';

  @override
  String get moderationHistoryLoadError => 'Could not load moderation history.';

  @override
  String get moderationLaunchSearchHint => 'Search by ID or name...';

  @override
  String get moderationSortOldestWaiting => 'Oldest waiting';

  @override
  String get moderationSortMostRecent => 'Most recent';

  @override
  String get moderationSortRecentAction => 'Recent action';

  @override
  String get moderationSortOldestAction => 'Oldest action';

  @override
  String get moderationDateFilterAll => 'All dates';

  @override
  String get moderationDateFilter7Days => 'Last 7 days';

  @override
  String get moderationDateFilter30Days => 'Last 30 days';

  @override
  String get moderationStatusFilterAll => 'All outcomes';

  @override
  String get moderationStatusFilterApproved => 'Approved';

  @override
  String get moderationStatusFilterRejected => 'Rejected';

  @override
  String get moderationSubmitterUid => 'Submitter';

  @override
  String get moderationModeratorUid => 'Moderator';

  @override
  String get moderationSystemActor => 'System';

  @override
  String get moderationHoldReason => 'Hold Reason';

  @override
  String get moderationMessage => 'Message';

  @override
  String get moderationSubmittedAt => 'Submitted';

  @override
  String get moderationReviewedAt => 'Reviewed';

  @override
  String moderationWaitingDays(int days) {
    return 'Waiting $days days';
  }

  @override
  String get moderationCopyUid => 'Copy UID';

  @override
  String get moderationUidCopied => 'UID copied';

  @override
  String get moderationSelectAll => 'Select all';

  @override
  String get moderationClearSelection => 'Clear';

  @override
  String get moderationBulkSelect => 'Select';

  @override
  String get moderationBulkSelectDone => 'Done';

  @override
  String get moderationReasonKeywordHold => 'Matched moderation keyword';

  @override
  String get moderationReasonAdminApprove => 'Approved by moderator';

  @override
  String get moderationReasonAdminReject => 'Rejected by moderator';

  @override
  String get moderationReasonAdminReopen => 'Returned to pending by moderator';

  @override
  String get moderationReasonHoldTimeout => 'Auto-approved after hold period';

  @override
  String get moderationBulkApprove => 'Approve selected';

  @override
  String get moderationBulkReject => 'Reject selected';

  @override
  String get moderationBulkApproveConfirmTitle => 'Approve selected reports?';

  @override
  String get moderationBulkApproveConfirmBody =>
      'These reports will become visible to paddlers.';

  @override
  String get moderationBulkRejectConfirmTitle => 'Reject selected reports?';

  @override
  String get moderationBulkRejectConfirmBody =>
      'These reports will stay hidden from the public list.';

  @override
  String moderationBatchPartialFailure(int count) {
    return 'Could not update $count selected reports.';
  }

  @override
  String get moderationReturnToPending => 'Return to pending';

  @override
  String get moderationReturnToPendingConfirmTitle =>
      'Return report to pending?';

  @override
  String get moderationReturnToPendingConfirmBody =>
      'This report will reappear on the pending tab for review. If it was approved, it will be removed from the public list.';

  @override
  String get launchDetailReviewReportsButton => 'Review Reports';
}
