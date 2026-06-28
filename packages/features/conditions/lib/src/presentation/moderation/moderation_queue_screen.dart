import 'package:eddyscout_conditions/src/domain/condition_report_models.dart';
import 'package:eddyscout_conditions/src/presentation/moderation/moderation_display_helpers.dart';
import 'package:eddyscout_conditions/src/presentation/moderation/moderation_history_provider.dart';
import 'package:eddyscout_conditions/src/presentation/moderation/moderation_queue_filters_provider.dart';
import 'package:eddyscout_conditions/src/presentation/moderation/moderation_selection_provider.dart';
import 'package:eddyscout_conditions/src/presentation/moderation/pending_reports_provider.dart';
import 'package:eddyscout_design_system/eddyscout_design_system.dart';
import 'package:eddyscout_localization/eddyscout_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Moderator workspace for pending reports and audit history.
class ModerationQueueScreen extends ConsumerStatefulWidget {
  /// Creates the moderation queue screen.
  const ModerationQueueScreen({super.key});

  @override
  ConsumerState<ModerationQueueScreen> createState() =>
      _ModerationQueueScreenState();
}

class _ModerationQueueScreenState extends ConsumerState<ModerationQueueScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final TextEditingController _launchSearchController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _launchSearchController = TextEditingController();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _launchSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.moderationQueueTitle),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: l10n.moderationTabPending),
            Tab(text: l10n.moderationTabHistory),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _PendingTab(launchSearchController: _launchSearchController),
          _HistoryTab(launchSearchController: _launchSearchController),
        ],
      ),
    );
  }
}

class _PendingTab extends ConsumerStatefulWidget {
  const _PendingTab({required this.launchSearchController});

  final TextEditingController launchSearchController;

  @override
  ConsumerState<_PendingTab> createState() => _PendingTabState();
}

class _PendingTabState extends ConsumerState<_PendingTab> {
  var _bulkSelectActive = false;

  void _setBulkSelectActive(bool active) {
    if (!active) {
      ref.read(moderationSelectionProvider.notifier).clear();
    }
    setState(() => _bulkSelectActive = active);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final pendingAsync = ref.watch(moderationPendingReportsProvider);
    final selection = ref.watch(moderationSelectionProvider);
    final filters = ref.watch(moderationPendingFiltersProvider);
    final visibleSelectedCount = pendingAsync.maybeWhen(
      data: (items) => selection
          .where((id) => items.any((report) => report.id == id))
          .length,
      orElse: () => 0,
    );
    final effectiveSelection = pendingAsync.maybeWhen(
      data: (items) {
        final visibleIds = items.map((e) => e.id).toSet();
        return selection.where(visibleIds.contains).toSet();
      },
      orElse: () => <String>{},
    );

    return Column(
      children: [
        _ModerationFilterBar(
          launchSearchController: widget.launchSearchController,
          launchQuery: filters.launchQuery,
          onLaunchQueryChanged: ref
              .read(moderationPendingFiltersProvider.notifier)
              .setLaunchQuery,
          pendingSort: filters.sort,
          onPendingSortChanged: ref
              .read(moderationPendingFiltersProvider.notifier)
              .setSort,
          submittedDateFilter: filters.submittedDateFilter,
          onSubmittedDateFilterChanged: ref
              .read(moderationPendingFiltersProvider.notifier)
              .setSubmittedDateFilter,
          bulkSelectActive: _bulkSelectActive,
          onBulkSelectToggle: () => _setBulkSelectActive(!_bulkSelectActive),
          onSelectAll: pendingAsync.maybeWhen(
            data: (items) => () {
              ref
                  .read(moderationSelectionProvider.notifier)
                  .selectAll(items.map((e) => e.id));
            },
            orElse: () => null,
          ),
          onClearSelection: () =>
              ref.read(moderationSelectionProvider.notifier).clear(),
          canClearSelection: visibleSelectedCount > 0,
        ),
        Expanded(
          child: pendingAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => _ModerationErrorBody(
              message: l10n.moderationQueueLoadError,
              onRetry: () =>
                  ref.read(moderationPendingReportsProvider.notifier).refresh(),
            ),
            data: (items) {
              if (items.isEmpty) {
                return RefreshIndicator(
                  onRefresh: () => ref
                      .read(moderationPendingReportsProvider.notifier)
                      .refresh(),
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(
                        height: MediaQuery.sizeOf(context).height * 0.4,
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(Spacing.lg),
                            child: Text(
                              l10n.moderationQueueEmpty,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return RefreshIndicator(
                onRefresh: () => ref
                    .read(moderationPendingReportsProvider.notifier)
                    .refresh(),
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                    _moderationCardHorizontalGutter,
                    _moderationCardHorizontalGutter,
                    _moderationCardHorizontalGutter,
                    Spacing.xs,
                  ),
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: items.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: Spacing.xs),
                  itemBuilder: (context, index) {
                    final report = items[index];
                    return _PendingReportCard(
                      key: ValueKey(report.id),
                      report: report,
                      bulkSelectActive: _bulkSelectActive,
                      selected: effectiveSelection.contains(report.id),
                      onSelectedChanged: (selected) {
                        ref
                            .read(moderationSelectionProvider.notifier)
                            .toggle(report.id);
                      },
                    );
                  },
                ),
              );
            },
          ),
        ),
        if (_bulkSelectActive && effectiveSelection.isNotEmpty)
          _BulkActionBar(
            selectedCount: effectiveSelection.length,
            onApprove: () => _confirmBulkModerate(
              context: context,
              ref: ref,
              approve: true,
              reportIds: effectiveSelection.toList(growable: false),
              onComplete: () => _setBulkSelectActive(false),
            ),
            onReject: () => _confirmBulkModerate(
              context: context,
              ref: ref,
              approve: false,
              reportIds: effectiveSelection.toList(growable: false),
              onComplete: () => _setBulkSelectActive(false),
            ),
          ),
      ],
    );
  }
}

