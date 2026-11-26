import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import 'package:daylog/database/app_database.dart';
import 'package:daylog/time_tracking/domain/history_timeline.dart';

// Feature: history-timeline
//
// glados cannot be added (analyzer conflict, see .agents/MEMORY.md), so the
// properties use a seeded random loop with 100+ iterations.
TimeEntry entry(int id, DateTime start, DateTime end) => TimeEntry(
  id: id,
  startTime: start.toIso8601String(),
  endTime: end.toIso8601String(),
  description: 'entry $id',
  activityType: 'Práce',
  createdAt: DateTime(2026),
);

DateTime at(int hour, int minute, {int day = 26}) =>
    DateTime(2026, 11, day, hour, minute);

List<TimeEntry> entriesOf(List<HistoryItem> items) => [
  for (final item in items)
    if (item is HistoryEntryItem) item.entry,
];

List<HistoryGapItem> gapsOf(List<HistoryItem> items) => [
  for (final item in items)
    if (item is HistoryGapItem) item,
];

void main() {
  group('buildHistoryItems', () {
    test('returns nothing for an empty day', () {
      expect(buildHistoryItems(const []), isEmpty);
    });

    test('lists the latest start first, the higher id first on a tie', () {
      final morning = entry(1, at(8, 0), at(9, 0));
      final noonA = entry(2, at(12, 0), at(12, 30));
      final noonB = entry(3, at(12, 0), at(12, 30));
      final items = buildHistoryItems([morning, noonA, noonB]);
      expect(entriesOf(items).map((e) => e.id), [3, 2, 1]);
    });

    test('puts a gap row between two entries that are a pause apart', () {
      final items = buildHistoryItems([
        entry(1, at(8, 10), at(9, 55)),
        entry(2, at(10, 21), at(10, 41)),
      ]);
      expect(items, hasLength(3));
      expect(items[0], isA<HistoryEntryItem>());
      final gap = items[1] as HistoryGapItem;
      expect(gap.from, at(9, 55));
      expect(gap.to, at(10, 21));
      expect(gap.length, const Duration(minutes: 26));
      expect(items[2], isA<HistoryEntryItem>());
    });

    test('has no gap row below the threshold and one at and above it', () {
      for (final (minutes, expected) in [(0, 0), (1, 0), (4, 0), (5, 1), (6, 1)]) {
        final items = buildHistoryItems([
          entry(1, at(8, 0), at(9, 0)),
          entry(2, at(9, minutes), at(10, 0)),
        ]);
        expect(gapsOf(items), hasLength(expected), reason: '$minutes min apart');
      }
    });

    test('has no gap row for overlapping entries', () {
      final items = buildHistoryItems([
        entry(1, at(8, 0), at(10, 0)),
        entry(2, at(9, 0), at(11, 0)),
      ]);
      expect(gapsOf(items), isEmpty);
    });

    test('measures the gap from the latest end of everything before it', () {
      // The long entry covers the short one, so the gap starts at 12:00, not 10:00.
      final items = buildHistoryItems([
        entry(1, at(8, 0), at(12, 0)),
        entry(2, at(9, 0), at(10, 0)),
        entry(3, at(13, 0), at(14, 0)),
      ]);
      final gaps = gapsOf(items);
      expect(gaps, hasLength(1));
      expect(gaps.single.from, at(12, 0));
      expect(gaps.single.length, const Duration(hours: 1));
    });

    test('never starts or ends with a gap row', () {
      final items = buildHistoryItems([
        entry(1, at(8, 0), at(9, 0)),
        entry(2, at(15, 0), at(16, 0)),
      ]);
      expect(items.first, isA<HistoryEntryItem>());
      expect(items.last, isA<HistoryEntryItem>());
    });

    test('finds a gap across midnight from the timestamps', () {
      final items = buildHistoryItems([
        entry(1, at(22, 0), at(23, 50)),
        entry(2, at(0, 10, day: 27), at(1, 0, day: 27)),
      ]);
      final gap = gapsOf(items).single;
      expect(gap.length, const Duration(minutes: 20));
      expect(entriesOf(items).first.id, 2);
    });

    test('keeps every entry exactly once and orders it (random days)', () {
      final random = Random(7);
      for (var run = 0; run < 150; run++) {
        final entries = <TimeEntry>[];
        final count = random.nextInt(12) + 1;
        for (var id = 1; id <= count; id++) {
          final start = at(8, 0).add(Duration(minutes: random.nextInt(600)));
          entries.add(
            entry(id, start, start.add(Duration(minutes: random.nextInt(120)))),
          );
        }
        final items = buildHistoryItems(entries);
        final listed = entriesOf(items);
        expect(listed.map((e) => e.id).toSet(), entries.map((e) => e.id).toSet());
        expect(listed, hasLength(entries.length));
        for (var i = 1; i < listed.length; i++) {
          final before = DateTime.parse(listed[i - 1].startTime);
          final after = DateTime.parse(listed[i].startTime);
          expect(
            before.isAfter(after) ||
                (before == after && listed[i - 1].id > listed[i].id),
            isTrue,
          );
        }
        expect(items.isEmpty || items.first is HistoryEntryItem, isTrue);
        expect(items.isEmpty || items.last is HistoryEntryItem, isTrue);
        for (var i = 0; i < items.length; i++) {
          if (items[i] case HistoryGapItem(:final length)) {
            expect(items[i - 1], isA<HistoryEntryItem>());
            expect(items[i + 1], isA<HistoryEntryItem>());
            expect(length >= historyGapThreshold, isTrue);
          }
        }
      }
    });
  });

  group('dayStripRange', () {
    test('rounds out to whole hours around the entries', () {
      final range = dayStripRange([
        entry(1, at(8, 10), at(9, 55)),
        entry(2, at(17, 30), at(18, 45)),
      ]);
      expect(range.start, at(8, 0));
      expect(range.end, at(19, 0));
    });

    test('keeps an end that is already on the hour', () {
      final range = dayStripRange([entry(1, at(8, 0), at(15, 0))]);
      expect(range.end, at(15, 0));
    });

    test('spans at least six hours', () {
      final range = dayStripRange([entry(1, at(10, 15), at(10, 40))]);
      expect(range.start, at(10, 0));
      expect(range.end.difference(range.start), const Duration(hours: 6));
    });

    test('extends to the hour after now when the day is today', () {
      final entries = [entry(1, at(8, 0), at(9, 0))];
      expect(dayStripRange(entries, now: at(16, 20)).end, at(17, 0));
      expect(dayStripRange(entries, now: at(8, 30)).end, at(14, 0));
    });

    test('runs past midnight for an entry across midnight', () {
      final range = dayStripRange([
        entry(1, at(22, 0), at(23, 0)),
        entry(2, at(23, 30), at(1, 20, day: 27)),
      ]);
      expect(range.start, at(22, 0));
      // 22:00 to 02:00 is only four hours, so the strip widens to six.
      expect(range.end, at(4, 0, day: 27));
    });

    test('contains every entry and now, on whole hours (random days)', () {
      final random = Random(11);
      for (var run = 0; run < 150; run++) {
        final entries = <TimeEntry>[];
        final count = random.nextInt(8) + 1;
        for (var id = 1; id <= count; id++) {
          final start = at(3, 0).add(Duration(minutes: random.nextInt(1200)));
          entries.add(
            entry(id, start, start.add(Duration(minutes: random.nextInt(300)))),
          );
        }
        final now = random.nextBool()
            ? at(3, 0).add(Duration(minutes: random.nextInt(1380)))
            : null;
        final range = dayStripRange(entries, now: now);
        expect(range.start.minute + range.start.second, 0);
        expect(range.end.minute + range.end.second, 0);
        expect(range.end.difference(range.start) >= dayStripMinSpan, isTrue);
        for (final e in entries) {
          expect(DateTime.parse(e.startTime).isBefore(range.start), isFalse);
          expect(DateTime.parse(e.endTime).isAfter(range.end), isFalse);
        }
        if (now != null) {
          expect(now.isBefore(range.start), isFalse);
          expect(now.isAfter(range.end), isFalse);
        }
        final ticks = dayStripTicks(range);
        expect(ticks.length, lessThanOrEqualTo(dayStripMaxTicks));
        expect(ticks.first, range.start);
        for (final tick in ticks) {
          expect(tick.minute, 0);
          expect(tick.isAfter(range.end), isFalse);
        }
      }
    });
  });

  group('dayStripTicks', () {
    List<int> hours(DateTime start, DateTime end) =>
        dayStripTicks((start: start, end: end)).map((t) => t.hour).toList();

    test('labels every hour of a short span', () {
      expect(hours(at(10, 0), at(14, 0)), [10, 11, 12, 13, 14]);
    });

    test('widens the step to keep at most five labels', () {
      expect(hours(at(8, 0), at(16, 0)), [8, 10, 12, 14, 16]);
      expect(hours(at(8, 0), at(20, 0)), [8, 11, 14, 17, 20]);
      expect(hours(at(6, 0), at(23, 0)), [6, 12, 18]);
    });
  });
}
