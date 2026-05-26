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
  String get mapPickDifferentTakeOut => 'Pick a different launch for take-out.';

  @override
  String get mapRiverDataLoading => 'Still loading river data… try again.';

  @override
  String get launchDetailConditionsErrorNetwork =>
      'Could not load conditions. Check your connection and try again.';

  @override
  String get launchDetailConditionsErrorGeneric =>
      'Could not load conditions. Pull to refresh or try again later.';

  @override
  String get launchDetailSkillSectionTitle => 'Skill (wind thresholds)';

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
  String get cancelButton => 'Cancel';

  @override
  String get submitButton => 'Submit';

  @override
  String get mapPlanningPutInLabel => 'Put-in';

  @override
  String get mapPlanningTakeOutLabel => 'Take-out';

  @override
  String get mapPlanningClearLabel => 'Clear';

  @override
  String get mapPlanningDoneLabel => 'Done';

  @override
  String get missingMapboxTokenTitle => 'Mapbox token required';

  @override
  String get webMapPlaceholderTitle => 'Map on mobile';

  @override
  String get webMapPlaceholderBody =>
      'Use the Android or iOS app for the interactive map.';
}
