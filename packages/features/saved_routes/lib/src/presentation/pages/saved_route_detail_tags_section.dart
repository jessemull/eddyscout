import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_design_system/eddyscout_design_system.dart';
import 'package:eddyscout_localization/eddyscout_localization.dart';
import 'package:eddyscout_saved_routes/src/presentation/pages/saved_route_detail_labels.dart';
import 'package:flutter/material.dart';

/// Category chips and custom tags for route detail.
class SavedRouteDetailTagsSection extends StatelessWidget {
  /// Creates the categories and tags section.
  const SavedRouteDetailTagsSection({
    required this.selectedCategories,
    required this.customTags,
    required this.customTagController,
    required this.onCategorySelected,
    required this.onCustomTagDeleted,
    required this.onAddCustomTag,
    super.key,
  });

  /// Enum categories currently selected for the route.
  final Set<RouteCategory> selectedCategories;

  /// User-defined tag strings.
  final List<String> customTags;

  /// Controller for the add-custom-tag field.
  final TextEditingController customTagController;

  /// Called when an enum category chip is toggled.
  final void Function(RouteCategory category, {required bool selected})
  onCategorySelected;

  /// Called when a custom tag chip is deleted.
  final ValueChanged<String> onCustomTagDeleted;

  /// Called when the user adds a custom tag.
  final VoidCallback onAddCustomTag;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.savedRoutesCategoriesLabel,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: Spacing.sm),
        Wrap(
          spacing: Spacing.sm,
          runSpacing: Spacing.sm,
          children: RouteCategory.values.map((category) {
            final selected = selectedCategories.contains(category);
            return FilterChip(
              label: Text(savedRouteCategoryLabel(l10n, category)),
              selected: selected,
              onSelected: (value) =>
                  onCategorySelected(category, selected: value),
            );
          }).toList(),
        ),
        const SizedBox(height: Spacing.md),
        Text(
          l10n.savedRoutesCustomTagsLabel,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: Spacing.sm),
        if (customTags.isNotEmpty)
          Wrap(
            spacing: Spacing.sm,
            runSpacing: Spacing.sm,
            children: customTags.map((tag) {
              return InputChip(
                label: Text(tag),
                onDeleted: () => onCustomTagDeleted(tag),
              );
            }).toList(),
          ),
        if (customTags.isNotEmpty) const SizedBox(height: Spacing.sm),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextField(
                key: const Key('saved_route_custom_tag_field'),
                controller: customTagController,
                decoration: InputDecoration(
                  labelText: l10n.savedRoutesCustomTagHint,
                ),
                onSubmitted: (_) => onAddCustomTag(),
              ),
            ),
            IconButton(
              tooltip: l10n.savedRoutesCustomTagAdd,
              icon: const Icon(Icons.add),
              onPressed: onAddCustomTag,
            ),
          ],
        ),
      ],
    );
  }
}
