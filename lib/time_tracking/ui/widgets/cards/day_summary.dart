import 'package:flutter/material.dart';

import '../../../domain/date_format_utils.dart';
import '../../../theme/time_theme.dart';
import '../../../../database/app_database.dart';
import '../../../../l10n/app_localizations.dart';

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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Text(
            l10n.time_historyEntryCount(count),
            style: TextStyle(
              color: theme.dim,
              fontSize: 13,
            ),
          ),
          const SizedBox(width: 16),
          Text(
            l10n.time_historyTotalLabel(formatDuration(l10n, _totalTime())),
            style: TextStyle(
              color: theme.dim,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
