import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_design_system/eddyscout_design_system.dart';
import 'package:eddyscout_localization/eddyscout_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'map_compact_search_result_row.dart';
import 'map_search_provider.dart';

/// Always-visible browse search field — focus does not change the layout.
class MapBrowseSearchField extends ConsumerStatefulWidget {
  const MapBrowseSearchField({super.key});

  @override
  ConsumerState<MapBrowseSearchField> createState() =>
      _MapBrowseSearchFieldState();
}

class _MapBrowseSearchFieldState extends ConsumerState<MapBrowseSearchField> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: ref.read(mapSearchQueryProvider));
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    ref.read(mapSearchContextStateProvider.notifier).setBrowse();
    ref.read(mapSearchQueryProvider.notifier).changeQuery(value);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(mapSearchQueryProvider, (previous, next) {
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

    return Material(
      type: MaterialType.transparency,
      child: DecoratedBox(
        key: const Key('map_browse_search_field'),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHigh.withValues(alpha: 0.94),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: scheme.shadow.withValues(alpha: 0.18),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.md,
            vertical: Spacing.sm + 2,
          ),
          child: Row(
            children: [
              Icon(Icons.search, color: scheme.onSurfaceVariant),
              const SizedBox(width: Spacing.sm),
              Expanded(
                child: Theme(
                  data: Theme.of(context).copyWith(
                    inputDecorationTheme: InputDecorationTheme(
                      filled: false,
                      fillColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      focusedErrorBorder: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      isDense: true,
                      isCollapsed: true,
                      hintStyle: Theme.of(context).textTheme.bodyLarge
                          ?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                  ),
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    decoration: InputDecoration(
                      hintText: l10n.mapSearchPlaceholder,
                    ),
                    style: Theme.of(context).textTheme.bodyLarge,
                    onChanged: _onQueryChanged,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Compact search bar for add-stop flows — map stays visible until results.
class MapCompactSearchBar extends ConsumerStatefulWidget {
  const MapCompactSearchBar({super.key});

  @override
  ConsumerState<MapCompactSearchBar> createState() =>
      _MapCompactSearchBarState();
}

class _MapCompactSearchBarState extends ConsumerState<MapCompactSearchBar> {
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

  void _close() {
    ref.read(mapSearchQueryProvider.notifier).clear();
    ref.read(mapSearchExpandedProvider.notifier).collapse();
  }

  void _onQueryChanged(String value) {
    ref.read(mapSearchQueryProvider.notifier).changeQuery(value);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;

    return Material(
      key: const Key('map_compact_search_bar'),
      elevation: 6,
      color: scheme.surfaceContainerHigh.withValues(alpha: 0.96),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.all(Spacing.sm),
          child: Row(
            children: [
              IconButton(
                tooltip: l10n.cancelButton,
                onPressed: _close,
                icon: const Icon(Icons.arrow_back),
              ),
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  decoration: InputDecoration(
                    hintText: l10n.mapSearchPlaceholder,
                    border: InputBorder.none,
                    isDense: true,
                  ),
                  onChanged: _onQueryChanged,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Full-screen search results — covers the map while the query is non-empty.
class MapFullScreenSearchOverlay extends ConsumerStatefulWidget {
  const MapFullScreenSearchOverlay({
    required this.onLaunchSelected,
    super.key,
  });

  final ValueChanged<LaunchPoint> onLaunchSelected;

  @override
  ConsumerState<MapFullScreenSearchOverlay> createState() =>
      _MapFullScreenSearchOverlayState();
}

class _MapFullScreenSearchOverlayState
    extends ConsumerState<MapFullScreenSearchOverlay> {
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

  void _close() {
    ref.read(mapSearchQueryProvider.notifier).clear();
    ref.read(mapSearchExpandedProvider.notifier).collapse();
  }

  void _selectLaunch(LaunchPoint launch) {
    widget.onLaunchSelected(launch);
    _close();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final query = ref.watch(mapSearchQueryProvider);

    return Material(
      key: const Key('map_fullscreen_search_overlay'),
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
                    onPressed: _close,
                    icon: const Icon(Icons.arrow_back),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      decoration: InputDecoration(
                        hintText: l10n.mapSearchPlaceholder,
                        border: InputBorder.none,
                        isDense: true,
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
              child: _SearchResultsList(
                query: query,
                onLaunchSelected: _selectLaunch,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchResultsList extends ConsumerWidget {
  const _SearchResultsList({
    required this.query,
    required this.onLaunchSelected,
  });

  final String query;
  final ValueChanged<LaunchPoint> onLaunchSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final launchHits = ref.watch(mapSearchLaunchHitsProvider);
    final placeHitsAsync = ref.watch(mapSearchPlaceHitsProvider(query));

    return ListView(
      children: [
        if (launchHits.isNotEmpty) ...[
          MapSearchSectionHeader(title: l10n.mapSearchLaunchesSection),
          for (final hit in launchHits)
            MapCompactSearchResultRow(
              title: hit.result.launch.name,
              subtitle: hit.result.launch.shortNote,
              icon: Icons.place_outlined,
              iconColor: mapSearchLaunchIconColor(
                context,
                hit.result.launch.riverSystem,
              ),
              onTap: () => onLaunchSelected(hit.result.launch),
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
                MapSearchSectionHeader(title: l10n.mapSearchPlacesSection),
                for (final hit in placeHits)
                  MapCompactSearchResultRow(
                    title: hit.result.name,
                    subtitle: hit.result.subtitle,
                    icon: Icons.place_outlined,
                    iconColor: mapSearchPlaceIconColor(context),
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
    );
  }
}
