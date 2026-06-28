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

part 'moderation_queue_filter_bar.dart';
part 'moderation_queue_report_cards.dart';

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
