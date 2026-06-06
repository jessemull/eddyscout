import 'package:eddyscout_localization/eddyscout_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Resolves generated strings from the pumped app shell MaterialApp.
AppLocalizations integrationL10n(WidgetTester tester) =>
    AppLocalizations.of(tester.element(find.byType(MaterialApp)));
