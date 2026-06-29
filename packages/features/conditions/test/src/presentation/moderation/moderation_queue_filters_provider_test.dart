import 'package:eddyscout_conditions/eddyscout_conditions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ModerationPendingFilters', () {
    test('updates launch query and trims whitespace', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container
          .read(moderationPendingFiltersProvider.notifier)
          .setLaunchQuery('  sellwood  ');

      expect(
        container.read(moderationPendingFiltersProvider).launchQuery,
        'sellwood',
      );
    });

    test('updates submitted date filter and sort', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(
        moderationPendingFiltersProvider.notifier,
      );
      notifier.setSubmittedDateFilter(ModerationSubmittedDateFilter.last7Days);
      notifier.setSort(ModerationQueueSort.createdAtDesc);

      final state = container.read(moderationPendingFiltersProvider);
      expect(
        state.submittedDateFilter,
        ModerationSubmittedDateFilter.last7Days,
      );
      expect(state.sort, ModerationQueueSort.createdAtDesc);
    });
  });

  group('ModerationHistoryFilters', () {
    test('updates history filters', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(
        moderationHistoryFiltersProvider.notifier,
      );
      notifier.setLaunchQuery('cathedral');
      notifier.setStatus(ModerationHistoryStatusFilter.approved);
      notifier.setReviewedDateFilter(ModerationReviewedDateFilter.last30Days);
      notifier.setSort(ModerationHistorySort.reviewedAtAsc);

      final state = container.read(moderationHistoryFiltersProvider);
      expect(state.launchQuery, 'cathedral');
      expect(state.status, ModerationHistoryStatusFilter.approved);
      expect(state.reviewedDateFilter, ModerationReviewedDateFilter.last30Days);
      expect(state.sort, ModerationHistorySort.reviewedAtAsc);
    });
  });

  group('submittedAfterForFilter', () {
    test('returns null for all', () {
      expect(
        submittedAfterForFilter(ModerationSubmittedDateFilter.all),
        isNull,
      );
    });

    test('returns cutoff for date presets', () {
      final cutoff = submittedAfterForFilter(
        ModerationSubmittedDateFilter.last7Days,
      );
      expect(cutoff, isNotNull);
      expect(
        DateTime.now().toUtc().difference(cutoff!).inDays,
        inInclusiveRange(6, 8),
      );
    });
  });

  group('reviewedAfterForFilter', () {
    test('returns null for all', () {
      expect(reviewedAfterForFilter(ModerationReviewedDateFilter.all), isNull);
    });
  });

  group('resolveLaunchIdFilter', () {
    test('returns null for empty query', () {
      expect(resolveLaunchIdFilter(''), isNull);
      expect(resolveLaunchIdFilter('   '), isNull);
    });

    test('returns id when query matches catalog', () {
      expect(
        resolveLaunchIdFilter('sellwood_riverfront'),
        'sellwood_riverfront',
      );
    });

    test('returns null for unknown partial search text', () {
      expect(resolveLaunchIdFilter('sellwood'), isNull);
    });
  });

  group('filterPendingReportsClientSide', () {
    final reports = [
      ModerationQueueReport(
        id: '1',
        launchId: 'sellwood_riverfront',
        message: 'A',
        createdAt: DateTime.utc(2026, 6, 1),
        submitterUid: 'u1',
      ),
      ModerationQueueReport(
        id: '2',
        launchId: 'cathedral_park',
        message: 'B',
        createdAt: DateTime.utc(2026, 6, 2),
        submitterUid: 'u2',
      ),
    ];

    test('returns all reports when query empty', () {
      expect(
        filterPendingReportsClientSide(reports: reports, launchQuery: ''),
        reports,
      );
    });

    test('filters by launch id substring', () {
      final filtered = filterPendingReportsClientSide(
        reports: reports,
        launchQuery: 'cathedral',
      );
      expect(filtered, hasLength(1));
      expect(filtered.single.launchId, 'cathedral_park');
    });

    test('filters by display name substring', () {
      final filtered = filterPendingReportsClientSide(
        reports: reports,
        launchQuery: 'sellwood',
      );
      expect(filtered, hasLength(1));
      expect(filtered.single.id, '1');
    });
  });

  group('filterHistoryReportsClientSide', () {
    final reports = [
      ModerationHistoryReport(
        id: '1',
        launchId: 'sellwood_riverfront',
        message: 'A',
        createdAt: DateTime.utc(2026, 6, 1),
        submitterUid: 'u1',
        moderationStatus: ConditionReportModerationStatus.approved,
        reviewedAt: DateTime.utc(2026, 6, 2),
      ),
    ];

    test('filters history by launch name', () {
      final filtered = filterHistoryReportsClientSide(
        reports: reports,
        launchQuery: 'riverfront',
      );
      expect(filtered, hasLength(1));
    });
  });
}
