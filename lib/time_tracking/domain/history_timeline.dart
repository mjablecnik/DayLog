import '../../database/app_database.dart';

/// Shortest interval between two entries that gets a gap row.
const Duration historyGapThreshold = Duration(minutes: 5);

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