class _HistoryTab extends ConsumerWidget {
  const _HistoryTab({required this.launchSearchController});

  final TextEditingController launchSearchController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final historyAsync = ref.watch(moderationHistoryProvider);
    final filters = ref.watch(moderationHistoryFiltersProvider);

    return Column(
      children: [
        _ModerationFilterBar(
          launchSearchController: launchSearchController,
          launchQuery: filters.launchQuery,
          onLaunchQueryChanged: ref
              .read(moderationHistoryFiltersProvider.notifier)
              .setLaunchQuery,
          historySort: filters.sort,
          onHistorySortChanged: ref
              .read(moderationHistoryFiltersProvider.notifier)
              .setSort,
          reviewedDateFilter: filters.reviewedDateFilter,
          onReviewedDateFilterChanged: ref
              .read(moderationHistoryFiltersProvider.notifier)
              .setReviewedDateFilter,
          statusFilter: filters.status,
          onStatusFilterChanged: ref
              .read(moderationHistoryFiltersProvider.notifier)
              .setStatus,
        ),
        Expanded(
          child: historyAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => _ModerationErrorBody(
              message: l10n.moderationHistoryLoadError,
              onRetry: () =>
                  ref.read(moderationHistoryProvider.notifier).refresh(),
            ),
            data: (items) {
              if (items.isEmpty) {
                return RefreshIndicator(
                  onRefresh: () =>
                      ref.read(moderationHistoryProvider.notifier).refresh(),
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(
                        height: MediaQuery.sizeOf(context).height * 0.4,
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(Spacing.lg),
                            child: Text(
                              l10n.moderationHistoryEmpty,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return RefreshIndicator(
                onRefresh: () =>
                    ref.read(moderationHistoryProvider.notifier).refresh(),
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                    _moderationCardHorizontalGutter,
                    _moderationCardHorizontalGutter,
                    _moderationCardHorizontalGutter,
                    Spacing.xs,
                  ),
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: items.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: Spacing.xs),
                  itemBuilder: (context, index) {
                    return _HistoryReportCard(
                      key: ValueKey(items[index].id),
                      report: items[index],
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

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

class _ModerationErrorBody extends StatelessWidget {
  const _ModerationErrorBody({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            const SizedBox(height: Spacing.sm),
            FilledButton.tonal(
              onPressed: onRetry,
              child: Text(l10n.retryButton),
            ),
          ],
        ),
      ),
    );
  }
}

class _PendingReportCard extends ConsumerStatefulWidget {
  const _PendingReportCard({
    required this.report,
    required this.bulkSelectActive,
    required this.selected,
    required this.onSelectedChanged,
    super.key,
  });

  final ModerationQueueReport report;
  final bool bulkSelectActive;
  final bool selected;
  final ValueChanged<bool> onSelectedChanged;

  @override
  ConsumerState<_PendingReportCard> createState() => _PendingReportCardState();
}

class _PendingReportCardState extends ConsumerState<_PendingReportCard> {
  var _busy = false;

  Future<void> _moderate({required bool approve}) async {
    if (_busy) {
      return;
    }
    setState(() => _busy = true);
    final ok = await ref
        .read(moderationPendingReportsProvider.notifier)
        .moderate(reportId: widget.report.id, approve: approve);
    if (!mounted) {
      return;
    }
    setState(() => _busy = false);
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.moderationActionError)),
      );
    } else if (widget.selected) {
      ref.read(moderationSelectionProvider.notifier).toggle(widget.report.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final report = widget.report;
    final launchName = resolveLaunchDisplayName(report.launchId);
    final submittedAt = report.createdAt.toLocal();
    final submittedTime = MaterialLocalizations.of(
      context,
    ).formatTimeOfDay(TimeOfDay.fromDateTime(submittedAt));
    final submittedLabel =
        '${MaterialLocalizations.of(context).formatShortDate(submittedAt)} · '
        '$submittedTime';

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(Spacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.bulkSelectActive) ...[
              Transform.translate(
                offset: const Offset(0, -2),
                child: Checkbox(
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                  value: widget.selected,
                  onChanged: _busy
                      ? null
                      : (value) => widget.onSelectedChanged(value ?? false),
                ),
              ),
              const SizedBox(width: Spacing.xs),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_busy)
                    const Padding(
                      padding: EdgeInsets.only(bottom: Spacing.xs),
                      child: LinearProgressIndicator(),
                    ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          launchName,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ),
                      if (report.holdAgeDays != null)
                        Text(
                          l10n.moderationWaitingDays(report.holdAgeDays!),
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                    ],
                  ),
                  Text(
                    submittedLabel,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: Spacing.sm),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _ModerationSubmitterField(
                          label: l10n.moderationSubmitterUid,
                          uid: report.submitterUid,
                        ),
                      ),
                      if (report.moderationReason != null) ...[
                        const SizedBox(width: Spacing.sm),
                        Expanded(
                          child: _ModerationLabeledText(
                            label: l10n.moderationHoldReason,
                            value: formatModerationReason(
                              l10n,
                              report.moderationReason!,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: Spacing.sm),
                  _ModerationMessageField(
                    label: l10n.moderationMessage,
                    message: report.message,
                  ),
                  if (!widget.bulkSelectActive) ...[
                    const SizedBox(height: Spacing.sm),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: _busy
                              ? null
                              : () => _moderate(approve: false),
                          style: TextButton.styleFrom(
                            visualDensity: VisualDensity.compact,
                            padding: const EdgeInsets.symmetric(
                              horizontal: Spacing.sm,
                            ),
                          ),
                          child: Text(l10n.moderationReject),
                        ),
                        FilledButton.tonal(
                          onPressed: _busy
                              ? null
                              : () => _moderate(approve: true),
                          style: FilledButton.styleFrom(
                            visualDensity: VisualDensity.compact,
                            padding: const EdgeInsets.symmetric(
                              horizontal: Spacing.md,
                            ),
                          ),
                          child: Text(l10n.moderationApprove),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryReportCard extends ConsumerStatefulWidget {
  const _HistoryReportCard({required this.report, super.key});

  final ModerationHistoryReport report;

  @override
  ConsumerState<_HistoryReportCard> createState() => _HistoryReportCardState();
}

class _HistoryReportCardState extends ConsumerState<_HistoryReportCard> {
  var _busy = false;

  Future<void> _confirmReopen() async {
    if (_busy) {
      return;
    }
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.moderationReturnToPendingConfirmTitle),
          content: Text(l10n.moderationReturnToPendingConfirmBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.cancelButton),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.moderationReturnToPending),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !mounted) {
      return;
    }

    setState(() => _busy = true);
    final ok = await ref
        .read(moderationHistoryProvider.notifier)
        .reopen(reportId: widget.report.id);
    if (!mounted) {
      return;
    }
    setState(() => _busy = false);
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.moderationActionError)),
      );
      return;
    }
    ref.invalidate(moderationPendingReportsProvider);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final report = widget.report;
    final launchName = resolveLaunchDisplayName(report.launchId);
    final statusLabel = switch (report.moderationStatus) {
      ConditionReportModerationStatus.approved =>
        l10n.moderationStatusFilterApproved,
      ConditionReportModerationStatus.rejected =>
        l10n.moderationStatusFilterRejected,
      ConditionReportModerationStatus.held => report.moderationStatus.name,
    };
    final reviewedAt = report.reviewedAt.toLocal();
    final reviewedTime = MaterialLocalizations.of(
      context,
    ).formatTimeOfDay(TimeOfDay.fromDateTime(reviewedAt));
    final reviewedLabel =
        '${MaterialLocalizations.of(context).formatShortDate(reviewedAt)} · '
        '$reviewedTime';

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(Spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_busy)
              const Padding(
                padding: EdgeInsets.only(bottom: Spacing.xs),
                child: LinearProgressIndicator(),
              ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    launchName,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                Text(
                  statusLabel,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            Text(
              '${l10n.moderationReviewedAt}: $reviewedLabel',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: Spacing.sm),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _ModerationSubmitterField(
                    label: l10n.moderationSubmitterUid,
                    uid: report.submitterUid,
                  ),
                ),
                const SizedBox(width: Spacing.sm),
                Expanded(
                  child: report.reviewedBy != null
                      ? _ModerationSubmitterField(
                          label: l10n.moderationModeratorUid,
                          uid: report.reviewedBy!,
                        )
                      : _ModerationLabeledText(
                          label: l10n.moderationModeratorUid,
                          value: l10n.moderationSystemActor,
                        ),
                ),
              ],
            ),
            if (report.moderationReason != null) ...[
              const SizedBox(height: Spacing.sm),
              _ModerationLabeledText(
                label: l10n.moderationHoldReason,
                value: formatModerationReason(l10n, report.moderationReason!),
              ),
            ],
            const SizedBox(height: Spacing.sm),
            _ModerationMessageField(
              label: l10n.moderationMessage,
              message: report.message,
            ),
            const SizedBox(height: Spacing.sm),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _busy ? null : _confirmReopen,
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: Spacing.sm),
                ),
                child: Text(l10n.moderationReturnToPending),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

TextStyle? _moderationFieldLabelStyle(BuildContext context) {
  return Theme.of(context).textTheme.labelMedium?.copyWith(
    fontWeight: FontWeight.bold,
  );
}

TextStyle? _moderationFieldValueStyle(BuildContext context) {
  return Theme.of(context).textTheme.bodySmall?.copyWith(
    color: Theme.of(context).colorScheme.onSurfaceVariant,
    fontWeight: FontWeight.normal,
  );
}

class _ModerationLabeledText extends StatelessWidget {
  const _ModerationLabeledText({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: _moderationFieldLabelStyle(context)),
        const SizedBox(height: Spacing.xxs),
        Text(value, style: _moderationFieldValueStyle(context)),
      ],
    );
  }
}

