import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// The application title
  ///
  /// In en, this message translates to:
  /// **'EddyScout'**
  String get appTitle;

  /// No description provided for @mapScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'EddyScout'**
  String get mapScreenTitle;

  /// No description provided for @mapPlanRouteTooltip.
  ///
  /// In en, this message translates to:
  /// **'Plan river route'**
  String get mapPlanRouteTooltip;

  /// No description provided for @mapExitPlanningTooltip.
  ///
  /// In en, this message translates to:
  /// **'Exit route planning'**
  String get mapExitPlanningTooltip;

  /// No description provided for @mapZoomInLabel.
  ///
  /// In en, this message translates to:
  /// **'Zoom in'**
  String get mapZoomInLabel;

  /// No description provided for @mapZoomOutLabel.
  ///
  /// In en, this message translates to:
  /// **'Zoom out'**
  String get mapZoomOutLabel;

  /// No description provided for @mapShowAllLaunchesLabel.
  ///
  /// In en, this message translates to:
  /// **'Show all launches'**
  String get mapShowAllLaunchesLabel;

  /// No description provided for @mapZoomControlsSemantics.
  ///
  /// In en, this message translates to:
  /// **'Map zoom controls'**
  String get mapZoomControlsSemantics;

  /// No description provided for @mapPickDifferentTakeOut.
  ///
  /// In en, this message translates to:
  /// **'Pick a different launch for take-out.'**
  String get mapPickDifferentTakeOut;

  /// No description provided for @mapRiverDataLoading.
  ///
  /// In en, this message translates to:
  /// **'Still loading river data… try again.'**
  String get mapRiverDataLoading;

  /// No description provided for @mapRiverDataReadFailed.
  ///
  /// In en, this message translates to:
  /// **'River route data could not be read.'**
  String get mapRiverDataReadFailed;

  /// No description provided for @mapRiverDataUnavailable.
  ///
  /// In en, this message translates to:
  /// **'River route data is unavailable.'**
  String get mapRiverDataUnavailable;

  /// No description provided for @mapRouteFailureSameLaunch.
  ///
  /// In en, this message translates to:
  /// **'Choose two different launches.'**
  String get mapRouteFailureSameLaunch;

  /// No description provided for @mapRouteFailureDifferentSystem.
  ///
  /// In en, this message translates to:
  /// **'Pick two launches on the same river system for river routing.'**
  String get mapRouteFailureDifferentSystem;

  /// No description provided for @mapRouteFailureNoBundledLine.
  ///
  /// In en, this message translates to:
  /// **'No bundled river line for \"{river}\" yet — routing is only available where hydro GeoJSON exists.'**
  String mapRouteFailureNoBundledLine(String river);

  /// No description provided for @mapRouteFailureNoData.
  ///
  /// In en, this message translates to:
  /// **'River route data is not available yet.'**
  String get mapRouteFailureNoData;

  /// No description provided for @mapRouteFailurePutInTooFar.
  ///
  /// In en, this message translates to:
  /// **'Put-in is too far from the modeled river line. Try another launch.'**
  String get mapRouteFailurePutInTooFar;

  /// No description provided for @mapRouteFailureTakeOutTooFar.
  ///
  /// In en, this message translates to:
  /// **'Take-out is too far from the modeled river line. Try another launch.'**
  String get mapRouteFailureTakeOutTooFar;

  /// No description provided for @mapRouteFailureNoConnectedPath.
  ///
  /// In en, this message translates to:
  /// **'No connected river path between these points in the current data.'**
  String get mapRouteFailureNoConnectedPath;

  /// No description provided for @mapRouteFailureDisconnectedReach.
  ///
  /// In en, this message translates to:
  /// **'Put-in and take-out are on different river segments in our bundled data. Try launches on the same reach.'**
  String get mapRouteFailureDisconnectedReach;

  /// No description provided for @mapRouteFailureDisconnectedReachNamed.
  ///
  /// In en, this message translates to:
  /// **'Put-in ({putInReach}) and take-out ({takeOutReach}) are on different bundled segments. Try launches on the same reach.'**
  String mapRouteFailureDisconnectedReachNamed(
    String putInReach,
    String takeOutReach,
  );

  /// No description provided for @mapPlanningStepPickPutIn.
  ///
  /// In en, this message translates to:
  /// **'Step 1: Tap a launch for put-in.'**
  String get mapPlanningStepPickPutIn;

  /// No description provided for @mapPlanningStepPickTakeOut.
  ///
  /// In en, this message translates to:
  /// **'Step 2: Tap another launch for take-out.'**
  String get mapPlanningStepPickTakeOut;

  /// No description provided for @mapPlanningComputingRoute.
  ///
  /// In en, this message translates to:
  /// **'Calculating route…'**
  String get mapPlanningComputingRoute;

  /// No description provided for @mapPlanningRiverSystem.
  ///
  /// In en, this message translates to:
  /// **'River system: {system}'**
  String mapPlanningRiverSystem(String system);

  /// No description provided for @mapPlanningRouteReach.
  ///
  /// In en, this message translates to:
  /// **'Bundled reach: {reachId}'**
  String mapPlanningRouteReach(String reachId);

  /// No description provided for @mapPlanningSemanticsLabel.
  ///
  /// In en, this message translates to:
  /// **'River route planning'**
  String get mapPlanningSemanticsLabel;

  /// No description provided for @mapPlanningTitleBeta.
  ///
  /// In en, this message translates to:
  /// **'River route (beta)'**
  String get mapPlanningTitleBeta;

  /// No description provided for @mapPlanningInstructions.
  ///
  /// In en, this message translates to:
  /// **'Tap a launch for put-in, then another for take-out. The line follows bundled open hydro data (approximate centerline)—not for navigation. Several downtown launches sit close together; overlapping pins are separate sites. Clear removes the route line and picks so you can start over. Done closes this panel and clears the route.'**
  String get mapPlanningInstructions;

  /// No description provided for @mapPlanningPutInName.
  ///
  /// In en, this message translates to:
  /// **'Put-in: {name}'**
  String mapPlanningPutInName(String name);

  /// No description provided for @mapPlanningTakeOutName.
  ///
  /// In en, this message translates to:
  /// **'Take-out: {name}'**
  String mapPlanningTakeOutName(String name);

  /// No description provided for @mapPlanningRouteLengthKm.
  ///
  /// In en, this message translates to:
  /// **'Along river (estimate): {km} km'**
  String mapPlanningRouteLengthKm(String km);

  /// No description provided for @mapPlanningClearLabel.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get mapPlanningClearLabel;

  /// No description provided for @mapPlanningDoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get mapPlanningDoneLabel;

  /// No description provided for @mapGpxExportLabel.
  ///
  /// In en, this message translates to:
  /// **'Export GPX'**
  String get mapGpxExportLabel;

  /// No description provided for @mapGpxImportLabel.
  ///
  /// In en, this message translates to:
  /// **'Import GPX'**
  String get mapGpxImportLabel;

  /// No description provided for @mapGpxExportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Route exported.'**
  String get mapGpxExportSuccess;

  /// No description provided for @mapGpxImportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Track imported.'**
  String get mapGpxImportSuccess;

  /// No description provided for @mapGpxExportNoRoute.
  ///
  /// In en, this message translates to:
  /// **'Plan a route before exporting GPX.'**
  String get mapGpxExportNoRoute;

  /// No description provided for @mapGpxFailureEmptyInput.
  ///
  /// In en, this message translates to:
  /// **'That GPX file is empty.'**
  String get mapGpxFailureEmptyInput;

  /// No description provided for @mapGpxFailureMalformed.
  ///
  /// In en, this message translates to:
  /// **'Could not read that GPX file.'**
  String get mapGpxFailureMalformed;

  /// No description provided for @mapGpxFailureNoGeometry.
  ///
  /// In en, this message translates to:
  /// **'No track or route found in that GPX file.'**
  String get mapGpxFailureNoGeometry;

  /// No description provided for @mapGpxFailureTooFewPoints.
  ///
  /// In en, this message translates to:
  /// **'GPX needs at least two points.'**
  String get mapGpxFailureTooFewPoints;

  /// No description provided for @mapGpxFailureFileRead.
  ///
  /// In en, this message translates to:
  /// **'Could not read the GPX file.'**
  String get mapGpxFailureFileRead;

  /// No description provided for @mapGpxFailureFileWrite.
  ///
  /// In en, this message translates to:
  /// **'Could not prepare the GPX file for sharing.'**
  String get mapGpxFailureFileWrite;

  /// No description provided for @mapGpxFailureShare.
  ///
  /// In en, this message translates to:
  /// **'Sharing is unavailable on this device.'**
  String get mapGpxFailureShare;

  /// No description provided for @mapGpxFailureGeneric.
  ///
  /// In en, this message translates to:
  /// **'GPX action failed. Try again.'**
  String get mapGpxFailureGeneric;

  /// No description provided for @mapGpxFailureOutsidePnw.
  ///
  /// In en, this message translates to:
  /// **'This track is outside our Pacific Northwest focus area.'**
  String get mapGpxFailureOutsidePnw;

  /// No description provided for @mapGpxFailureLaunchSnapFailed.
  ///
  /// In en, this message translates to:
  /// **'Put-in and take-out could not be matched to known launches.'**
  String get mapGpxFailureLaunchSnapFailed;

  /// No description provided for @commonDash.
  ///
  /// In en, this message translates to:
  /// **'—'**
  String get commonDash;

  /// No description provided for @commonBullet.
  ///
  /// In en, this message translates to:
  /// **'•'**
  String get commonBullet;

  /// No description provided for @commonDotSeparator.
  ///
  /// In en, this message translates to:
  /// **' · '**
  String get commonDotSeparator;

  /// No description provided for @launchDetailConditionsErrorNetwork.
  ///
  /// In en, this message translates to:
  /// **'Could not load conditions. Check your connection and try again.'**
  String get launchDetailConditionsErrorNetwork;

  /// No description provided for @launchDetailConditionsErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Could not load conditions. Pull to refresh or try again later.'**
  String get launchDetailConditionsErrorGeneric;

  /// No description provided for @launchDetailSkillProfileErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Could not load your skill profile. Restart the app or try again later.'**
  String get launchDetailSkillProfileErrorGeneric;

  /// No description provided for @launchDetailSkillSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Skill (wind thresholds)'**
  String get launchDetailSkillSectionTitle;

  /// No description provided for @launchDetailWindExposureSemantics.
  ///
  /// In en, this message translates to:
  /// **'Wind exposure {label}'**
  String launchDetailWindExposureSemantics(String label);

  /// No description provided for @launchDetailRiverSemantics.
  ///
  /// In en, this message translates to:
  /// **'River {river}'**
  String launchDetailRiverSemantics(String river);

  /// No description provided for @launchDetailTideRelevanceSemantics.
  ///
  /// In en, this message translates to:
  /// **'Tide {label}'**
  String launchDetailTideRelevanceSemantics(String label);

  /// No description provided for @launchDetailSkillBeginner.
  ///
  /// In en, this message translates to:
  /// **'Beginner'**
  String get launchDetailSkillBeginner;

  /// No description provided for @launchDetailSkillIntermediate.
  ///
  /// In en, this message translates to:
  /// **'Intermed.'**
  String get launchDetailSkillIntermediate;

  /// No description provided for @launchDetailSkillAdvanced.
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get launchDetailSkillAdvanced;

  /// No description provided for @launchDetailReportSubmitError.
  ///
  /// In en, this message translates to:
  /// **'Could not submit report. Try again in a moment.'**
  String get launchDetailReportSubmitError;

  /// No description provided for @launchDetailDigestError.
  ///
  /// In en, this message translates to:
  /// **'Could not load digest. Try again.'**
  String get launchDetailDigestError;

  /// No description provided for @launchDetailAiSummaryError.
  ///
  /// In en, this message translates to:
  /// **'Could not load AI summary. Try again.'**
  String get launchDetailAiSummaryError;

  /// No description provided for @launchDetailReportConditionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Report conditions'**
  String get launchDetailReportConditionsTitle;

  /// No description provided for @launchDetailReportConditionsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Short note to help others (stored securely)'**
  String get launchDetailReportConditionsSubtitle;

  /// No description provided for @launchDetailConditionsSection.
  ///
  /// In en, this message translates to:
  /// **'Conditions'**
  String get launchDetailConditionsSection;

  /// No description provided for @launchDetailDisclaimerTitle.
  ///
  /// In en, this message translates to:
  /// **'Disclaimer'**
  String get launchDetailDisclaimerTitle;

  /// No description provided for @launchDetailDisclaimerBody.
  ///
  /// In en, this message translates to:
  /// **'EddyScout shows third-party data for planning only. It is not a substitute for your judgment, skill assessment, or on-site scouting. River and marine conditions can change rapidly.'**
  String get launchDetailDisclaimerBody;

  /// No description provided for @launchDetailDataSourcesTitle.
  ///
  /// In en, this message translates to:
  /// **'Data sources'**
  String get launchDetailDataSourcesTitle;

  /// No description provided for @launchDetailFirebaseUnavailableIntro.
  ///
  /// In en, this message translates to:
  /// **'Firebase did not start, so AI summary and reports are unavailable.'**
  String get launchDetailFirebaseUnavailableIntro;

  /// No description provided for @launchDetailFirebaseUnavailableBody.
  ///
  /// In en, this message translates to:
  /// **'Firebase features need a successful app init and anonymous sign-in. Add google-services.json, enable Anonymous auth, deploy functions, and rebuild with USE_FIREBASE=true in .local.env (make run).'**
  String get launchDetailFirebaseUnavailableBody;

  /// No description provided for @launchDetailFirebaseErrorLabel.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String launchDetailFirebaseErrorLabel(String error);

  /// No description provided for @launchDetailFirebaseHintMissingNativeConfig.
  ///
  /// In en, this message translates to:
  /// **'Add apps/eddyscout/android/app/google-services.json from Firebase Console. In a git worktree, run make dev to symlink from your main clone. Then stop the app fully and rebuild (not hot reload).'**
  String get launchDetailFirebaseHintMissingNativeConfig;

  /// No description provided for @launchDetailFirebaseHintAnonymousAuth.
  ///
  /// In en, this message translates to:
  /// **'Firebase is blocking anonymous sign-in. In Firebase Console open Authentication → Sign-in method → enable Anonymous → Save. If it is already on, open Authentication → Settings and ensure user sign-up is not disabled. Then stop the app fully and run make dev again (not hot reload).'**
  String get launchDetailFirebaseHintAnonymousAuth;

  /// No description provided for @launchDetailRiverWillamette.
  ///
  /// In en, this message translates to:
  /// **'Willamette'**
  String get launchDetailRiverWillamette;

  /// No description provided for @launchDetailRiverColumbia.
  ///
  /// In en, this message translates to:
  /// **'Columbia / regional'**
  String get launchDetailRiverColumbia;

  /// No description provided for @launchDetailRiverClackamas.
  ///
  /// In en, this message translates to:
  /// **'Clackamas'**
  String get launchDetailRiverClackamas;

  /// No description provided for @launchDetailRiverSlough.
  ///
  /// In en, this message translates to:
  /// **'Slough / confluence'**
  String get launchDetailRiverSlough;

  /// No description provided for @launchDetailReportThanks.
  ///
  /// In en, this message translates to:
  /// **'Thanks—report submitted.'**
  String get launchDetailReportThanks;

  /// No description provided for @launchDetailReportAddMessageFirst.
  ///
  /// In en, this message translates to:
  /// **'Add a short message first.'**
  String get launchDetailReportAddMessageFirst;

  /// No description provided for @launchDetailReportsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load reports: {message}'**
  String launchDetailReportsLoadError(String message);

  /// No description provided for @launchDetailReportsUnauthHint.
  ///
  /// In en, this message translates to:
  /// **'If this persists: fully stop the app and run again (not hot reload); confirm listConditionReports is deployed with Cloud Run invoker public (see firebase/DEPLOY.md); on emulators, use a Google Play system image.'**
  String get launchDetailReportsUnauthHint;

  /// No description provided for @launchDetailTimeJustNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get launchDetailTimeJustNow;

  /// No description provided for @launchDetailTimeMinutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{count}m ago'**
  String launchDetailTimeMinutesAgo(int count);

  /// No description provided for @launchDetailTimeHoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{count}h ago'**
  String launchDetailTimeHoursAgo(int count);

  /// No description provided for @launchDetailTimeDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count}d ago'**
  String launchDetailTimeDaysAgo(int count);

  /// No description provided for @launchDetailAttributionLaunchList.
  ///
  /// In en, this message translates to:
  /// **'Launch list: curated for EddyScout (verify access locally).'**
  String get launchDetailAttributionLaunchList;

  /// No description provided for @launchDetailAttributionWeather.
  ///
  /// In en, this message translates to:
  /// **'Weather: {source}.'**
  String launchDetailAttributionWeather(String source);

  /// No description provided for @launchDetailAttributionTides.
  ///
  /// In en, this message translates to:
  /// **'Tides: NOAA CO-OPS (station {station}, {datum}).'**
  String launchDetailAttributionTides(String station, String datum);

  /// No description provided for @launchDetailAttributionMarine.
  ///
  /// In en, this message translates to:
  /// **'Marine: NWS zone {zone}.'**
  String launchDetailAttributionMarine(String zone);

  /// No description provided for @launchDetailAttributionFlow.
  ///
  /// In en, this message translates to:
  /// **'Flow: USGS NWIS (site {site}).'**
  String launchDetailAttributionFlow(String site);

  /// No description provided for @launchDetailAiSummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'AI summary'**
  String get launchDetailAiSummaryTitle;

  /// No description provided for @launchDetailAiSummaryVerifyHint.
  ///
  /// In en, this message translates to:
  /// **'Verify against the raw data below—AI can misread or omit details.'**
  String get launchDetailAiSummaryVerifyHint;

  /// No description provided for @launchDetailCommunityDigestTitle.
  ///
  /// In en, this message translates to:
  /// **'Community digest (AI)'**
  String get launchDetailCommunityDigestTitle;

  /// No description provided for @launchDetailCommunityDigestSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Paraphrases recent paddler notes below—not official conditions or river status.'**
  String get launchDetailCommunityDigestSubtitle;

  /// No description provided for @launchDetailDigestNoReports.
  ///
  /// In en, this message translates to:
  /// **'No paddler reports to summarize yet.'**
  String get launchDetailDigestNoReports;

  /// No description provided for @launchDetailDigestFromCache.
  ///
  /// In en, this message translates to:
  /// **'From cache (same reports; regenerate if someone just posted).'**
  String get launchDetailDigestFromCache;

  /// No description provided for @launchDetailDigestReadIndividualHint.
  ///
  /// In en, this message translates to:
  /// **'Read individual reports below—summaries can miss nuance.'**
  String get launchDetailDigestReadIndividualHint;

  /// No description provided for @launchDetailRecentReportsTitle.
  ///
  /// In en, this message translates to:
  /// **'Recent reports'**
  String get launchDetailRecentReportsTitle;

  /// No description provided for @launchDetailRecentReportsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Raw messages (newest first). Compare with the digest above.'**
  String get launchDetailRecentReportsSubtitle;

  /// No description provided for @launchDetailNoPaddlerReports.
  ///
  /// In en, this message translates to:
  /// **'No paddler reports yet.'**
  String get launchDetailNoPaddlerReports;

  /// No description provided for @launchDetailReportYou.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get launchDetailReportYou;

  /// No description provided for @launchDetailReportAnonymous.
  ///
  /// In en, this message translates to:
  /// **'Anonymous paddler'**
  String get launchDetailReportAnonymous;

  /// No description provided for @launchDetailConditionReportTitle.
  ///
  /// In en, this message translates to:
  /// **'Condition report'**
  String get launchDetailConditionReportTitle;

  /// No description provided for @launchDetailConditionReportHint.
  ///
  /// In en, this message translates to:
  /// **'What are you seeing on the water?'**
  String get launchDetailConditionReportHint;

  /// No description provided for @launchDetailGoNoGoTitle.
  ///
  /// In en, this message translates to:
  /// **'Go / No-go (informational)'**
  String get launchDetailGoNoGoTitle;

  /// No description provided for @launchDetailGoNoGoNoWarnings.
  ///
  /// In en, this message translates to:
  /// **'No stub warnings from wind, marine text, or flow thresholds for this launch.'**
  String get launchDetailGoNoGoNoWarnings;

  /// No description provided for @launchDetailGoNoGoStubDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Stub rules only—not a substitute for your judgment, skill, or scouting on site.'**
  String get launchDetailGoNoGoStubDisclaimer;

  /// No description provided for @launchDetailWeatherTitle.
  ///
  /// In en, this message translates to:
  /// **'Weather'**
  String get launchDetailWeatherTitle;

  /// No description provided for @launchDetailRiverFlowTitle.
  ///
  /// In en, this message translates to:
  /// **'River flow (USGS)'**
  String get launchDetailRiverFlowTitle;

  /// No description provided for @launchDetailRiverFlowSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{cfs} cfs · {time}'**
  String launchDetailRiverFlowSubtitle(String cfs, String time);

  /// No description provided for @launchDetailTidesTitle.
  ///
  /// In en, this message translates to:
  /// **'Tides'**
  String get launchDetailTidesTitle;

  /// No description provided for @launchDetailFeetValue.
  ///
  /// In en, this message translates to:
  /// **'{feet} ft'**
  String launchDetailFeetValue(String feet);

  /// No description provided for @launchDetailTideEventLine.
  ///
  /// In en, this message translates to:
  /// **'{type} {height} · {time}'**
  String launchDetailTideEventLine(String type, String height, String time);

  /// No description provided for @launchDetailNoTideData.
  ///
  /// In en, this message translates to:
  /// **'No tide data'**
  String get launchDetailNoTideData;

  /// No description provided for @launchDetailMarineTitle.
  ///
  /// In en, this message translates to:
  /// **'Marine (NWS {zone})'**
  String launchDetailMarineTitle(String zone);

  /// No description provided for @launchDetailUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Unavailable'**
  String get launchDetailUnavailable;

  /// No description provided for @launchDetailNoMarineForecast.
  ///
  /// In en, this message translates to:
  /// **'No marine forecast'**
  String get launchDetailNoMarineForecast;

  /// No description provided for @launchDetailWeatherSourceOpenMeteoBackup.
  ///
  /// In en, this message translates to:
  /// **'Open-Meteo (backup)'**
  String get launchDetailWeatherSourceOpenMeteoBackup;

  /// No description provided for @launchDetailWeatherSourceOpenMeteo.
  ///
  /// In en, this message translates to:
  /// **'Open-Meteo'**
  String get launchDetailWeatherSourceOpenMeteo;

  /// No description provided for @launchDetailWeatherSourceNws.
  ///
  /// In en, this message translates to:
  /// **'National Weather Service'**
  String get launchDetailWeatherSourceNws;

  /// No description provided for @launchDetailTideMinorReferenceNote.
  ///
  /// In en, this message translates to:
  /// **'Reference only — timing/height differs upriver from the station.'**
  String get launchDetailTideMinorReferenceNote;

  /// No description provided for @launchDetailRiverFlowNoData.
  ///
  /// In en, this message translates to:
  /// **'No data'**
  String get launchDetailRiverFlowNoData;

  /// No description provided for @launchDetailMarineExpandHint.
  ///
  /// In en, this message translates to:
  /// **'{count} period(s) · tap to read'**
  String launchDetailMarineExpandHint(int count);

  /// No description provided for @launchDetailMarinePeriodLabel.
  ///
  /// In en, this message translates to:
  /// **'Period {number}'**
  String launchDetailMarinePeriodLabel(int number);

  /// No description provided for @launchNotFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'Launch not found'**
  String get launchNotFoundTitle;

  /// No description provided for @launchNotFoundBody.
  ///
  /// In en, this message translates to:
  /// **'That launch is not in the curated list.'**
  String get launchNotFoundBody;

  /// No description provided for @launchDetailWindGust.
  ///
  /// In en, this message translates to:
  /// **'Gust {speed} mph'**
  String launchDetailWindGust(String speed);

  /// No description provided for @launchDetailWindLine.
  ///
  /// In en, this message translates to:
  /// **'Wind: {details}'**
  String launchDetailWindLine(String details);

  /// No description provided for @launchDetailWindFromDirection.
  ///
  /// In en, this message translates to:
  /// **'from {direction}'**
  String launchDetailWindFromDirection(String direction);

  /// No description provided for @launchDetailTemperatureF.
  ///
  /// In en, this message translates to:
  /// **'{temp}°F'**
  String launchDetailTemperatureF(String temp);

  /// No description provided for @retryButton.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retryButton;

  /// No description provided for @regenerateButton.
  ///
  /// In en, this message translates to:
  /// **'Regenerate'**
  String get regenerateButton;

  /// No description provided for @checkAgainButton.
  ///
  /// In en, this message translates to:
  /// **'Check again'**
  String get checkAgainButton;

  /// No description provided for @summarizeWithAiButton.
  ///
  /// In en, this message translates to:
  /// **'Summarize with AI'**
  String get summarizeWithAiButton;

  /// No description provided for @summarizeRecentReportsButton.
  ///
  /// In en, this message translates to:
  /// **'Summarize recent reports'**
  String get summarizeRecentReportsButton;

  /// No description provided for @cancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelButton;

  /// No description provided for @submitButton.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submitButton;

  /// No description provided for @missingMapboxTokenTitle.
  ///
  /// In en, this message translates to:
  /// **'Mapbox token required'**
  String get missingMapboxTokenTitle;

  /// No description provided for @missingMapboxTokenDevIntro.
  ///
  /// In en, this message translates to:
  /// **'Local dev: create .local.env from the template and run via the script:'**
  String get missingMapboxTokenDevIntro;

  /// No description provided for @missingMapboxTokenCompileIntro.
  ///
  /// In en, this message translates to:
  /// **'Or pass at compile time:'**
  String get missingMapboxTokenCompileIntro;

  /// No description provided for @missingMapboxTokenSecurityNote.
  ///
  /// In en, this message translates to:
  /// **'Never commit .local.env. Use a restricted public token in Mapbox.'**
  String get missingMapboxTokenSecurityNote;

  /// No description provided for @webMapPlaceholderTitle.
  ///
  /// In en, this message translates to:
  /// **'Map on mobile'**
  String get webMapPlaceholderTitle;

  /// No description provided for @webMapPlaceholderBody.
  ///
  /// In en, this message translates to:
  /// **'Use the Android or iOS app for the interactive map.'**
  String get webMapPlaceholderBody;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
