import '../../database/app_database.dart';

/// Shortest interval between two entries that gets a gap row.
const Duration historyGapThreshold = Duration(minutes: 5);

/// The shortest span the day strip covers.
const Duration dayStripMinSpan = Duration(hours: 6);

/// The most hour labels under the day strip.
const int dayStripMaxTicks = 5;

/// One row of the History list: an entry or a gap between two entries.
sealed class HistoryItem {
  const HistoryItem();
}

final class HistoryEntryItem extends HistoryItem {
  const HistoryEntryItem(this.entry);

  final TimeEntry entry;
}

final class HistoryGapItem extends HistoryItem {
  const HistoryGapItem({required this.from, required this.to});

  /// The latest end of the entries before the gap.
  final DateTime from;

  /// The start of the entry after the gap.
  final DateTime to;

  Duration get length => to.difference(from);
}

/// The interval the day strip covers.
typedef DayStripRange = ({DateTime start, DateTime end});

/// [entries] newest first (latest start first, higher id first on a tie) with a
/// [HistoryGapItem] wherever the time between an entry and everything before it
/// is at least [historyGapThreshold]. The list never starts or ends with a gap.
///
/// Gaps come from the stored timestamps, so an entry across midnight works, and
/// an entry that overlaps another one never produces a gap.
List<HistoryItem> buildHistoryItems(List<TimeEntry> entries) {
  final oldestFirst = [...entries]
    ..sort((a, b) {
      final byStart = DateTime.parse(
        a.startTime,
      ).compareTo(DateTime.parse(b.startTime));
      return byStart != 0 ? byStart : a.id.compareTo(b.id);
    });

  final items = <HistoryItem>[];
  DateTime? latestEnd;
  for (final entry in oldestFirst) {
    final start = DateTime.parse(entry.startTime);
    final end = DateTime.parse(entry.endTime);
    if (latestEnd != null && start.difference(latestEnd) >= historyGapThreshold) {
      items.add(HistoryGapItem(from: latestEnd, to: start));
    }
    items.add(HistoryEntryItem(entry));
    if (latestEnd == null || end.isAfter(latestEnd)) latestEnd = end;
  }
  return items.reversed.toList();
}

/// The range of the day strip: whole hours, containing every entry and [now],
/// at least [dayStripMinSpan] long. [now] is given only when the day is today.
DayStripRange dayStripRange(List<TimeEntry> entries, {DateTime? now}) {
  assert(entries.isNotEmpty, 'the day strip needs at least one entry');
  var first = DateTime.parse(entries.first.startTime).toLocal();
  var last = DateTime.parse(entries.first.endTime).toLocal();
  for (final entry in entries) {
    final start = DateTime.parse(entry.startTime).toLocal();
    final end = DateTime.parse(entry.endTime).toLocal();
    if (start.isBefore(first)) first = start;
    if (end.isAfter(last)) last = end;
  }
  if (now != null) {
    final local = now.toLocal();
    if (local.isBefore(first)) first = local;
    if (local.isAfter(last)) last = local;
  }

  final start = DateTime(first.year, first.month, first.day, first.hour);
  final onTheHour = DateTime(last.year, last.month, last.day, last.hour);
  var end = onTheHour == last ? onTheHour : _plusHours(onTheHour, 1);
  while (end.difference(start) < dayStripMinSpan) {
    end = _plusHours(end, 1);
  }
  return (start: start, end: end);
}

/// The whole hours of [range] that get a label: a step of 1, 2, 3, 6, 12 or 24
/// hours, the smallest that gives at most [dayStripMaxTicks] labels.
List<DateTime> dayStripTicks(DayStripRange range) {
  final spanHours = (range.end.difference(range.start).inMinutes / 60).round();
  final step = const [
    1,
    2,
    3,
    6,
    12,
    24,
  ].firstWhere((s) => spanHours ~/ s + 1 <= dayStripMaxTicks, orElse: () => 24);
  return [
    for (var hours = 0; hours <= spanHours; hours += step)
      _plusHours(range.start, hours),
  ];
}

/// Adds whole hours on the wall clock, so a daylight saving change does not
/// move the result off the hour.
DateTime _plusHours(DateTime time, int hours) =>
    DateTime(time.year, time.month, time.day, time.hour + hours);
