import '../../l10n/app_localizations.dart';

/// Formats [duration] as a compact "Xh Ym" / "Xh" / "Ym" label.
String formatDuration(AppLocalizations l10n, Duration duration) {
  final totalMinutes = duration.inMinutes;
  if (totalMinutes < 60) return l10n.time_durationMinutesOnly(totalMinutes);
  final hours = totalMinutes ~/ 60;
  final mins = totalMinutes % 60;
  return mins > 0
      ? l10n.time_durationHoursMinutes(hours, mins)
      : l10n.time_durationHoursOnly(hours);
}

/// Short weekday labels (Monday..Sunday) in the current locale, matching
/// `DateTime.weekday`'s 1=Monday..7=Sunday convention (index 0 = Monday).
List<String> weekdayShortLabels(AppLocalizations l10n) => [
      l10n.time_weekdayMon,
      l10n.time_weekdayTue,
      l10n.time_weekdayWed,
      l10n.time_weekdayThu,
      l10n.time_weekdayFri,
      l10n.time_weekdaySat,
      l10n.time_weekdaySun,
    ];
