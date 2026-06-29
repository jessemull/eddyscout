import 'package:eddyscout_conditions/eddyscout_conditions.dart';
import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final reportA = ModerationQueueReport(
    id: 'a',
    launchId: 'cathedral_park',
    message: 'Windy',
    createdAt: DateTime.utc(2026, 6, 15),
    submitterUid: 'user-a',
  );
  final reportB = ModerationQueueReport(
    id: 'b',
    launchId: 'sellwood_riverfront',
    message: 'Calm',
    createdAt: DateTime.utc(2026, 6, 16),
    submitterUid: 'user-b',
  );
  final historyA = ModerationHistoryReport(
    id: 'h1',
    launchId: 'cathedral_park',
    message: 'Approved',
    createdAt: DateTime.utc(2026, 6, 10),
    submitterUid: 'user-a',
    moderationStatus: ConditionReportModerationStatus.approved,
    moderationReason: 'admin_approve',
    reviewedAt: DateTime.utc(2026, 6, 11),
    reviewedBy: 'mod',
  );

  group('date filter helpers', () {
    test('submittedAfterForFilter returns null or recent cutoff', () {
      expect(submittedAfterForFilter(ModerationSubmittedDateFilter.all), isNull);
      final last7 = submittedAfterForFilter(
        ModerationSubmittedDateFilter.last7Days,
      );
      final last30 = submittedAfterForFilter(
        ModerationSubmittedDateFilter.last30Days,
      );
      expect(last7, isNotNull);
      expect(last30, isNotNull);
      expect(last30!.isBefore(last7!), isTrue);
    });

    test('reviewedAfterForFilter returns null or recent cutoff', () {
      expect(reviewedAfterForFilter(ModerationReviewedDateFilter.all), isNull);
      expect(
        reviewedAfterForFilter(ModerationReviewedDateFilter.last7Days),
        isNotNull,
      );
      expect(
        reviewedAfterForFilter(ModerationReviewedDateFilter.last30Days),
        isNotNull,
      );
    });
  });

  group('resolveLaunchIdFilter', () {
    test('returns null for blank or unknown search text', () {
      expect(resolveLaunchIdFilter(''), isNull);
      expect(resolveLaunchIdFilter('   '), isNull);
      expect(resolveLaunchIdFilter('not_a_launch'), isNull);
    });

    test('returns exact id when search matches catalog launch', () {
      expect(resolveLaunchIdFilter('cathedral_park'), 'cathedral_park');
    });
  });

  group('client-side filters', () {
    test('filterPendingReportsClientSide matches id and display name', () {
      expect(
        filterPendingReportsClientSide(reports: [reportA, reportB], launchQuery: ''),
        [reportA, reportB],
      );
      expect(
        filterPendingReportsClientSide(
          reports: [reportA, reportB],
          launchQuery: 'cathedral',
        ),
        [reportA],
      );
      expect(
        filterPendingReportsClientSide(
          reports: [reportA, reportB],
          launchQuery: 'boat ramp',
        ),
        [reportA],
      );
    });

    test('filterHistoryReportsClientSide matches id and display name', () {
      expect(
        filterHistoryReportsClientSide(reports: [historyA], launchQuery: 'sellwood'),
        isEmpty,
      );
      expect(
        filterHistoryReportsClientSide(reports: [historyA], launchQuery: 'cathedral'),
        [historyA],
      );
    });
  });

  group('filter notifiers', () {
    test('ModerationPendingFilters updates launch, date, and sort', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(moderationPendingFiltersProvider.notifier);
      notifier
        ..setLaunchQuery('  cathedral_park  ')
        ..setSubmittedDateFilter(ModerationSubmittedDateFilter.last7Days)
        ..setSort(ModerationQueueSort.createdAtDesc);

      final state = container.read(moderationPendingFiltersProvider);
      expect(state.launchQuery, 'cathedral_park');
      expect(state.submittedDateFilter, ModerationSubmittedDateFilter.last7Days);
      expect(state.sort, ModerationQueueSort.createdAtDesc);
    });

    test('ModerationHistoryFilters updates launch, status, date, and sort', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(moderationHistoryFiltersProvider.notifier);
      notifier
        ..setLaunchQuery(' sellwood ')
        ..setStatus(ModerationHistoryStatusFilter.approved)
        ..setReviewedDateFilter(ModerationReviewedDateFilter.last30Days)
        ..setSort(ModerationHistorySort.reviewedAtAsc);

      final state = container.read(moderationHistoryFiltersProvider);
      expect(state.launchQuery, 'sellwood');
      expect(state.status, ModerationHistoryStatusFilter.approved);
      expect(state.reviewedDateFilter, ModerationReviewedDateFilter.last30Days);
      expect(state.sort, ModerationHistorySort.reviewedAtAsc);
    });

    test('filter state copyWith preserves unchanged fields', () {
      const pending = ModerationPendingFiltersState(
        launchQuery: 'a',
        submittedDateFilter: ModerationSubmittedDateFilter.last7Days,
      );
      expect(
        pending.copyWith(sort: ModerationQueueSort.createdAtDesc).launchQuery,
        'a',
      );

      const history = ModerationHistoryFiltersState(
        launchQuery: 'b',
        status: ModerationHistoryStatusFilter.rejected,
      );
      expect(
        history.copyWith(limit: 50).status,
        ModerationHistoryStatusFilter.rejected,
      );
    });
  });
}
