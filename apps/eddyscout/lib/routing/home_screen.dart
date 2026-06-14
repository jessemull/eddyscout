import 'package:eddyscout/routing/app_routes.dart';
import 'package:eddyscout/routing/app_shell.dart';
import 'package:eddyscout_design_system/eddyscout_design_system.dart';
import 'package:eddyscout_localization/eddyscout_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Placeholder home tab until discovery content ships.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.homePlaceholderTitle)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(Spacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                l10n.homePlaceholderBody,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: Spacing.lg),
              FilledButton(
                onPressed: () {
                  const MapRoute().go(context);
                  StatefulNavigationShell.maybeOf(context)?.goBranch(
                    AppShellBranches.map,
                  );
                },
                child: Text(l10n.homeExploreMapButton),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
