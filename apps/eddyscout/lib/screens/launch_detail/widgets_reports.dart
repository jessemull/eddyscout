part of '../launch_detail_screen.dart';

class _LaunchReportsDigestCard extends ConsumerWidget {
  const _LaunchReportsDigestCard({required this.launchId});

  final String launchId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final digestState = ref.watch(launchReportsDigestProvider(launchId));
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.groups_outlined, color: scheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Community digest (AI)',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Paraphrases recent paddler notes below—not official conditions '
              'or river status.',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 12),
            if (digestState.isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (digestState.errorMessage != null) ...[
              Text(
                digestState.errorMessage!,
                style: TextStyle(color: scheme.error, fontSize: 13),
              ),
              TextButton.icon(
                onPressed: () => ref
                    .read(launchReportsDigestProvider(launchId).notifier)
                    .summarize(),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ] else if (digestState.result != null) ...[
              if (digestState.result!.noReports)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'No paddler reports to summarize yet.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    TextButton(
                      onPressed: () => ref
                          .read(launchReportsDigestProvider(launchId).notifier)
                          .summarize(),
                      child: const Text('Check again'),
                    ),
                  ],
                )
              else ...[
                Text(
                  digestState.result!.digestText,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                if (digestState.result!.cached) ...[
                  const SizedBox(height: 6),
                  Text(
                    'From cache (same reports; regenerate if someone just '
                    'posted).',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  'Read individual reports below—summaries can miss nuance.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                TextButton(
                  onPressed: () => ref
                      .read(launchReportsDigestProvider(launchId).notifier)
                      .summarize(forceRefresh: true),
                  child: const Text('Regenerate'),
                ),
              ],
            ] else
              FilledButton.tonalIcon(
                onPressed: () => ref
                    .read(launchReportsDigestProvider(launchId).notifier)
                    .summarize(),
                icon: const Icon(Icons.topic_outlined),
                label: const Text('Summarize recent reports'),
              ),
          ],
        ),
      ),
    );
  }
}

class _RecentConditionReports extends ConsumerWidget {
  const _RecentConditionReports({required this.launchId});

  final String launchId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportsAsync = ref.watch(conditionReportsListProvider(launchId));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Recent reports', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 4),
        Text(
          'Raw messages (newest first). Compare with the digest above.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        reportsAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
          error: (error, _) => Text(
            _recentReportsErrorMessage(error),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          data: (items) {
            if (items.isEmpty) {
              return Text(
                'No paddler reports yet.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < items.length; i++) ...[
                  if (i > 0) const SizedBox(height: 8),
                  _ConditionReportTile(report: items[i]),
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}

class _ConditionReportTile extends StatelessWidget {
  const _ConditionReportTile({required this.report});

  final ConditionReportListItem report;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final attribution = report.isMine ? 'You' : 'Anonymous paddler';
    final when = _formatConditionReportTime(context, report.createdAt);
    return Material(
      color: scheme.surfaceContainerHighest.withValues(alpha: 0.35),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  attribution,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  ' · $when',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(report.message, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

/// Bottom sheet content: owns `TextEditingController` until the route removes
/// this widget (avoids "used after being disposed" during IME teardown).
class _ConditionReportSheet extends ConsumerStatefulWidget {
  const _ConditionReportSheet({
    required this.launch,
    required this.conditionsFetchedAt,
    required this.scaffoldMessenger,
    required this.onSuccessFeedback,
  });

  final LaunchPoint launch;
  final DateTime conditionsFetchedAt;
  final ScaffoldMessengerState? scaffoldMessenger;
  final VoidCallback onSuccessFeedback;

  @override
  ConsumerState<_ConditionReportSheet> createState() =>
      _ConditionReportSheetState();
}

class _ConditionReportSheetState extends ConsumerState<_ConditionReportSheet> {
  late final TextEditingController _controller;

  /// After submit, the `TextField` is removed before `Navigator.pop`.
  /// Otherwise the IME / viewInsets teardown can rebuild `TextField` while the
  /// route disposal has already disposed `TextEditingController`.
  bool _submittedClosing = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      widget.scaffoldMessenger?.showSnackBar(
        const SnackBar(content: Text('Add a short message first.')),
      );
      return;
    }
    final fetchedAt = widget.conditionsFetchedAt.toUtc().toIso8601String();
    final submitArgs = (
      launchId: widget.launch.id,
      clientConditionsFetchedAt: fetchedAt,
    );
    final ok = await ref
        .read(conditionReportSubmitProvider(submitArgs).notifier)
        .submit(text);
    if (!mounted) {
      return;
    }
    if (!ok) {
      final err = ref.read(conditionReportSubmitProvider(submitArgs).notifier);
      widget.scaffoldMessenger?.showSnackBar(
        SnackBar(content: Text(err.errorMessage ?? 'Could not submit report.')),
      );
      return;
    }
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _submittedClosing = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      Navigator.pop(context);
      widget.onSuccessFeedback();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_submittedClosing) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Condition report',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _controller,
              maxLength: 800,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'What are you seeing on the water?',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton(onPressed: _submit, child: const Text('Submit')),
          ],
        ),
      ),
    );
  }
}
