import 'package:eddyscout_localization/eddyscout_localization.dart';
import 'package:eddyscout_map/eddyscout_map.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Bottom navigation shell indices for [StatefulNavigationShell.goBranch].
abstract final class AppShellBranches {
  static const home = 0;
  static const map = 1;
  static const savedRoutes = 2;
  static const menu = 3;
}

/// Bottom navigation shell for home, map, saved routes, and menu tabs.
class AppShell extends ConsumerWidget {
  /// Creates the shell wrapping [navigationShell].
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: navigationShell.currentIndex == AppShellBranches.map
          ? Colors.transparent
          : null,
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          navigationShell.goBranch(index);
          if (index == AppShellBranches.map) {
            ref.read(mapTabResumedProvider.notifier).notifyResumed();
          }
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: l10n.shellTabHome,
          ),
          NavigationDestination(
            icon: const Icon(Icons.map_outlined),
            selectedIcon: const Icon(Icons.map),
            label: l10n.shellTabMap,
          ),
          NavigationDestination(
            icon: const Icon(Icons.bookmark_border),
            selectedIcon: const Icon(Icons.bookmark),
            label: l10n.shellTabSavedRoutes,
          ),
          NavigationDestination(
            icon: const Icon(Icons.menu),
            selectedIcon: const Icon(Icons.menu),
            label: l10n.shellTabMenu,
          ),
        ],
      ),
    );
  }
}
