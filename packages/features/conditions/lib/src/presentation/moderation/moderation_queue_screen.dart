import 'package:eddyscout_conditions/src/domain/condition_report_models.dart';
import 'package:eddyscout_conditions/src/presentation/moderation/pending_reports_provider.dart';
import 'package:eddyscout_design_system/eddyscout_design_system.dart';
import 'package:eddyscout_localization/eddyscout_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Moderator review queue for held condition reports.
class ModerationQueueScreen extends ConsumerWidget {
  /// Creates the moderation queue screen.
  const ModerationQueueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final pendingAsync = ref.watch(moderationPendingReportsProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.moderationQueueTitle)),
      body: pendingAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(Spacing.md),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.moderationQueueLoadError,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
                const SizedBox(height: Spacing.sm),
                FilledButton.tonal(
                  onPressed: () => ref
                      .read(moderationPendingReportsProvider.notifier)
                      .refresh(),
                  child: Text(l10n.retryButton),
                ),
              ],
            ),
          ),
        ),
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(Spacing.lg),
                child: Text(
                  l10n.moderationQueueEmpty,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(Spacing.md),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(height: Spacing.sm),
            itemBuilder: (context, index) {
              final report = items[index];
              return _PendingReportCard(report: report);
            },
          );
        },
      ),
    );
  }
}

class _PendingReportCard extends ConsumerStatefulWidget {
  const _PendingReportCard({required this.report});

  final ModerationQueueReport report;

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
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final report = widget.report;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              report.launchId,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: scheme.primary,
              ),
            ),
            const SizedBox(height: Spacing.xs),
            Text(
              MaterialLocalizations.of(
                context,
              ).formatShortDate(report.createdAt),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
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
