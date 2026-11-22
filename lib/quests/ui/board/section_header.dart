import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import '../../../theme/tokens.dart';
import '../../../ui_kit/layout/section_headers.dart';

/// Small upper-case label row above a list section, with a figure on the
/// right ("+110 XP", "2 quests · 35 XP").
class BoardSectionHeader extends StatelessWidget {
  const BoardSectionHeader({
    super.key,
    required this.label,
    required this.figure,
    this.count,
    this.figureColor,
  });

  /// Already localized section name.
  final String label;

  /// Already localized summary shown at the right.
  final String figure;
  final int? count;

  /// Defaults to the faint text colour; the open section uses brass.
  final Color? figureColor;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Space.s20,
        Space.s8,
        Space.s20,
        Space.s10,
      ),
      child: CountHeader(
        title: label,
        count: count,
        trailing: DecoratedBox(
          decoration: BoxDecoration(
            color: p.brassSoft,
            borderRadius: BorderRadius.circular(Radii.pill),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Space.s8,
              vertical: Space.s4,
            ),
            child: Text(
              figure,
              style: context.bodyText.labelLarge?.copyWith(
                color: figureColor ?? p.brassText,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
