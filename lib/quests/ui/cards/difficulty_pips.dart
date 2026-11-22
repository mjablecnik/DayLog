import 'package:flutter/material.dart';

import '../../domain/xp_rules.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui_kit/controls/effort_pips.dart';

/// Number of filled pips for [difficulty]: its effort step, one to four.
int pipCount(Difficulty difficulty) => switch (difficulty) {
  Difficulty.easy => 1,
  Difficulty.normal => 2,
  Difficulty.hard => 3,
  Difficulty.fullDay => 4,
};

/// Four bars, of which one to four are filled brass. Effort is never
/// colour coded and never named: the semantic label gives the step only.
class DifficultyPips extends StatelessWidget {
  const DifficultyPips(this.difficulty, {super.key, this.emptyColor});

  final Difficulty difficulty;

  /// Colour of the unfilled pips; defaults to the faint text of a Quest card.
  final Color? emptyColor;

  static const int total = 4;

  @override
  Widget build(BuildContext context) {
    final int filled = pipCount(difficulty);
    final AppLocalizations l = AppLocalizations.of(context);

    return Semantics(
      label: l.a11y_effort(filled, total),
      excludeSemantics: true,
      child: EffortPips(filled: filled),
    );
  }
}
