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
        title: label,
        trailing: Text(
          strings.mission_sectionSummary(count, xp),
          style: context.bodyText.bodyMedium?.copyWith(
            fontSize: 14,
            color: context.palette.textDim,
          ),
        ),
      ),
    );
  }
}

/// Adds a quest to the current mission: the last row of the "Remaining" group.
class AddQuestRow extends StatelessWidget {
  const AddQuestRow({super.key, required this.onTap, this.first = false});

  final VoidCallback onTap;

  /// No quest row precedes it, so it draws the top edge of the group itself.
  final bool first;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final GroupEdges edges = (first: first, last: true);
    return Padding(
      padding: EdgeInsets.only(
        top: first ? Space.s20 : 0,
        bottom: Space.s10,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: p.card,
          borderRadius: groupedRadius(edges),
          border: groupedBorder(p.boardLine, edges),
        ),
        child: ClipRRect(
          borderRadius: groupedRadius(edges),
          child: AddRow(
            label: AppLocalizations.of(context).mission_addQuestToMission,
            onTap: onTap,
          ),
        ),
      ),
    );
  }
}
