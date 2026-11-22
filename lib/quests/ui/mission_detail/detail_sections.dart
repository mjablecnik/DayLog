import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/tokens.dart';
import '../../../ui_kit/layout/grouped_list.dart';
import '../../../ui_kit/layout/section_headers.dart';

/// Caps section label on the left and "N quests · M XP" on the right.
class DetailSectionHead extends StatelessWidget {
  const DetailSectionHead({
    super.key,
    required this.label,
    required this.count,
    required this.xp,
  });

  final String label;
  final int count;
  final int xp;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: Space.s24, bottom: Space.s12),
      child: CountHeader(
        title: label.toUpperCase(),
        trailing: Text(
          strings.mission_sectionSummary(count, xp).toUpperCase(),
          style: context.bodyText.labelSmall?.copyWith(
            color: context.palette.textDim,
          ),
        ),
      ),
    );
  }
}

/// Adds a quest to the current mission.
class AddQuestRow extends StatelessWidget {
  const AddQuestRow({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GroupedList(
    children: [
      AddRow(
        label: AppLocalizations.of(context).mission_addQuestToMission,
        onTap: onTap,
      ),
    ],
  );
}
