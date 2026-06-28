part of 'moderation_queue_screen.dart';

const double _moderationRowSpacing = Spacing.sm;
const double _moderationFilterHorizontalPadding = Spacing.sm;
const double _moderationFilterTopPadding = Spacing.sm + Spacing.xs;
const double _moderationCardHorizontalGutter = Spacing.md;

ButtonStyle _moderationFilterTextButtonStyle() {
  return TextButton.styleFrom(
    visualDensity: VisualDensity.compact,
    padding: const EdgeInsets.symmetric(horizontal: Spacing.sm),
    minimumSize: Size.zero,
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
  );
}

class _ModerationFilterBar extends StatelessWidget {
  const _ModerationFilterBar({
    required this.launchSearchController,
    required this.launchQuery,
    required this.onLaunchQueryChanged,
    this.pendingSort,
    this.onPendingSortChanged,
    this.historySort,
    this.onHistorySortChanged,
    this.submittedDateFilter,
    this.onSubmittedDateFilterChanged,
    this.reviewedDateFilter,
    this.onReviewedDateFilterChanged,
    this.statusFilter,
    this.onStatusFilterChanged,
    this.bulkSelectActive = false,
    this.onBulkSelectToggle,
    this.onSelectAll,
    this.onClearSelection,
    this.canClearSelection = false,
  });

  final TextEditingController launchSearchController;
  final String launchQuery;
  final ValueChanged<String> onLaunchQueryChanged;
  final ModerationQueueSort? pendingSort;
  final ValueChanged<ModerationQueueSort>? onPendingSortChanged;
  final ModerationHistorySort? historySort;
  final ValueChanged<ModerationHistorySort>? onHistorySortChanged;
  final ModerationSubmittedDateFilter? submittedDateFilter;
  final ValueChanged<ModerationSubmittedDateFilter>?
  onSubmittedDateFilterChanged;
  final ModerationReviewedDateFilter? reviewedDateFilter;
  final ValueChanged<ModerationReviewedDateFilter>? onReviewedDateFilterChanged;
  final ModerationHistoryStatusFilter? statusFilter;
  final ValueChanged<ModerationHistoryStatusFilter>? onStatusFilterChanged;
  final bool bulkSelectActive;
  final VoidCallback? onBulkSelectToggle;
  final VoidCallback? onSelectAll;
  final VoidCallback? onClearSelection;
  final bool canClearSelection;

