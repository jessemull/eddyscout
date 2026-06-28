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

class _PendingTab extends ConsumerWidget {
  const _PendingTab({required this.launchSearchController});

  final TextEditingController launchSearchController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          launchSearchController: launchSearchController,
          launchQuery: filters.launchQuery,
          onLaunchQueryChanged: ref
              .read(moderationPendingFiltersProvider.notifier)
              .setLaunchQuery,
          sortLabel: filters.sort == ModerationQueueSort.createdAtAsc
              ? l10n.moderationSortOldestWaiting
              : l10n.moderationSortMostRecent,
          onSortToggle: () {
            ref
                .read(moderationPendingFiltersProvider.notifier)
                .setSort(
                  filters.sort == ModerationQueueSort.createdAtAsc
                      ? ModerationQueueSort.createdAtDesc
                      : ModerationQueueSort.createdAtAsc,
                );
          },
          submittedDateFilter: filters.submittedDateFilter,
          onSubmittedDateFilterChanged: ref
              .read(moderationPendingFiltersProvider.notifier)
              .setSubmittedDateFilter,
          selectionActions: pendingAsync.maybeWhen(
            data: (items) => _SelectionAppBarActions(
              visibleIds: items.map((e) => e.id),
              selectedCount: visibleSelectedCount,
            ),
            orElse: () => const SizedBox.shrink(),
          ),
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
                  padding: const EdgeInsets.all(Spacing.md),
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: items.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: Spacing.sm),
                  itemBuilder: (context, index) {
                    final report = items[index];
                    return _PendingReportCard(
                      key: ValueKey(report.id),
                      report: report,
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
        if (effectiveSelection.isNotEmpty)
          _BulkActionBar(
            selectedCount: effectiveSelection.length,
            onApprove: () => _confirmBulkModerate(
              context: context,
              ref: ref,
              approve: true,
              reportIds: effectiveSelection.toList(growable: false),
            ),
            onReject: () => _confirmBulkModerate(
              context: context,
              ref: ref,
              approve: false,
              reportIds: effectiveSelection.toList(growable: false),
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
          sortLabel: filters.sort == ModerationHistorySort.reviewedAtDesc
              ? l10n.moderationSortRecentAction
              : l10n.moderationSortOldestAction,
          onSortToggle: () {
            ref
                .read(moderationHistoryFiltersProvider.notifier)
                .setSort(
                  filters.sort == ModerationHistorySort.reviewedAtDesc
                      ? ModerationHistorySort.reviewedAtAsc
                      : ModerationHistorySort.reviewedAtDesc,
                );
          },
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
                  padding: const EdgeInsets.all(Spacing.md),
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: items.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: Spacing.sm),
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

class _ModerationFilterBar extends StatelessWidget {
  const _ModerationFilterBar({
    required this.launchSearchController,
    required this.launchQuery,
    required this.onLaunchQueryChanged,
    required this.sortLabel,
    required this.onSortToggle,
    this.submittedDateFilter,
    this.onSubmittedDateFilterChanged,
    this.reviewedDateFilter,
    this.onReviewedDateFilterChanged,
    this.statusFilter,
    this.onStatusFilterChanged,
    this.selectionActions = const SizedBox.shrink(),
  });

  final TextEditingController launchSearchController;
  final String launchQuery;
  final ValueChanged<String> onLaunchQueryChanged;
  final String sortLabel;
  final VoidCallback onSortToggle;
  final ModerationSubmittedDateFilter? submittedDateFilter;
  final ValueChanged<ModerationSubmittedDateFilter>?
  onSubmittedDateFilterChanged;
  final ModerationReviewedDateFilter? reviewedDateFilter;
  final ValueChanged<ModerationReviewedDateFilter>? onReviewedDateFilterChanged;
  final ModerationHistoryStatusFilter? statusFilter;
  final ValueChanged<ModerationHistoryStatusFilter>? onStatusFilterChanged;
  final Widget selectionActions;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Material(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(Spacing.sm),
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
                      hintText: l10n.moderationLaunchSearchHint,
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: onLaunchQueryChanged,
                  ),
                ),
                const SizedBox(width: Spacing.sm),
                selectionActions,
              ],
            ),
            const SizedBox(height: Spacing.sm),
            Wrap(
              spacing: Spacing.xs,
              runSpacing: Spacing.xs,
              children: [
                ActionChip(
                  label: Text(sortLabel),
                  onPressed: onSortToggle,
                ),
                if (submittedDateFilter != null &&
                    onSubmittedDateFilterChanged != null) ...[
                  _DateFilterChip(
                    label: l10n.moderationDateFilterAll,
                    selected:
                        submittedDateFilter ==
                        ModerationSubmittedDateFilter.all,
                    onSelected: () => onSubmittedDateFilterChanged!(
                      ModerationSubmittedDateFilter.all,
                    ),
                  ),
                  _DateFilterChip(
                    label: l10n.moderationDateFilter7Days,
                    selected:
                        submittedDateFilter ==
                        ModerationSubmittedDateFilter.last7Days,
                    onSelected: () => onSubmittedDateFilterChanged!(
                      ModerationSubmittedDateFilter.last7Days,
                    ),
                  ),
                  _DateFilterChip(
                    label: l10n.moderationDateFilter30Days,
                    selected:
                        submittedDateFilter ==
                        ModerationSubmittedDateFilter.last30Days,
                    onSelected: () => onSubmittedDateFilterChanged!(
                      ModerationSubmittedDateFilter.last30Days,
                    ),
                  ),
                ],
                if (reviewedDateFilter != null &&
                    onReviewedDateFilterChanged != null) ...[
                  _DateFilterChip(
                    label: l10n.moderationDateFilterAll,
                    selected:
                        reviewedDateFilter == ModerationReviewedDateFilter.all,
                    onSelected: () => onReviewedDateFilterChanged!(
                      ModerationReviewedDateFilter.all,
                    ),
                  ),
                  _DateFilterChip(
                    label: l10n.moderationDateFilter7Days,
                    selected:
                        reviewedDateFilter ==
                        ModerationReviewedDateFilter.last7Days,
                    onSelected: () => onReviewedDateFilterChanged!(
                      ModerationReviewedDateFilter.last7Days,
                    ),
                  ),
                  _DateFilterChip(
                    label: l10n.moderationDateFilter30Days,
                    selected:
                        reviewedDateFilter ==
                        ModerationReviewedDateFilter.last30Days,
                    onSelected: () => onReviewedDateFilterChanged!(
                      ModerationReviewedDateFilter.last30Days,
                    ),
                  ),
                ],
                if (statusFilter != null && onStatusFilterChanged != null) ...[
                  _DateFilterChip(
                    label: l10n.moderationStatusFilterAll,
                    selected: statusFilter == ModerationHistoryStatusFilter.all,
                    onSelected: () => onStatusFilterChanged!(
                      ModerationHistoryStatusFilter.all,
                    ),
                  ),
                  _DateFilterChip(
                    label: l10n.moderationStatusFilterApproved,
                    selected:
                        statusFilter == ModerationHistoryStatusFilter.approved,
                    onSelected: () => onStatusFilterChanged!(
                      ModerationHistoryStatusFilter.approved,
                    ),
                  ),
                  _DateFilterChip(
                    label: l10n.moderationStatusFilterRejected,
                    selected:
                        statusFilter == ModerationHistoryStatusFilter.rejected,
                    onSelected: () => onStatusFilterChanged!(
                      ModerationHistoryStatusFilter.rejected,
                    ),
                  ),
                ],
              ],
            ),
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
      onSelected: (_) => onSelected(),
    );
  }
}

