import 'package:flutter/material.dart';

import '../../../domain/date_format_utils.dart';
import '../../../theme/time_theme.dart';
import '../../../../database/app_database.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../theme/app_theme.dart';
import '../../../../theme/tokens.dart';

class DaySummary extends StatelessWidget {
  final List<TimeEntry> entries;
  final AppThemeData theme;

  const DaySummary({super.key, required this.entries, required this.theme});

  Duration _totalTime() {
    int totalMinutes = 0;
    for (final entry in entries) {
      final start = DateTime.parse(entry.startTime);
      final end = DateTime.parse(entry.endTime);
      totalMinutes += end.difference(start).inMinutes;
    }
    return Duration(minutes: totalMinutes);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final count = entries.length;
    final palette = context.palette;
    final style = context.bodyText.bodySmall?.copyWith(
      fontSize: 13,
      fontWeight: const FontWeight(750),
    );
    Widget pill(String label, Color fill, Color color) => DecoratedBox(
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(Radii.pill),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Space.s12,
          vertical: Space.s6,
        ),
        child: Text(label, style: style?.copyWith(color: color)),
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Space.s16,
        vertical: Space.s8,
      ),
      child: Wrap(
        spacing: Space.s8,
        runSpacing: Space.s6,
        children: [
          pill(
            l10n.time_historyEntryCount(count),
            palette.tone,
            palette.text,
          ),
          pill(
            l10n.time_historyTotalLabel(formatDuration(l10n, _totalTime())),
            palette.brassSoft,
            palette.brassText,
          ),
        ],
      ),
    );
  }
}