  List<Widget> _buildFilterChips(AppLocalizations l10n) {
    return [
      if (pendingSort != null && onPendingSortChanged != null) ...[
        _DateFilterChip(
          label: l10n.moderationSortOldestWaiting,
          selected: pendingSort == ModerationQueueSort.createdAtAsc,
          onSelected: () =>
              onPendingSortChanged!(ModerationQueueSort.createdAtAsc),
        ),
        _DateFilterChip(
          label: l10n.moderationSortMostRecent,
          selected: pendingSort == ModerationQueueSort.createdAtDesc,
          onSelected: () =>
              onPendingSortChanged!(ModerationQueueSort.createdAtDesc),
        ),
      ],
      if (historySort != null && onHistorySortChanged != null) ...[
        _DateFilterChip(
          label: l10n.moderationSortRecentAction,
          selected: historySort == ModerationHistorySort.reviewedAtDesc,
          onSelected: () =>
              onHistorySortChanged!(ModerationHistorySort.reviewedAtDesc),
        ),
        _DateFilterChip(
          label: l10n.moderationSortOldestAction,
          selected: historySort == ModerationHistorySort.reviewedAtAsc,
          onSelected: () =>
              onHistorySortChanged!(ModerationHistorySort.reviewedAtAsc),
        ),
      ],
      if (submittedDateFilter != null &&
          onSubmittedDateFilterChanged != null) ...[
        _DateFilterChip(
          label: l10n.moderationDateFilterAll,
          selected: submittedDateFilter == ModerationSubmittedDateFilter.all,
          onSelected: () =>
              onSubmittedDateFilterChanged!(ModerationSubmittedDateFilter.all),
        ),
        _DateFilterChip(
          label: l10n.moderationDateFilter7Days,
          selected:
              submittedDateFilter == ModerationSubmittedDateFilter.last7Days,
          onSelected: () => onSubmittedDateFilterChanged!(
            ModerationSubmittedDateFilter.last7Days,
          ),
        ),
        _DateFilterChip(
          label: l10n.moderationDateFilter30Days,
          selected:
              submittedDateFilter == ModerationSubmittedDateFilter.last30Days,
          onSelected: () => onSubmittedDateFilterChanged!(
            ModerationSubmittedDateFilter.last30Days,
          ),
        ),
      ],
      if (reviewedDateFilter != null &&
          onReviewedDateFilterChanged != null) ...[
        _DateFilterChip(
          label: l10n.moderationDateFilterAll,
          selected: reviewedDateFilter == ModerationReviewedDateFilter.all,
          onSelected: () =>
              onReviewedDateFilterChanged!(ModerationReviewedDateFilter.all),
        ),
        _DateFilterChip(
          label: l10n.moderationDateFilter7Days,
          selected:
              reviewedDateFilter == ModerationReviewedDateFilter.last7Days,
          onSelected: () => onReviewedDateFilterChanged!(
            ModerationReviewedDateFilter.last7Days,
          ),
        ),
        _DateFilterChip(
          label: l10n.moderationDateFilter30Days,
          selected:
              reviewedDateFilter == ModerationReviewedDateFilter.last30Days,
          onSelected: () => onReviewedDateFilterChanged!(
            ModerationReviewedDateFilter.last30Days,
          ),
        ),
      ],
      if (statusFilter != null && onStatusFilterChanged != null) ...[
        _DateFilterChip(
          label: l10n.moderationStatusFilterAll,
          selected: statusFilter == ModerationHistoryStatusFilter.all,
          onSelected: () =>
              onStatusFilterChanged!(ModerationHistoryStatusFilter.all),
        ),
        _DateFilterChip(
          label: l10n.moderationStatusFilterApproved,
          selected: statusFilter == ModerationHistoryStatusFilter.approved,
          onSelected: () =>
              onStatusFilterChanged!(ModerationHistoryStatusFilter.approved),
        ),
        _DateFilterChip(
          label: l10n.moderationStatusFilterRejected,
          selected: statusFilter == ModerationHistoryStatusFilter.rejected,
          onSelected: () =>
              onStatusFilterChanged!(ModerationHistoryStatusFilter.rejected),
        ),
      ],
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final chips = _buildFilterChips(l10n);

    return DecoratedBox(
      decoration: BoxDecoration(color: scheme.surface),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          _moderationFilterHorizontalPadding,
          _moderationFilterTopPadding,
          _moderationFilterHorizontalPadding,
          0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: launchSearchController,
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: Spacing.md,
                        vertical: Spacing.sm,
                      ),
                      hintText: l10n.moderationLaunchSearchHint,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(28),
                        borderSide: BorderSide(color: scheme.outline),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(28),
                        borderSide: BorderSide(
                          color: scheme.primary,
                          width: 2,
                        ),
                      ),
                    ),
                    onChanged: onLaunchQueryChanged,
                  ),
                ),
                if (onBulkSelectToggle != null) ...[
                  const SizedBox(width: Spacing.xs),
                  TextButton(
                    onPressed: onBulkSelectToggle,
                    style: _moderationFilterTextButtonStyle(),
                    child: Text(
                      bulkSelectActive
                          ? l10n.moderationBulkSelectDone
                          : l10n.moderationBulkSelect,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: _moderationRowSpacing),
            SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: chips.length,
                separatorBuilder: (_, _) => const SizedBox(width: Spacing.xs),
                itemBuilder: (context, index) => chips[index],
              ),
            ),
            if (bulkSelectActive) ...[
              const SizedBox(height: _moderationRowSpacing),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: onSelectAll,
                    style: _moderationFilterTextButtonStyle(),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(l10n.moderationSelectAll),
                        const SizedBox(width: Spacing.xs),
                        const Icon(Icons.select_all, size: 16),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: canClearSelection ? onClearSelection : null,
                    style: _moderationFilterTextButtonStyle(),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(l10n.moderationClearSelection),
                        const SizedBox(width: Spacing.xs),
                        const Icon(Icons.close, size: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DateFilterChip extends StatelessWidget {
  const _DateFilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      visualDensity: VisualDensity.compact,
      showCheckmark: false,
      onSelected: (_) => onSelected(),
    );
  }
}

class _BulkActionBar extends StatelessWidget {
  const _BulkActionBar({
    required this.selectedCount,
    required this.onApprove,
    required this.onReject,
  });

  final int selectedCount;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Material(
      elevation: 4,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: _moderationFilterHorizontalPadding,
            vertical: Spacing.xs,
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onReject,
                  style: OutlinedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                  ),
                  child: Text(l10n.moderationBulkReject),
                ),
              ),
              const SizedBox(width: Spacing.sm),
              Expanded(
                child: FilledButton(
                  onPressed: onApprove,
                  style: FilledButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                  ),
                  child: Text(l10n.moderationBulkApprove),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
