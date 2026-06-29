import 'package:eddyscout_conditions/src/domain/condition_report_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('parseConditionReportModerationStatus', () {
    test('parses held and rejected', () {
      expect(
        parseConditionReportModerationStatus('held'),
        ConditionReportModerationStatus.held,
      );
      expect(
        parseConditionReportModerationStatus('rejected'),
        ConditionReportModerationStatus.rejected,
      );
    });

    test('defaults unknown values to approved', () {
      expect(
        parseConditionReportModerationStatus('approved'),
        ConditionReportModerationStatus.approved,
      );
      expect(
        parseConditionReportModerationStatus('other'),
        ConditionReportModerationStatus.approved,
      );
    });
  });

  group('ModerationBatchFailure.fromJson', () {
    test('throws on invalid payload', () {
      expect(
        () => ModerationBatchFailure.fromJson({'reportId': 1, 'code': 'x'}),
        throwsA(isA<FormatException>()),
      );
    });
  });

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
        'submitterUid': 'uid-123',
        'moderationReason': 'keyword_hold',
        'holdAgeDays': 2,
      });

      expect(report.id, 'abc');
      expect(report.submitterUid, 'uid-123');
      expect(report.holdAgeDays, 2);
      expect(report.moderationReason, 'keyword_hold');
    });
  });

  group('ModerationHistoryReport.fromJson', () {
    test('parses audit row', () {
      final report = ModerationHistoryReport.fromJson({
        'id': 'abc',
        'launchId': 'sellwood',
        'message': 'Held note',
        'createdAt': '2026-06-15T12:00:00-07:00',
        'submitterUid': 'uid-123',
        'moderationStatus': 'approved',
        'moderationReason': 'admin_approve',
        'reviewedAt': '2026-06-16T12:00:00-07:00',
        'reviewedBy': 'mod-1',
      });

      expect(report.reviewedBy, 'mod-1');
      expect(
        report.moderationStatus,
        ConditionReportModerationStatus.approved,
      );
    });
  });

  group('ModerationBatchModerateResult.fromJson', () {
    test('parses succeeded and failed ids', () {
      final result = ModerationBatchModerateResult.fromJson({
        'succeeded': ['a'],
        'failed': [
          {'reportId': 'b', 'code': 'not-found'},
        ],
      });

      expect(result.succeeded, ['a']);
      expect(result.failed.single.reportId, 'b');
    });
  });
}
