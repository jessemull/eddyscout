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
  /// **'No connected river path between these river systems in bundled data.'**
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

  /// Estimated river route length in user-selected units
  ///
  /// In en, this message translates to:
  /// **'Along river (estimate): {distance}'**
  String mapPlanningRouteLength(String distance);

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

  /// No description provided for @launchDetailReportPendingReview.
  ///
  /// In en, this message translates to:
  /// **'Thanks—your report is being reviewed and will appear once approved.'**
  String get launchDetailReportPendingReview;

  /// No description provided for @launchDetailReportsPendingReviewHint.
  ///
  /// In en, this message translates to:
  /// **'You have a report pending review for this launch.'**
  String get launchDetailReportsPendingReviewHint;

  /// No description provided for @launchDetailReportsModerationTrustLine.
  ///
  /// In en, this message translates to:
  /// **'Community notes are reviewed before they appear—not official conditions or river status.'**
  String get launchDetailReportsModerationTrustLine;

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
  /// **'Approved paddler messages (newest first). Compare with the digest above.'**
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
  /// **'Conditions check (informational)'**
  String get launchDetailGoNoGoTitle;

  /// No description provided for @launchDetailGoNoGoNoWarnings.
  ///
  /// In en, this message translates to:
  /// **'No warnings'**
  String get launchDetailGoNoGoNoWarnings;

  /// No description provided for @launchDetailGoNoGoStubDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Not a substitute for your judgment, skill, or scouting on site.'**
  String get launchDetailGoNoGoStubDisclaimer;

  /// Headline when conditions verdict is favorable
  ///
  /// In en, this message translates to:
  /// **'Favorable conditions'**
  String get launchDetailGoNoGoVerdictGo;

  /// Headline when conditions verdict is moderate
  ///
  /// In en, this message translates to:
  /// **'Moderate conditions'**
  String get launchDetailGoNoGoVerdictMarginal;

  /// Headline when conditions verdict is poor
  ///
  /// In en, this message translates to:
  /// **'Poor conditions'**
  String get launchDetailGoNoGoVerdictNoGo;

  /// Headline when conditions verdict lacks enough forecast data
  ///
  /// In en, this message translates to:
  /// **'Unknown conditions'**
  String get launchDetailGoNoGoVerdictInsufficientData;

  /// Info reason during cold-water months
  ///
  /// In en, this message translates to:
  /// **'Cold-water season in the PNW—dress for immersion, know hypothermia risk, and carry safety gear.'**
  String get launchDetailGoNoGoReasonColdWaterSeason;

  /// Info reason when weather data is missing
  ///
  /// In en, this message translates to:
  /// **'Weather data was not available. Cannot assess wind from forecast.'**
  String get launchDetailGoNoGoReasonWeatherMissing;

  /// Info reason when weather fetch failed with an error code
  ///
  /// In en, this message translates to:
  /// **'Weather data failed to load ({error}). Cannot assess wind from forecast.'**
  String launchDetailGoNoGoReasonWeatherMissingWithError(String error);

  /// Marginal reason when wind speed/gust is unavailable
  ///
  /// In en, this message translates to:
  /// **'Wind speed or gust was not available from the forecast. Use caution, especially in open or exposed areas.'**
  String get launchDetailGoNoGoReasonWindUnknown;

  /// No-go reason when effective wind exceeds threshold
  ///
  /// In en, this message translates to:
  /// **'Effective wind about {mph} mph ({exposure} site)—our stub rules treat this as strong for paddling.'**
  String launchDetailGoNoGoReasonWindHigh(int mph, String exposure);

  /// Marginal reason when effective wind is elevated (launch detail single line)
  ///
  /// In en, this message translates to:
  /// **'Effective wind about {mph} mph ({exposure} site)—conditions may feel rougher on open water.'**
  String launchDetailGoNoGoReasonWindElevated(int mph, String exposure);

  /// Route go/no-go bullet: wind exposure tier
  ///
  /// In en, this message translates to:
  /// **'{exposure} site.'**
  String launchDetailGoNoGoReasonWindElevatedExposure(String exposure);

  /// Route go/no-go bullet: effective wind speed
  ///
  /// In en, this message translates to:
  /// **'Effective wind speed {mph} mph.'**
  String launchDetailGoNoGoReasonWindElevatedSpeed(int mph);

  /// Route go/no-go bullet: open-water caution for elevated wind
  ///
  /// In en, this message translates to:
  /// **'Conditions may feel rougher on the open water.'**
  String get launchDetailGoNoGoReasonWindElevatedRoughWater;

  /// Route go/no-go sentence: no-go wind is too strong
  ///
  /// In en, this message translates to:
  /// **'Too strong for paddling.'**
  String get launchDetailGoNoGoReasonWindHighTooStrong;

  /// No-go reason when marine text matches a severe pattern
  ///
  /// In en, this message translates to:
  /// **'Marine forecast includes {pattern}.'**
  String launchDetailGoNoGoReasonMarineSevere(String pattern);

  /// Marginal reason when marine text matches an advisory pattern
  ///
  /// In en, this message translates to:
  /// **'Marine forecast includes “{pattern}”—expect rougher water, current, or advisories near the estuary/coast.'**
  String launchDetailGoNoGoReasonMarineAdvisory(String pattern);

  /// Info reason when forecast period starts at night
  ///
  /// In en, this message translates to:
  /// **'This forecast period starts during typical low-light hours locally—verify visibility, hazards, and your comfort paddling after dark.'**
  String get launchDetailGoNoGoReasonForecastLowLight;

  /// No-go reason when discharge exceeds upper flow band
  ///
  /// In en, this message translates to:
  /// **'Discharge is approximately {cfs} at site {siteId}.'**
  String launchDetailGoNoGoReasonFlowVeryHigh(String cfs, String siteId);

  /// Marginal reason for elevated or low discharge
  ///
  /// In en, this message translates to:
  /// **'Discharge is approximately {cfs}.'**
  String launchDetailGoNoGoReasonFlowApproximate(String cfs);

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

  /// No description provided for @shellTabMap.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get shellTabMap;

  /// No description provided for @shellTabSavedRoutes.
  ///
  /// In en, this message translates to:
  /// **'Saved routes'**
  String get shellTabSavedRoutes;

  /// No description provided for @shellTabHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get shellTabHome;

  /// No description provided for @shellTabMenu.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get shellTabMenu;

  /// No description provided for @mapSearchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search rivers, launches, places…'**
  String get mapSearchPlaceholder;

  /// No description provided for @mapSearchLaunchesSection.
  ///
  /// In en, this message translates to:
  /// **'Launches'**
  String get mapSearchLaunchesSection;

  /// No description provided for @mapSearchPlacesSection.
  ///
  /// In en, this message translates to:
  /// **'Places'**
  String get mapSearchPlacesSection;

  /// No description provided for @mapSearchNoResults.
  ///
  /// In en, this message translates to:
  /// **'No results found.'**
  String get mapSearchNoResults;

  /// No description provided for @mapPlanPaddleButton.
  ///
  /// In en, this message translates to:
  /// **'Plan paddle'**
  String get mapPlanPaddleButton;

  /// No description provided for @mapViewConditionsButton.
  ///
  /// In en, this message translates to:
  /// **'View conditions'**
  String get mapViewConditionsButton;

  /// No description provided for @mapRoutePlanningTitle.
  ///
  /// In en, this message translates to:
  /// **'Plan paddle'**
  String get mapRoutePlanningTitle;

  /// No description provided for @mapRouteStopStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get mapRouteStopStart;

  /// No description provided for @mapRouteStopDestination.
  ///
  /// In en, this message translates to:
  /// **'Destination'**
  String get mapRouteStopDestination;

  /// No description provided for @mapRouteStopMiddle.
  ///
  /// In en, this message translates to:
  /// **'Stop {number}'**
  String mapRouteStopMiddle(int number);

  /// No description provided for @mapRouteAddStop.
  ///
  /// In en, this message translates to:
  /// **'Add stop'**
  String get mapRouteAddStop;

  /// No description provided for @mapRouteChooseDestination.
  ///
  /// In en, this message translates to:
  /// **'Choose destination'**
  String get mapRouteChooseDestination;

  /// No description provided for @mapRouteAddStopHint.
  ///
  /// In en, this message translates to:
  /// **'Tap another launch on the map to set your destination or add a stop.'**
  String get mapRouteAddStopHint;

  /// No description provided for @mapRouteEditStopsTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit stops'**
  String get mapRouteEditStopsTitle;

  /// No description provided for @mapRoutePreviewStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get mapRoutePreviewStart;

  /// No description provided for @mapRoutePreviewAddStops.
  ///
  /// In en, this message translates to:
  /// **'Add stops'**
  String get mapRoutePreviewAddStops;

  /// No description provided for @mapRouteSummaryComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Route conditions summary coming soon.'**
  String get mapRouteSummaryComingSoon;

  /// No description provided for @mapRouteTripTime.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String mapRouteTripTime(int minutes);

  /// No description provided for @mapRouteTotalTrip.
  ///
  /// In en, this message translates to:
  /// **'Total trip: {minutes} min ({distance})'**
  String mapRouteTotalTrip(int minutes, String distance);

  /// No description provided for @mapRouteReorderStopHint.
  ///
  /// In en, this message translates to:
  /// **'Drag to reorder stop'**
  String get mapRouteReorderStopHint;

  /// No description provided for @mapRouteDeleteStopSemantics.
  ///
  /// In en, this message translates to:
  /// **'Remove stop {name}'**
  String mapRouteDeleteStopSemantics(String name);

  /// No description provided for @mapRouteOriginStopSemantics.
  ///
  /// In en, this message translates to:
  /// **'Starting location, {name}'**
  String mapRouteOriginStopSemantics(String name);

  /// No description provided for @mapRouteDestinationStopSemantics.
  ///
  /// In en, this message translates to:
  /// **'Destination, {name}'**
  String mapRouteDestinationStopSemantics(String name);

  /// No description provided for @mapRouteMiddleStopSemantics.
  ///
  /// In en, this message translates to:
  /// **'Stop {letter}, {name}'**
  String mapRouteMiddleStopSemantics(String letter, String name);

  /// No description provided for @mapRouteStartComingSoon.
  ///
  /// In en, this message translates to:
  /// **'On-water navigation is coming soon.'**
  String get mapRouteStartComingSoon;

  /// No description provided for @mapLocateMeLabel.
  ///
  /// In en, this message translates to:
  /// **'Locate me'**
  String get mapLocateMeLabel;

  /// No description provided for @mapCloseSheetLabel.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get mapCloseSheetLabel;

  /// No description provided for @homePlaceholderTitle.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homePlaceholderTitle;

  /// No description provided for @homePlaceholderBody.
  ///
  /// In en, this message translates to:
  /// **'Featured paddles and discovery experiences are coming soon.'**
  String get homePlaceholderBody;

  /// No description provided for @homeExploreMapButton.
  ///
  /// In en, this message translates to:
  /// **'Explore map'**
  String get homeExploreMapButton;

  /// No description provided for @menuScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menuScreenTitle;

  /// No description provided for @menuImportGpx.
  ///
  /// In en, this message translates to:
  /// **'Import GPX'**
  String get menuImportGpx;

  /// No description provided for @menuExportGpx.
  ///
  /// In en, this message translates to:
  /// **'Export GPX'**
  String get menuExportGpx;

  /// No description provided for @menuSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get menuSettings;

  /// No description provided for @menuAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get menuAbout;

  /// No description provided for @menuSettingsComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Settings coming soon.'**
  String get menuSettingsComingSoon;

  /// No description provided for @menuAboutBody.
  ///
  /// In en, this message translates to:
  /// **'EddyScout — your Pacific Northwest paddling companion.'**
  String get menuAboutBody;

  /// Title for the app settings screen
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsScreenTitle;

  /// Label for the paddling speed preference
  ///
  /// In en, this message translates to:
  /// **'Paddling speed'**
  String get settingsPaddleSpeedLabel;

  /// Formatted paddling speed value
  ///
  /// In en, this message translates to:
  /// **'{speed} km/h'**
  String settingsPaddleSpeedValue(String speed);

  /// Help text for the paddling speed preference
  ///
  /// In en, this message translates to:
  /// **'Your average paddling speed for trip-time estimates.'**
  String get settingsPaddleSpeedDescription;

  /// Button label to restore default paddling speed
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get settingsPaddleSpeedReset;

  /// Section title for distance and speed display units
  ///
  /// In en, this message translates to:
  /// **'Units'**
  String get settingsUnitsSectionTitle;

  /// Help text for the units preference
  ///
  /// In en, this message translates to:
  /// **'Choose how distance and speed are shown in route planning and saved routes.'**
  String get settingsUnitsDescription;

  /// Label for metric unit system option
  ///
  /// In en, this message translates to:
  /// **'Metric (km, km/h)'**
  String get settingsUnitsMetricLabel;

  /// Label for imperial unit system option
  ///
  /// In en, this message translates to:
  /// **'Imperial (mi, mph)'**
  String get settingsUnitsImperialLabel;

  /// Error message when the units preference fails to load
  ///
  /// In en, this message translates to:
  /// **'Could not load unit preferences.'**
  String get settingsUnitsLoadError;

  /// Error message when the paddling speed preference fails to load
  ///
  /// In en, this message translates to:
  /// **'Could not load paddling speed preference.'**
  String get settingsPaddleSpeedLoadError;

  /// Formatted distance in kilometers
  ///
  /// In en, this message translates to:
  /// **'{value} km'**
  String displayDistanceKm(String value);

  /// Formatted distance in miles
  ///
  /// In en, this message translates to:
  /// **'{value} mi'**
  String displayDistanceMi(String value);

  /// Formatted speed in kilometers per hour
  ///
  /// In en, this message translates to:
  /// **'{value} km/h'**
  String displaySpeedKmh(String value);

  /// Formatted speed in miles per hour
  ///
  /// In en, this message translates to:
  /// **'{value} mph'**
  String displaySpeedMph(String value);

  /// No description provided for @savedRoutesListTitle.
  ///
  /// In en, this message translates to:
  /// **'Saved routes'**
  String get savedRoutesListTitle;

  /// No description provided for @savedRoutesAllTab.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get savedRoutesAllTab;

  /// No description provided for @savedRoutesFavoritesTab.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get savedRoutesFavoritesTab;

  /// No description provided for @savedRoutesListEmpty.
  ///
  /// In en, this message translates to:
  /// **'No saved routes yet. Plan a route on the Map tab and tap Save.'**
  String get savedRoutesListEmpty;

  /// No description provided for @savedRoutesFavoritesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No favorite routes yet.'**
  String get savedRoutesFavoritesEmpty;

  /// No description provided for @savedRoutesListError.
  ///
  /// In en, this message translates to:
  /// **'Could not load saved routes.'**
  String get savedRoutesListError;

  /// Route distance with unit in user-selected system
  ///
  /// In en, this message translates to:
  /// **'{distance}'**
  String savedRoutesDistance(String distance);

  /// No description provided for @savedRoutesWaypointCount.
  ///
  /// In en, this message translates to:
  /// **'{count} stops'**
  String savedRoutesWaypointCount(int count);

  /// No description provided for @savedRoutesFavoriteTooltip.
  ///
  /// In en, this message translates to:
  /// **'Add to favorites'**
  String get savedRoutesFavoriteTooltip;

  /// No description provided for @savedRoutesUnfavoriteTooltip.
  ///
  /// In en, this message translates to:
  /// **'Remove from favorites'**
  String get savedRoutesUnfavoriteTooltip;

  /// No description provided for @savedRoutesDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Route details'**
  String get savedRoutesDetailTitle;

  /// Label for read-only route distance on detail screen
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get savedRoutesDetailDistanceLabel;

  /// No description provided for @savedRoutesDetailError.
  ///
  /// In en, this message translates to:
  /// **'Could not load this route.'**
  String get savedRoutesDetailError;

  /// No description provided for @savedRoutesNotFound.
  ///
  /// In en, this message translates to:
  /// **'Route not found.'**
  String get savedRoutesNotFound;

  /// No description provided for @savedRoutesNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get savedRoutesNameLabel;

  /// No description provided for @savedRoutesDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get savedRoutesDescriptionLabel;

  /// No description provided for @savedRoutesNotesLabel.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get savedRoutesNotesLabel;

  /// No description provided for @savedRoutesDurationLabel.
  ///
  /// In en, this message translates to:
  /// **'Estimated duration (minutes)'**
  String get savedRoutesDurationLabel;

  /// No description provided for @savedRoutesDurationHint.
  ///
  /// In en, this message translates to:
  /// **'Optional — estimated paddling time in minutes'**
  String get savedRoutesDurationHint;

  /// No description provided for @savedRoutesDifficultyLabel.
  ///
  /// In en, this message translates to:
  /// **'Difficulty'**
  String get savedRoutesDifficultyLabel;

  /// No description provided for @savedRoutesDifficultyNone.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get savedRoutesDifficultyNone;

  /// No description provided for @savedRoutesDifficultyEasy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get savedRoutesDifficultyEasy;

  /// No description provided for @savedRoutesDifficultyModerate.
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get savedRoutesDifficultyModerate;

  /// No description provided for @savedRoutesDifficultyHard.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get savedRoutesDifficultyHard;

  /// No description provided for @savedRoutesDifficultyExpert.
  ///
  /// In en, this message translates to:
  /// **'Expert'**
  String get savedRoutesDifficultyExpert;

  /// No description provided for @savedRoutesSkillLabel.
  ///
  /// In en, this message translates to:
  /// **'Recommended skill'**
  String get savedRoutesSkillLabel;

  /// No description provided for @savedRoutesSkillNone.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get savedRoutesSkillNone;

  /// No description provided for @savedRoutesCategoriesLabel.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get savedRoutesCategoriesLabel;

  /// No description provided for @savedRoutesCategoryScenic.
  ///
  /// In en, this message translates to:
  /// **'Scenic'**
  String get savedRoutesCategoryScenic;

  /// No description provided for @savedRoutesCategoryTraining.
  ///
  /// In en, this message translates to:
  /// **'Training'**
  String get savedRoutesCategoryTraining;

  /// No description provided for @savedRoutesCategoryCommute.
  ///
  /// In en, this message translates to:
  /// **'Commute'**
  String get savedRoutesCategoryCommute;

  /// No description provided for @savedRoutesCategoryOvernight.
  ///
  /// In en, this message translates to:
  /// **'Overnight'**
  String get savedRoutesCategoryOvernight;

  /// No description provided for @savedRoutesCustomTagsLabel.
  ///
  /// In en, this message translates to:
  /// **'Custom tags'**
  String get savedRoutesCustomTagsLabel;

  /// No description provided for @savedRoutesCustomTagHint.
  ///
  /// In en, this message translates to:
  /// **'Add a tag'**
  String get savedRoutesCustomTagHint;

  /// No description provided for @savedRoutesCustomTagAdd.
  ///
  /// In en, this message translates to:
  /// **'Add tag'**
  String get savedRoutesCustomTagAdd;

  /// No description provided for @savedRoutesFavoriteError.
  ///
  /// In en, this message translates to:
  /// **'Could not update favorite.'**
  String get savedRoutesFavoriteError;

  /// No description provided for @savedRoutesLoadOnMapInsufficientWaypoints.
  ///
  /// In en, this message translates to:
  /// **'Could not load route — too few known launch points.'**
  String get savedRoutesLoadOnMapInsufficientWaypoints;

  /// No description provided for @savedRoutesLoadOnMapDrawError.
  ///
  /// In en, this message translates to:
  /// **'Route loaded, but the map could not draw the line.'**
  String get savedRoutesLoadOnMapDrawError;

  /// No description provided for @savedRoutesWaypointsTitle.
  ///
  /// In en, this message translates to:
  /// **'Waypoints'**
  String get savedRoutesWaypointsTitle;

  /// No description provided for @savedRoutesWaypointSemantics.
  ///
  /// In en, this message translates to:
  /// **'Waypoint {position}, {name}'**
  String savedRoutesWaypointSemantics(int position, String name);

  /// No description provided for @savedRoutesReorderWaypointHint.
  ///
  /// In en, this message translates to:
  /// **'Drag to reorder'**
  String get savedRoutesReorderWaypointHint;

  /// No description provided for @savedRoutesDeleteWaypointSemantics.
  ///
  /// In en, this message translates to:
  /// **'Delete waypoint {position}'**
  String savedRoutesDeleteWaypointSemantics(int position);

  /// No description provided for @savedRoutesUnknownLaunch.
  ///
  /// In en, this message translates to:
  /// **'Unknown launch'**
  String get savedRoutesUnknownLaunch;

  /// No description provided for @savedRoutesSaveButton.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get savedRoutesSaveButton;

  /// No description provided for @savedRoutesLoadOnMapButton.
  ///
  /// In en, this message translates to:
  /// **'Load on map'**
  String get savedRoutesLoadOnMapButton;

  /// No description provided for @savedRoutesDeleteButton.
  ///
  /// In en, this message translates to:
  /// **'Delete route'**
  String get savedRoutesDeleteButton;

  /// No description provided for @savedRoutesNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a route name.'**
  String get savedRoutesNameRequired;

  /// No description provided for @savedRoutesSaveSuccess.
  ///
  /// In en, this message translates to:
  /// **'Route saved.'**
  String get savedRoutesSaveSuccess;

  /// No description provided for @savedRoutesSaveError.
  ///
  /// In en, this message translates to:
  /// **'Could not save route.'**
  String get savedRoutesSaveError;

  /// No description provided for @savedRoutesDeleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete route?'**
  String get savedRoutesDeleteConfirmTitle;

  /// No description provided for @savedRoutesDeleteConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'This removes the route from your device. This cannot be undone.'**
  String get savedRoutesDeleteConfirmBody;

  /// No description provided for @savedRoutesDeleteError.
  ///
  /// In en, this message translates to:
  /// **'Could not delete route.'**
  String get savedRoutesDeleteError;

  /// No description provided for @savedRoutesSaveDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Save route'**
  String get savedRoutesSaveDialogTitle;

  /// No description provided for @savedRoutesSaveFromMapButton.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get savedRoutesSaveFromMapButton;

  /// No description provided for @mapPlanningSaveLabel.
  ///
  /// In en, this message translates to:
  /// **'Save route'**
  String get mapPlanningSaveLabel;

  /// No description provided for @mapPlanningWaypointCount.
  ///
  /// In en, this message translates to:
  /// **'{count} stops'**
  String mapPlanningWaypointCount(int count);

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @tripsFromHereSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Trips from here'**
  String get tripsFromHereSectionTitle;

  /// No description provided for @tripsFromHereBand5Mi.
  ///
  /// In en, this message translates to:
  /// **'Within 5 mi'**
  String get tripsFromHereBand5Mi;

  /// No description provided for @tripsFromHereBand10Mi.
  ///
  /// In en, this message translates to:
  /// **'Within 10 mi'**
  String get tripsFromHereBand10Mi;

  /// No description provided for @tripsFromHereBand20Mi.
  ///
  /// In en, this message translates to:
  /// **'Within 20 mi'**
  String get tripsFromHereBand20Mi;

  /// No description provided for @tripsFromHereBandEmpty5Mi.
  ///
  /// In en, this message translates to:
  /// **'No launches within 5 mi along the river'**
  String get tripsFromHereBandEmpty5Mi;

  /// No description provided for @tripsFromHereBandEmpty10Mi.
  ///
  /// In en, this message translates to:
  /// **'No launches within 10 mi along the river'**
  String get tripsFromHereBandEmpty10Mi;

  /// No description provided for @tripsFromHereBandEmpty20Mi.
  ///
  /// In en, this message translates to:
  /// **'No launches within 20 mi along the river'**
  String get tripsFromHereBandEmpty20Mi;

  /// No description provided for @tripsFromHereNoNearbyLaunches.
  ///
  /// In en, this message translates to:
  /// **'No nearby launches found along the river from here.'**
  String get tripsFromHereNoNearbyLaunches;

  /// No description provided for @tripsFromHereLoadError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load nearby launches.'**
  String get tripsFromHereLoadError;

  /// No description provided for @tripsFromHereBandShowMore.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Show 1 more launch} other{Show {count} more launches}}'**
  String tripsFromHereBandShowMore(int count);

  /// No description provided for @tripsFromHerePlanToLaunchSemantics.
  ///
  /// In en, this message translates to:
  /// **'Plan route to {launchName}, {riverName}'**
  String tripsFromHerePlanToLaunchSemantics(
    String launchName,
    String riverName,
  );

  /// No description provided for @tripsFromHereBandSemantics.
  ///
  /// In en, this message translates to:
  /// **'{bandLabel}, {count, plural, =0{no launches} =1{1 launch} other{{count} launches}}'**
  String tripsFromHereBandSemantics(String bandLabel, int count);

  /// No description provided for @tripsFromHereSuggestedTitle.
  ///
  /// In en, this message translates to:
  /// **'Suggested trips'**
  String get tripsFromHereSuggestedTitle;

  /// No description provided for @tripsFromHereFilterShort.
  ///
  /// In en, this message translates to:
  /// **'Short'**
  String get tripsFromHereFilterShort;

  /// No description provided for @tripsFromHereFilterMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get tripsFromHereFilterMedium;

  /// No description provided for @tripsFromHereFilterLong.
  ///
  /// In en, this message translates to:
  /// **'Long'**
  String get tripsFromHereFilterLong;

  /// No description provided for @tripsFromHereSuggestedTripSemantics.
  ///
  /// In en, this message translates to:
  /// **'Suggested trip to {launchName}, {distanceMi} miles, about {minutes} minutes'**
  String tripsFromHereSuggestedTripSemantics(
    String launchName,
    String distanceMi,
    int minutes,
  );

  /// No description provided for @tripsFromHereSuggestedEmpty.
  ///
  /// In en, this message translates to:
  /// **'No suggested trips match this filter.'**
  String get tripsFromHereSuggestedEmpty;

  /// No description provided for @tripsFromHereSuggestedSearchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search nearby launches...'**
  String get tripsFromHereSuggestedSearchPlaceholder;

  /// No description provided for @tripsFromHereMaxDistanceLabel.
  ///
  /// In en, this message translates to:
  /// **'Within'**
  String get tripsFromHereMaxDistanceLabel;

  /// No description provided for @tripsFromHereMaxDistance5Miles.
  ///
  /// In en, this message translates to:
  /// **'5 Miles'**
  String get tripsFromHereMaxDistance5Miles;

  /// No description provided for @tripsFromHereMaxDistance10Miles.
  ///
  /// In en, this message translates to:
  /// **'10 Miles'**
  String get tripsFromHereMaxDistance10Miles;

  /// No description provided for @tripsFromHereMaxDistance20Miles.
  ///
  /// In en, this message translates to:
  /// **'20 Miles'**
  String get tripsFromHereMaxDistance20Miles;

  /// No description provided for @tripsFromHereSuggestedEntrySubtitle.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 nearby launch} other{{count} nearby launches}}'**
  String tripsFromHereSuggestedEntrySubtitle(int count);

  /// Route go/no-go summary when weather fetch failed for a stop
  ///
  /// In en, this message translates to:
  /// **'Weather data failed to load. Cannot assess wind from forecast.'**
  String get routeGoNoGoReasonWeatherMissingSummary;

  /// Accessibility label while route go/no-go rollup loads
  ///
  /// In en, this message translates to:
  /// **'Loading route conditions…'**
  String get routeGoNoGoLoading;

  /// No description provided for @routeGoNoGoErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Route conditions could not be loaded.'**
  String get routeGoNoGoErrorGeneric;

  /// No description provided for @routeGoNoGoTriggeringStop.
  ///
  /// In en, this message translates to:
  /// **'Worst at {stopName}'**
  String routeGoNoGoTriggeringStop(String stopName);

  /// No description provided for @routeGoNoGoAllStopsTitle.
  ///
  /// In en, this message translates to:
  /// **'All stops'**
  String get routeGoNoGoAllStopsTitle;

  /// No description provided for @routeGoNoGoStopLine.
  ///
  /// In en, this message translates to:
  /// **'{position}. {name} — {verdict}'**
  String routeGoNoGoStopLine(int position, String name, String verdict);

  /// No description provided for @routeGoNoGoPartialFailuresTitle.
  ///
  /// In en, this message translates to:
  /// **'Some stops could not load conditions:'**
  String get routeGoNoGoPartialFailuresTitle;

  /// Partial-failure message when a route stop references an unknown launch id
  ///
  /// In en, this message translates to:
  /// **'Launch not found in catalog.'**
  String get routeGoNoGoLaunchNotFound;

  /// Partial-failure message when conditions for a route stop could not be loaded
  ///
  /// In en, this message translates to:
  /// **'Conditions could not be loaded for this stop.'**
  String get routeGoNoGoStopConditionsUnavailable;

  /// No description provided for @routeGoNoGoStopFailureLine.
  ///
  /// In en, this message translates to:
  /// **'{position}. {name}: {message}'**
  String routeGoNoGoStopFailureLine(int position, String name, String message);

  /// No description provided for @routeGoNoGoRouteDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Not a substitute for your judgment, skill, or scouting on site.'**
  String get routeGoNoGoRouteDisclaimer;

  /// No description provided for @routeGoNoGoSemanticsVerdictOnly.
  ///
  /// In en, this message translates to:
  /// **'Route conditions: {verdict}'**
  String routeGoNoGoSemanticsVerdictOnly(String verdict);

  /// No description provided for @routeGoNoGoSemanticsVerdictWithStop.
  ///
  /// In en, this message translates to:
  /// **'Route conditions: {verdict}. {stopName}.'**
  String routeGoNoGoSemanticsVerdictWithStop(String verdict, String stopName);

  /// No description provided for @moderationQueueTitle.
  ///
  /// In en, this message translates to:
  /// **'Review Reports'**
  String get moderationQueueTitle;

  /// No description provided for @moderationQueueEmpty.
  ///
  /// In en, this message translates to:
  /// **'No reports waiting for review.'**
  String get moderationQueueEmpty;

  /// No description provided for @moderationQueueLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load the review queue.'**
  String get moderationQueueLoadError;

  /// No description provided for @moderationApprove.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get moderationApprove;

  /// No description provided for @moderationReject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get moderationReject;

  /// No description provided for @moderationActionError.
  ///
  /// In en, this message translates to:
  /// **'Could not update that report. Try again.'**
  String get moderationActionError;

  /// No description provided for @moderationTabPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get moderationTabPending;

  /// No description provided for @moderationTabHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get moderationTabHistory;

  /// No description provided for @moderationHistoryEmpty.
  ///
  /// In en, this message translates to:
  /// **'No moderation history yet.'**
  String get moderationHistoryEmpty;

  /// No description provided for @moderationHistoryLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load moderation history.'**
  String get moderationHistoryLoadError;

  /// No description provided for @moderationLaunchSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by ID or name...'**
  String get moderationLaunchSearchHint;

  /// No description provided for @moderationSortOldestWaiting.
  ///
  /// In en, this message translates to:
  /// **'Oldest waiting'**
  String get moderationSortOldestWaiting;

  /// No description provided for @moderationSortMostRecent.
  ///
  /// In en, this message translates to:
  /// **'Most recent'**
  String get moderationSortMostRecent;

  /// No description provided for @moderationSortRecentAction.
  ///
  /// In en, this message translates to:
  /// **'Recent action'**
  String get moderationSortRecentAction;

  /// No description provided for @moderationSortOldestAction.
  ///
  /// In en, this message translates to:
  /// **'Oldest action'**
  String get moderationSortOldestAction;

  /// No description provided for @moderationDateFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All dates'**
  String get moderationDateFilterAll;

  /// No description provided for @moderationDateFilter7Days.
  ///
  /// In en, this message translates to:
  /// **'Last 7 days'**
  String get moderationDateFilter7Days;

  /// No description provided for @moderationDateFilter30Days.
  ///
  /// In en, this message translates to:
  /// **'Last 30 days'**
  String get moderationDateFilter30Days;

  /// No description provided for @moderationStatusFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All outcomes'**
  String get moderationStatusFilterAll;

  /// No description provided for @moderationStatusFilterApproved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get moderationStatusFilterApproved;

  /// No description provided for @moderationStatusFilterRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get moderationStatusFilterRejected;

  /// No description provided for @moderationSubmitterUid.
  ///
  /// In en, this message translates to:
  /// **'Submitter'**
  String get moderationSubmitterUid;

  /// No description provided for @moderationModeratorUid.
  ///
  /// In en, this message translates to:
  /// **'Moderator'**
  String get moderationModeratorUid;

  /// No description provided for @moderationSystemActor.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get moderationSystemActor;

  /// No description provided for @moderationHoldReason.
  ///
  /// In en, this message translates to:
  /// **'Hold Reason'**
  String get moderationHoldReason;

  /// No description provided for @moderationMessage.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get moderationMessage;

  /// No description provided for @moderationSubmittedAt.
  ///
  /// In en, this message translates to:
  /// **'Submitted'**
  String get moderationSubmittedAt;

  /// No description provided for @moderationReviewedAt.
  ///
  /// In en, this message translates to:
  /// **'Reviewed'**
  String get moderationReviewedAt;

  /// No description provided for @moderationWaitingDays.
  ///
  /// In en, this message translates to:
  /// **'Waiting {days} days'**
  String moderationWaitingDays(int days);

  /// No description provided for @moderationCopyUid.
  ///
  /// In en, this message translates to:
  /// **'Copy UID'**
  String get moderationCopyUid;

  /// No description provided for @moderationUidCopied.
  ///
  /// In en, this message translates to:
  /// **'UID copied'**
  String get moderationUidCopied;

  /// No description provided for @moderationSelectAll.
  ///
  /// In en, this message translates to:
  /// **'Select all'**
  String get moderationSelectAll;

  /// No description provided for @moderationClearSelection.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get moderationClearSelection;

  /// No description provided for @moderationBulkSelect.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get moderationBulkSelect;

  /// No description provided for @moderationBulkSelectDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get moderationBulkSelectDone;

  /// No description provided for @moderationReasonKeywordHold.
  ///
  /// In en, this message translates to:
  /// **'Matched moderation keyword'**
  String get moderationReasonKeywordHold;

  /// No description provided for @moderationReasonAdminApprove.
  ///
  /// In en, this message translates to:
  /// **'Approved by moderator'**
  String get moderationReasonAdminApprove;

  /// No description provided for @moderationReasonAdminReject.
  ///
  /// In en, this message translates to:
  /// **'Rejected by moderator'**
  String get moderationReasonAdminReject;

  /// No description provided for @moderationReasonAdminReopen.
  ///
  /// In en, this message translates to:
  /// **'Returned to pending by moderator'**
  String get moderationReasonAdminReopen;

  /// No description provided for @moderationReasonHoldTimeout.
  ///
  /// In en, this message translates to:
  /// **'Auto-approved after hold period'**
  String get moderationReasonHoldTimeout;

  /// No description provided for @moderationBulkApprove.
  ///
  /// In en, this message translates to:
  /// **'Approve selected'**
  String get moderationBulkApprove;

  /// No description provided for @moderationBulkReject.
  ///
  /// In en, this message translates to:
  /// **'Reject selected'**
  String get moderationBulkReject;

  /// No description provided for @moderationBulkApproveConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Approve selected reports?'**
  String get moderationBulkApproveConfirmTitle;

  /// No description provided for @moderationBulkApproveConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'These reports will become visible to paddlers.'**
  String get moderationBulkApproveConfirmBody;

  /// No description provided for @moderationBulkRejectConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Reject selected reports?'**
  String get moderationBulkRejectConfirmTitle;

  /// No description provided for @moderationBulkRejectConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'These reports will stay hidden from the public list.'**
  String get moderationBulkRejectConfirmBody;

  /// No description provided for @moderationBatchPartialFailure.
  ///
  /// In en, this message translates to:
  /// **'Could not update {count} selected reports.'**
  String moderationBatchPartialFailure(int count);

  /// No description provided for @moderationReturnToPending.
  ///
  /// In en, this message translates to:
  /// **'Return to pending'**
  String get moderationReturnToPending;

  /// No description provided for @moderationReturnToPendingConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Return report to pending?'**
  String get moderationReturnToPendingConfirmTitle;

  /// No description provided for @moderationReturnToPendingConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'This report will reappear on the pending tab for review. If it was approved, it will be removed from the public list.'**
  String get moderationReturnToPendingConfirmBody;

  /// No description provided for @launchDetailReviewReportsButton.
  ///
  /// In en, this message translates to:
  /// **'Review Reports'**
  String get launchDetailReviewReportsButton;
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
