import 'package:eddyscout_localization/generated/app_localizations.dart';
import 'package:flutter/widgets.dart';

/// Convenient access to generated localizations.
extension L10nContext on BuildContext {
  /// Non-null [AppLocalizations] for this build context.
  AppLocalizations get l10n => AppLocalizations.of(this);
}
