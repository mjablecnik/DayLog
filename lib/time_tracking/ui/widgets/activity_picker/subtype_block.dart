import 'package:flutter/material.dart';

import '../../../../theme/app_theme.dart';
import '../../../../theme/tokens.dart';
import '../../../../ui_kit/common/app_segmented.dart';
import '../../../../ui_kit/controls/choice_chip.dart';

import '../../../domain/activity_types.dart';
import '../../../theme/time_theme.dart';
import '../../../../l10n/app_localizations.dart';

/// The framed block that holds the subtype chips of the selected main type.
///
/// It is drawn in the colour of the main type and has its own heading and hint,
/// so the choice cannot be overlooked next to the main type chips above it.
class SubtypeBlock extends StatelessWidget {
  final AppThemeData theme;
  final ActivityType type;
  final String? selectedKey;
  final ValueChanged<String> onSelected;

  const SubtypeBlock({
    super.key,
    required this.theme,
    required this.type,
    required this.selectedKey,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = theme.isDark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Space.s12),
      decoration: BoxDecoration(
        color: context.palette.tone,
        borderRadius: BorderRadius.circular(Radii.button),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.time_pickerSubtypeHeading(
                    activityTypeLabel(l10n, type.key),
                  ),
                  style: context.bodyText.labelLarge,
                ),
              ),
              const SizedBox(width: Space.s8),
              Text(
                l10n.time_pickerSubtypeHint,
                style: context.bodyText.bodySmall?.copyWith(
                  color: context.palette.textDim,
                ),
              ),
            ],
          ),
          const SizedBox(height: Space.s8),
          if (type.subtypes.length <= 3)
            AppSegmented<String?>(
              options: [
                for (final subtype in type.subtypes)
                  SegmentedOption(
                    value: subtype.key,
                    label: subtypeLabel(l10n, type.key, subtype.key),
                  ),
              ],
              selected: selectedKey,
              onChanged: (key) {
                if (key != null) onSelected(key);
              },
            )
          else
            Wrap(
              spacing: Space.s8,
              runSpacing: Space.s8,
              children: [
                for (final subtype in type.subtypes)
                  ChoiceChipX(
                    key: ValueKey('subtype-chip-${subtype.key}'),
                    label: subtypeLabel(l10n, type.key, subtype.key),
                    color: isDark ? subtype.dark : subtype.light,
                    selected: subtype.key == selectedKey,
                    onSelected: (_) => onSelected(subtype.key),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
