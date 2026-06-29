import 'package:eddyscout_conditions/src/presentation/moderation/moderation_display_helpers.dart';
import 'package:eddyscout_localization/eddyscout_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('resolveLaunchDisplayName uses catalog name when known', (
    tester,
  ) async {
    expect(
      resolveLaunchDisplayName('cathedral_park'),
      'Cathedral Park Boat Ramp',
    );
    expect(resolveLaunchDisplayName('unknown_launch'), 'unknown_launch');
  });

  testWidgets('formatModerationReason maps known codes and falls back', (
    tester,
  ) async {
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
      formatModerationReason(l10n, 'custom_reason_code'),
      'custom reason code',
    );
  });

  test('truncateUid keeps short ids and truncates long ids', () {
    expect(truncateUid('abc'), 'abc');
    expect(truncateUid('1234567890'), '12345678');
    expect(truncateUid('1234567890', length: 4), '1234');
  });
}
