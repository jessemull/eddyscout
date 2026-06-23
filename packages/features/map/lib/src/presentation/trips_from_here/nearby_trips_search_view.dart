import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_design_system/eddyscout_design_system.dart';
import 'package:eddyscout_localization/eddyscout_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../map_compact_search_result_row.dart';
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
      5 => l10n.tripsFromHereMaxDistance5Miles,
      10 => l10n.tripsFromHereMaxDistance10Miles,
      _ => l10n.tripsFromHereMaxDistance20Miles,
    };
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(nearbyTripsSearchQueryProvider, (previous, next) {
      if (_controller.text == next) {
        return;
      }
      _controller.value = TextEditingValue(
        text: next,
        selection: TextSelection.collapsed(offset: next.length),
      );
    });

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
              child: DropdownButtonFormField<int>(
                initialValue: maxMi,
                decoration: InputDecoration(
                  labelText: l10n.tripsFromHereMaxDistanceLabel,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: Spacing.sm,
                    vertical: Spacing.xs,
                  ),
                ),
                items: [
                  for (final miles in kNearbyTripsMaxDistanceOptionsMi)
                    DropdownMenuItem(
                      value: miles,
                      child: Text(_maxDistanceLabel(l10n, miles)),
                    ),
                ],
                onChanged: (miles) {
                  if (miles == null) {
                    return;
                  }
                  ref
                      .read(nearbyTripsMaxDistanceMiProvider.notifier)
                      .setMiles(miles);
                },
              ),
            ),
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
                      MapSearchSectionHeader(
                        title: l10n.mapSearchLaunchesSection,
                      ),
                      for (final launch in launches)
                        MapCompactSearchResultRow(
                          title: launch.name,
                          subtitle: mapLaunchRiverLabel(
                            l10n,
                            launch.riverSystem,
                          ),
                          icon: Icons.place_outlined,
                          iconColor: mapSearchLaunchIconColor(
                            context,
                            launch.riverSystem,
                          ),
                          semanticsLabel: l10n
                              .tripsFromHerePlanToLaunchSemantics(
                                launch.name,
                                mapLaunchRiverLabel(
                                  l10n,
                                  launch.riverSystem,
                                ),
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
