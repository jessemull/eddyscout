import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_design_system/eddyscout_design_system.dart';
import 'package:eddyscout_localization/eddyscout_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'nearby_trips_search_provider.dart';
import 'trips_from_here_l10n.dart';

/// Full-screen nearby trips search (shared by map overlay and pushed routes).
class NearbyTripsSearchView extends ConsumerStatefulWidget {
  /// Creates search UI for [originLaunch].
  const NearbyTripsSearchView({
    required this.originLaunch,
    required this.onLaunchSelected,
    required this.onClose,
    super.key,
  });

  final LaunchPoint originLaunch;
  final ValueChanged<LaunchPoint> onLaunchSelected;
  final VoidCallback onClose;

  @override
  ConsumerState<NearbyTripsSearchView> createState() =>
      _NearbyTripsSearchViewState();
}

class _NearbyTripsSearchViewState extends ConsumerState<NearbyTripsSearchView> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: ref.read(nearbyTripsSearchQueryProvider),
    );
    _focusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  String _maxDistanceLabel(AppLocalizations l10n, int miles) {
    return switch (miles) {
      5 => l10n.tripsFromHereBand5Mi,
      10 => l10n.tripsFromHereBand10Mi,
      _ => l10n.tripsFromHereBand20Mi,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final maxMi = ref.watch(nearbyTripsMaxDistanceMiProvider);
    final resultsAsync = ref.watch(
      filteredNearbyTripsProvider(widget.originLaunch.id),
    );

    return Material(
      key: const Key('nearby_trips_search_view'),
      color: scheme.surface,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(Spacing.sm),
              child: Row(
                children: [
                  IconButton(
                    tooltip: l10n.cancelButton,
                    onPressed: widget.onClose,
                    icon: const Icon(Icons.arrow_back),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      decoration: InputDecoration(
                        hintText: l10n.tripsFromHereSuggestedSearchPlaceholder,
                        border: InputBorder.none,
                        isDense: true,
                      ),
                      onChanged: (value) {
                        ref
                            .read(nearbyTripsSearchQueryProvider.notifier)
                            .changeQuery(value);
                      },
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Spacing.md,
                0,
                Spacing.md,
                Spacing.sm,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.tripsFromHereMaxDistanceLabel,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: Spacing.xs),
                  SegmentedButton<int>(
                    segments: [
                      for (final miles in kNearbyTripsMaxDistanceOptionsMi)
                        ButtonSegment(
                          value: miles,
                          label: Text(_maxDistanceLabel(l10n, miles)),
                        ),
                    ],
                    selected: {maxMi},
                    onSelectionChanged: (next) {
                      ref
                          .read(nearbyTripsMaxDistanceMiProvider.notifier)
                          .setMiles(next.single);
                    },
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: resultsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, _) => Padding(
                  padding: const EdgeInsets.all(Spacing.lg),
                  child: Text(
                    l10n.tripsFromHereLoadError,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: scheme.error,
                    ),
                  ),
                ),
                data: (launches) {
                  if (launches.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(Spacing.lg),
                      child: Text(
                        l10n.tripsFromHereNoNearbyLaunches,
                        textAlign: TextAlign.center,
                      ),
                    );
                  }
                  return ListView(
                    children: [
                      for (final launch in launches)
                        ListTile(
                          leading: const Icon(Icons.place_outlined),
                          title: Text(launch.name),
                          subtitle: Text(
                            mapLaunchRiverLabel(l10n, launch.riverSystem),
                          ),
                          onTap: () => widget.onLaunchSelected(launch),
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