class _SelectionAppBarActions extends ConsumerWidget {
  const _SelectionAppBarActions({
    required this.visibleIds,
    required this.selectedCount,
  });

  final Iterable<String> visibleIds;
  final int selectedCount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextButton(
          onPressed: () => ref
              .read(moderationSelectionProvider.notifier)
              .selectAll(visibleIds),
          child: Text(l10n.moderationSelectAll),
        ),
        TextButton(
          onPressed: selectedCount == 0
              ? null
              : () => ref.read(moderationSelectionProvider.notifier).clear(),
          child: Text(l10n.moderationClearSelection),
        ),
      ],
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
      elevation: 8,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(Spacing.sm),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onReject,
                  child: Text(l10n.moderationBulkReject),
                ),
              ),
              const SizedBox(width: Spacing.sm),
              Expanded(
                child: FilledButton(
                  onPressed: onApprove,
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
    required this.selected,
    required this.onSelectedChanged,
    super.key,
  });

  final ModerationQueueReport report;
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
    } else {
      ref.read(moderationSelectionProvider.notifier).toggle(widget.report.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final report = widget.report;
    final launchName = resolveLaunchDisplayName(report.launchId);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_busy) ...[
              const LinearProgressIndicator(),
              const SizedBox(height: Spacing.sm),
            ],
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: widget.selected,
                  onChanged: _busy
                      ? null
                      : (value) => widget.onSelectedChanged(value ?? false),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        launchName,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      Text(
                        report.launchId,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (report.holdAgeDays != null)
                  Chip(
                    label: Text(
                      l10n.moderationWaitingDays(report.holdAgeDays!),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: Spacing.sm),
            _MetadataRow(
              label: l10n.moderationSubmittedAt,
              value: MaterialLocalizations.of(
                context,
              ).formatFullDate(report.createdAt.toLocal()),
              secondaryValue:
                  MaterialLocalizations.of(
                    context,
                  ).formatTimeOfDay(
                    TimeOfDay.fromDateTime(report.createdAt.toLocal()),
                  ),
            ),
            _UidRow(
              label: l10n.moderationSubmitterUid,
              uid: report.submitterUid,
            ),
            if (report.moderationReason != null)
              _MetadataRow(
                label: l10n.moderationHoldReason,
                value: report.moderationReason!,
              ),
            const SizedBox(height: Spacing.sm),
            Text(report.message, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: Spacing.md),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _busy ? null : () => _moderate(approve: false),
                    child: Text(l10n.moderationReject),
                  ),
                ),
                const SizedBox(width: Spacing.sm),
                Expanded(
                  child: FilledButton(
                    onPressed: _busy ? null : () => _moderate(approve: true),
                    child: Text(l10n.moderationApprove),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryReportCard extends StatelessWidget {
  const _HistoryReportCard({required this.report, super.key});

  final ModerationHistoryReport report;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final launchName = resolveLaunchDisplayName(report.launchId);
    final statusLabel = switch (report.moderationStatus) {
      ConditionReportModerationStatus.approved =>
        l10n.moderationStatusFilterApproved,
      ConditionReportModerationStatus.rejected =>
        l10n.moderationStatusFilterRejected,
      ConditionReportModerationStatus.held => report.moderationStatus.name,
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        launchName,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      Text(
                        report.launchId,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Chip(label: Text(statusLabel)),
              ],
            ),
            const SizedBox(height: Spacing.sm),
            _MetadataRow(
              label: l10n.moderationSubmittedAt,
              value: MaterialLocalizations.of(
                context,
              ).formatFullDate(report.createdAt.toLocal()),
            ),
            _MetadataRow(
              label: l10n.moderationReviewedAt,
              value: MaterialLocalizations.of(
                context,
              ).formatFullDate(report.reviewedAt.toLocal()),
              secondaryValue:
                  MaterialLocalizations.of(
                    context,
                  ).formatTimeOfDay(
                    TimeOfDay.fromDateTime(report.reviewedAt.toLocal()),
                  ),
            ),
            _UidRow(
              label: l10n.moderationSubmitterUid,
              uid: report.submitterUid,
            ),
            if (report.reviewedBy != null)
              _UidRow(
                label: l10n.moderationModeratorUid,
                uid: report.reviewedBy!,
              )
            else
              _MetadataRow(
                label: l10n.moderationModeratorUid,
                value: l10n.moderationSystemActor,
              ),
            if (report.moderationReason != null)
              _MetadataRow(
                label: l10n.moderationHoldReason,
                value: report.moderationReason!,
              ),
            const SizedBox(height: Spacing.sm),
            Text(report.message, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

class _MetadataRow extends StatelessWidget {
  const _MetadataRow({
    required this.label,
    required this.value,
    this.secondaryValue,
  });

  final String label;
  final String value;
  final String? secondaryValue;

  @override
  Widget build(BuildContext context) {
    final text = secondaryValue == null ? value : '$value · $secondaryValue';
    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.xxs),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '$label: ',
              style: Theme.of(context).textTheme.labelMedium,
            ),
            TextSpan(
              text: text,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _UidRow extends StatelessWidget {
  const _UidRow({required this.label, required this.uid});

  final String label;
  final String uid;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.xxs),
      child: Row(
        children: [
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '$label: ',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  TextSpan(
                    text: truncateUid(uid),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            tooltip: l10n.moderationCopyUid,
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: uid));
              if (!context.mounted) {
                return;
              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.moderationUidCopied)),
              );
            },
            icon: const Icon(Icons.copy, size: 18),
          ),
        ],
      ),
    );
  }
}

Future<void> _confirmBulkModerate({
  required BuildContext context,
  required WidgetRef ref,
  required bool approve,
  required List<String> reportIds,
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
