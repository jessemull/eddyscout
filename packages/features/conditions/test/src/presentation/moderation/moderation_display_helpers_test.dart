import 'package:eddyscout_conditions/src/presentation/moderation/moderation_display_helpers.dart';
import 'package:eddyscout_localization/eddyscout_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('resolveLaunchDisplayName', () {
    test('returns catalog name for known launch id', () {
      expect(
        resolveLaunchDisplayName('sellwood_riverfront'),
        'Sellwood Riverfront Park',
      );
    });

    test('returns raw id when launch is unknown', () {
      expect(resolveLaunchDisplayName('unknown_launch'), 'unknown_launch');
    });
  });

  group('truncateUid', () {
    test('returns full uid when shorter than limit', () {
      expect(truncateUid('abc'), 'abc');
    });

    test('truncates long uids', () {
      expect(truncateUid('abcdefghijklmnop'), 'abcdefgh');
    });

    test('respects custom length', () {
      expect(truncateUid('abcdefghij', length: 4), 'abcd');
    });
  });

  group('formatModerationReason', () {
    testWidgets('maps known reason codes to localized strings', (tester) async {
      late AppLocalizations l10n;

      await tester.pumpWidget(
        const MaterialApp(
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: SizedBox.shrink(),
        ),
      );
      l10n = AppLocalizations.of(tester.element(find.byType(SizedBox)));

      expect(
        formatModerationReason(l10n, 'keyword_hold'),
        l10n.moderationReasonKeywordHold,
      );
      expect(
        formatModerationReason(l10n, 'admin_approve'),
        l10n.moderationReasonAdminApprove,
      );
      expect(
        formatModerationReason(l10n, 'hold_timeout_release'),
        l10n.moderationReasonHoldTimeout,
      );
    });

    testWidgets('falls back to humanized unknown codes', (tester) async {
      late AppLocalizations l10n;

      await tester.pumpWidget(
        const MaterialApp(
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: SizedBox.shrink(),
        ),
      );
      l10n = AppLocalizations.of(tester.element(find.byType(SizedBox)));

      expect(formatModerationReason(l10n, 'custom_reason'), 'custom reason');
    });
  });
}