class _ModerationSubmitterField extends StatelessWidget {
  const _ModerationSubmitterField({
    required this.label,
    required this.uid,
  });

  final String label;
  final String uid;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: _moderationFieldLabelStyle(context)),
        const SizedBox(height: Spacing.xxs),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                truncateUid(uid),
                style: _moderationFieldValueStyle(context),
              ),
            ),
            const SizedBox(width: Spacing.sm),
            InkWell(
              onTap: () async {
                await Clipboard.setData(ClipboardData(text: uid));
                if (!context.mounted) {
                  return;
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.moderationUidCopied)),
                );
              },
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding: const EdgeInsets.all(Spacing.xxs),
                child: Icon(
                  Icons.copy,
                  size: 14,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ModerationMessageField extends StatelessWidget {
  const _ModerationMessageField({
    required this.label,
    required this.message,
  });

  final String label;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: _moderationFieldLabelStyle(context)),
        const SizedBox(height: Spacing.xxs),
        Text(message, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}

Future<void> _confirmBulkModerate({
  required BuildContext context,
  required WidgetRef ref,
  required bool approve,
  required List<String> reportIds,
  VoidCallback? onComplete,
}) async {
  final l10n = context.l10n;
  final needsConfirm = !approve || reportIds.length > 1;
  if (needsConfirm) {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            approve
                ? l10n.moderationBulkApproveConfirmTitle
                : l10n.moderationBulkRejectConfirmTitle,
          ),
          content: Text(
            approve
                ? l10n.moderationBulkApproveConfirmBody
                : l10n.moderationBulkRejectConfirmBody,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.cancelButton),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                approve ? l10n.moderationApprove : l10n.moderationReject,
              ),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !context.mounted) {
      return;
    }
  }

  final result = await ref
      .read(moderationPendingReportsProvider.notifier)
      .moderateBatch(reportIds: reportIds, approve: approve);
  if (!context.mounted) {
    return;
  }
  ref.read(moderationSelectionProvider.notifier).clear();
  onComplete?.call();
  if (result == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.moderationActionError)),
    );
    return;
  }
  if (result.failed.isNotEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.moderationBatchPartialFailure(result.failed.length)),
      ),
    );
  }
}
