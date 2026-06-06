import 'package:eddyscout_localization/eddyscout_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Resolves generated strings from a descendant of [MaterialApp] that carries
/// [AppLocalizations] (the app element itself does not).
AppLocalizations integrationL10n(WidgetTester tester) => AppLocalizations.of(
  tester.element(
    find
        .descendant(
          of: find.byType(MaterialApp),
          matching: find.byType(Scaffold),
        )
        .first,
  ),
);
