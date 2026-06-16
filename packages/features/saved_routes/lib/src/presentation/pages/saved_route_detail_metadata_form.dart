import 'package:eddyscout_core/eddyscout_core.dart';
import 'package:eddyscout_design_system/eddyscout_design_system.dart';
import 'package:eddyscout_localization/eddyscout_localization.dart';
import 'package:eddyscout_saved_routes/src/presentation/pages/saved_route_detail_labels.dart';
import 'package:flutter/material.dart';

/// Name, notes, duration, difficulty, and skill fields for route detail.
class SavedRouteDetailMetadataForm extends StatelessWidget {
  /// Creates the metadata form section.
  const SavedRouteDetailMetadataForm({
    required this.nameController,
    required this.descriptionController,
    required this.notesController,
    required this.durationController,
    required this.difficulty,
    required this.skillLevel,
    required this.units,
    required this.onFieldChanged,
    required this.onDifficultyChanged,
    required this.onSkillChanged,
    super.key,
  });

  /// Route name input.
  final TextEditingController nameController;

  /// Optional route description input.
  final TextEditingController descriptionController;

  /// Free-form notes input.
  final TextEditingController notesController;

  /// Estimated duration in minutes.
  final TextEditingController durationController;

  /// Selected difficulty, if any.
  final RouteDifficulty? difficulty;

  /// Selected recommended skill level, if any.
  final RecommendedSkillLevel? skillLevel;

  /// User display unit preference for helper text.
  final DisplayUnitSystem units;

  /// Called when any text field changes.
  final VoidCallback onFieldChanged;

  /// Called when difficulty selection changes.
  final ValueChanged<RouteDifficulty?> onDifficultyChanged;

  /// Called when skill level selection changes.
  final ValueChanged<RecommendedSkillLevel?> onSkillChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: nameController,
          decoration: InputDecoration(
            labelText: l10n.savedRoutesNameLabel,
          ),
          onChanged: (_) => onFieldChanged(),
        ),
        const SizedBox(height: Spacing.sm),
        TextField(
          controller: descriptionController,
          decoration: InputDecoration(
            labelText: l10n.savedRoutesDescriptionLabel,
          ),
          onChanged: (_) => onFieldChanged(),
        ),
        const SizedBox(height: Spacing.sm),
        TextField(
          controller: notesController,
          decoration: InputDecoration(
            labelText: l10n.savedRoutesNotesLabel,
          ),
          maxLines: 3,
          onChanged: (_) => onFieldChanged(),
        ),
        const SizedBox(height: Spacing.sm),
        TextField(
          controller: durationController,
          decoration: InputDecoration(
            labelText: l10n.savedRoutesDurationLabel,
            helperText: switch (units) {
              DisplayUnitSystem.metric => l10n.savedRoutesDurationHintMetric,
              DisplayUnitSystem.imperial =>
                l10n.savedRoutesDurationHintImperial,
            },
          ),
          keyboardType: TextInputType.number,
          onChanged: (_) => onFieldChanged(),
        ),
        const SizedBox(height: Spacing.md),
        DropdownButtonFormField<RouteDifficulty?>(
          initialValue: difficulty,
          decoration: InputDecoration(
            labelText: l10n.savedRoutesDifficultyLabel,
          ),
          items: [
            DropdownMenuItem(child: Text(l10n.savedRoutesDifficultyNone)),
            ...RouteDifficulty.values.map(
              (d) => DropdownMenuItem(
                value: d,
                child: Text(savedRouteDifficultyLabel(l10n, d)),
              ),
            ),
          ],
          onChanged: onDifficultyChanged,
        ),
        const SizedBox(height: Spacing.sm),
        DropdownButtonFormField<RecommendedSkillLevel?>(
          initialValue: skillLevel,
          decoration: InputDecoration(
            labelText: l10n.savedRoutesSkillLabel,
          ),
          items: [
            DropdownMenuItem(child: Text(l10n.savedRoutesSkillNone)),
            ...RecommendedSkillLevel.values.map(
              (s) => DropdownMenuItem(
                value: s,
                child: Text(savedRouteSkillLabel(l10n, s)),
              ),
            ),
          ],
          onChanged: onSkillChanged,
        ),
      ],
    );
  }
}
