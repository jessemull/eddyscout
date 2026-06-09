import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_design_system/eddyscout_design_system.dart';
import 'package:eddyscout_localization/eddyscout_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'map_search_provider.dart';

/// Full-screen search overlay for launches and (future) places.
class MapSearchOverlay extends ConsumerStatefulWidget {
  const MapSearchOverlay({
    required this.onLaunchSelected,
    super.key,
  });

  final ValueChanged<LaunchPoint> onLaunchSelected;

  @override
  ConsumerState<MapSearchOverlay> createState() => _MapSearchOverlayState();
}

class _MapSearchOverlayState extends ConsumerState<MapSearchOverlay> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: ref.read(mapSearchQueryProvider));
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

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final launchHits = ref.watch(mapSearchLaunchHitsProvider);
    final query = ref.watch(mapSearchQueryProvider);
    final placeHitsAsync = ref.watch(mapSearchPlaceHitsProvider(query));

    return Material(
      color: Theme.of(context).colorScheme.surface,
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
                    onPressed: () {
                      ref.read(mapSearchOverlayVisibleProvider.notifier).hide();
                    },
                    icon: const Icon(Icons.arrow_back),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      decoration: InputDecoration(
                        hintText: l10n.mapSearchPlaceholder,
                        border: InputBorder.none,
                      ),
                      onChanged: (value) {
                        ref
                            .read(mapSearchQueryProvider.notifier)
                            .changeQuery(value);
                      },
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: query.trim().isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(Spacing.lg),
                        child: Text(
                          l10n.mapSearchPlaceholder,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    )
                  : ListView(
                      children: [
                        if (launchHits.isNotEmpty) ...[
                          _SectionHeader(title: l10n.mapSearchLaunchesSection),
                          for (final hit in launchHits)
                            _LaunchResultTile(
                              launch: hit.result.launch,
                              onTap: () {
                                widget.onLaunchSelected(hit.result.launch);
                                ref
                                    .read(
                                      mapSearchOverlayVisibleProvider.notifier,
                                    )
                                    .hide();
                              },
                            ),
                        ],
                        placeHitsAsync.when(
                          loading: () => const SizedBox.shrink(),
                          error: (_, _) => const SizedBox.shrink(),
                          data: (placeHits) {
                            if (placeHits.isEmpty) {
                              return const SizedBox.shrink();
                            }
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _SectionHeader(
                                  title: l10n.mapSearchPlacesSection,
                                ),
                                for (final hit in placeHits)
                                  ListTile(
                                    leading: const Icon(Icons.place_outlined),
                                    title: Text(hit.result.name),
                                    subtitle: Text(hit.result.subtitle),
                                  ),
                              ],
                            );
                          },
                        ),
                        if (launchHits.isEmpty &&
                            placeHitsAsync.maybeWhen(
                              data: (places) => places.isEmpty,
                              orElse: () => false,
                            ))
                          Padding(
                            padding: const EdgeInsets.all(Spacing.lg),
                            child: Text(
                              l10n.mapSearchNoResults,
                              textAlign: TextAlign.center,
                            ),
                          ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(
      Spacing.md,
      Spacing.sm,
      Spacing.md,
      Spacing.xs,
    ),
    child: Text(
      title,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
        color: Theme.of(context).colorScheme.primary,
      ),
    ),
  );
}

class _LaunchResultTile extends StatelessWidget {
  const _LaunchResultTile({
    required this.launch,
    required this.onTap,
  });

  final LaunchPoint launch;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ListTile(
    leading: const Icon(Icons.place_outlined),
    title: Text(launch.name),
    subtitle: Text(launch.shortNote),
    onTap: onTap,
  );
}
