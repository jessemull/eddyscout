import 'package:eddyscout_conditions/src/domain/condition_report_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ConditionReportSubmitResult.fromJson', () {
    test('defaults to approved when status missing', () {
      final result = ConditionReportSubmitResult.fromJson({'ok': true});
      expect(result.moderationStatus, ConditionReportModerationStatus.approved);
      expect(result.isPubliclyVisible, isTrue);
    });

    test('parses held status', () {
      final result = ConditionReportSubmitResult.fromJson({
        'moderationStatus': 'held',
      });
      expect(result.moderationStatus, ConditionReportModerationStatus.held);
      expect(result.isPubliclyVisible, isFalse);
    });
  });

  group('ConditionReportsListResult.fromJson', () {
    test('parses reports and pending flag', () {
      final result = ConditionReportsListResult.fromJson({
        'reports': [
          {
            'message': 'Calm',
            'createdAt': '2026-06-15T12:00:00-07:00',
            'isMine': false,
          },
        ],
        'viewerHasPendingReport': true,
      });

      expect(result.reports, hasLength(1));
      expect(result.viewerHasPendingReport, isTrue);
    });
  });

  group('ModerationQueueReport.fromJson', () {
    test('parses queue row', () {
      final report = ModerationQueueReport.fromJson({
        'id': 'abc',
        'launchId': 'sellwood',
        'message': 'Held note',
        'createdAt': '2026-06-15T12:00:00-07:00',
        'moderationReason': 'keyword_hold',
      });

      expect(report.id, 'abc');
      expect(report.moderationReason, 'keyword_hold');
    });
  });
}
