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

  /// Map screen app bar title
  ///
  /// In en, this message translates to:
  /// **'EddyScout'**
  String get mapScreenTitle;

  /// App bar action to enter route planning mode
  ///
  /// In en, this message translates to:
  /// **'Plan river route'**
  String get mapPlanRouteTooltip;

  /// App bar action to leave route planning mode
  ///
  /// In en, this message translates to:
  /// **'Exit route planning'**
  String get mapExitPlanningTooltip;

  /// Accessibility label for map zoom in control
  ///
  /// In en, this message translates to:
  /// **'Zoom in'**
  String get mapZoomInLabel;

  /// Accessibility label for map zoom out control
  ///
  /// In en, this message translates to:
  /// **'Zoom out'**
  String get mapZoomOutLabel;

  /// Accessibility label for fit-all-launches control
  ///
  /// In en, this message translates to:
  /// **'Show all launches'**
  String get mapShowAllLaunchesLabel;

  /// Snack bar when take-out equals put-in
  ///
  /// In en, this message translates to:
  /// **'Pick a different launch for take-out.'**
  String get mapPickDifferentTakeOut;

  /// Snack bar when hydro planner is not ready
  ///
  /// In en, this message translates to:
  /// **'Still loading river data… try again.'**
  String get mapRiverDataLoading;

  /// Error when conditions fetch fails due to network
  ///
  /// In en, this message translates to:
  /// **'Could not load conditions. Check your connection and try again.'**
  String get launchDetailConditionsErrorNetwork;

  /// Generic conditions load error
  ///
  /// In en, this message translates to:
  /// **'Could not load conditions. Pull to refresh or try again later.'**
  String get launchDetailConditionsErrorGeneric;

  /// Section title for go/no-go skill profile selector
  ///
  /// In en, this message translates to:
  /// **'Skill (wind thresholds)'**
  String get launchDetailSkillSectionTitle;

  /// Beginner skill profile segment label
  ///
  /// In en, this message translates to:
  /// **'Beginner'**
  String get launchDetailSkillBeginner;

  /// Intermediate skill profile segment label
  ///
  /// In en, this message translates to:
  /// **'Intermed.'**
  String get launchDetailSkillIntermediate;

  /// Advanced skill profile segment label
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get launchDetailSkillAdvanced;

  /// Error after failed condition report submit
  ///
  /// In en, this message translates to:
  /// **'Could not submit report. Try again in a moment.'**
  String get launchDetailReportSubmitError;

  /// Error after failed community digest fetch
  ///
  /// In en, this message translates to:
  /// **'Could not load digest. Try again.'**
  String get launchDetailDigestError;

  /// Error after failed AI conditions summary
  ///
  /// In en, this message translates to:
  /// **'Could not load AI summary. Try again.'**
  String get launchDetailAiSummaryError;

  /// Generic cancel button label
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelButton;

  /// Generic submit button label
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submitButton;

  /// Route planning put-in launch label
  ///
  /// In en, this message translates to:
  /// **'Put-in'**
  String get mapPlanningPutInLabel;

  /// Route planning take-out launch label
  ///
  /// In en, this message translates to:
  /// **'Take-out'**
  String get mapPlanningTakeOutLabel;

  /// Clear route planning selection
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get mapPlanningClearLabel;

  /// Finish route planning mode
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get mapPlanningDoneLabel;

  /// Screen title when MAPBOX_ACCESS_TOKEN is missing
  ///
  /// In en, this message translates to:
  /// **'Mapbox token required'**
  String get missingMapboxTokenTitle;

  /// Web placeholder screen title
  ///
  /// In en, this message translates to:
  /// **'Map on mobile'**
  String get webMapPlaceholderTitle;

  /// Web placeholder screen body
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
