# Design Document: History Timeline

## Overview

The History_Screen keeps its structure (header, Day_Navigator, summary pills, one Grouped_List, swipe hint). Two
things change: Gap_Rows appear between entry rows, and the order of the two times in a History_Row is swapped.

**Key design decisions:**

- **All logic is pure and in one domain file.** The History_Timeline turns the entry list into a list of items (entry or
  gap). Widgets only draw what it returns, so the rules are unit-tested without a widget tree.
- **The provider is unchanged.** `watchEntriesForDay` already orders by start time descending. The History_Timeline
  sorts again (start descending, id descending) so that its result does not depend on the query.
- **Gaps are derived, never stored.** A gap is the interval between an entry's start and the latest end of all entries
  that start earlier (so an entry that covers a shorter one does not leave a false gap). No schema change, no migration.
- **No day strip.** Variant C of the mockups had a strip above the list; it was built and removed on Martin's request.

## Project Structure

```
lib/time_tracking/
├── domain/
│   └── history_timeline.dart           # NEW: items and gaps (pure)
└── ui/
    ├── screens/history_screen.dart     # CHANGED: items instead of entries
    └── widgets/cards/
        ├── history_row.dart            # CHANGED: end above start
        └── gap_row.dart                # NEW: Gap_Row
test/time_tracking/
├── domain/history_timeline_test.dart   # NEW
└── ui/screens/time_screens_test.dart   # CHANGED: order, gap row
```

## Components and Interfaces

### 1. History_Timeline (`lib/time_tracking/domain/history_timeline.dart`)

```dart
/// Shortest interval that gets a Gap_Row.
const Duration historyGapThreshold = Duration(minutes: 5);

sealed class HistoryItem {
  const HistoryItem();
}

final class HistoryEntryItem extends HistoryItem {
  const HistoryEntryItem(this.entry);
  final TimeEntry entry;
}

final class HistoryGapItem extends HistoryItem {
  const HistoryGapItem({required this.from, required this.to});
  final DateTime from; // latest end of the entries before the gap
  final DateTime to; // start of the later entry
  Duration get length => to.difference(from);
}

/// Entries newest first with a [HistoryGapItem] wherever the interval between an
/// entry and everything before it is at least [historyGapThreshold]. Never starts
/// or ends with a gap.
List<HistoryItem> buildHistoryItems(List<TimeEntry> entries);
```

### 2. Gap_Row (`lib/time_tracking/ui/widgets/cards/gap_row.dart`)

```dart
class GapRow extends StatelessWidget {
  const GapRow({super.key, required this.length});
  final Duration length;
}
```

A row on the `palette.tone` background: a dashed line, the text `time_historyGap(duration)` in 12.5 px weight 600 in
`palette.textDim`, a short dashed line. Same horizontal padding as the History_Row; no `InkWell`.

### 3. History_Row (`.../history_row.dart`)

Only the time column changes: the end time above the start time.

### 4. History_Screen (`.../history_screen.dart`)

`DaySummary` keeps receiving the entries. The `GroupedList` children come from `buildHistoryItems(entries)`:
`HistoryEntryItem` → `HistoryRow` (as now), `HistoryGapItem` → `GapRow`.

## Data Models

No schema change. The new string:

| Key | cs | en |
|---|---|---|
| `time_historyGap` | pauza {duration} | gap {duration} |

## Correctness Properties

### Property 1: Gaps lie exactly between neighbours

*For any* list of entries, every HistoryGapItem produced by `buildHistoryItems` SHALL lie between two HistoryEntryItems and SHALL have a length of at least the Gap_Threshold.

**Validates: Requirements 2.1, 2.3, 2.4, 2.5**

### Property 2: Entries are kept and ordered

*For any* list of entries, the HistoryEntryItems of `buildHistoryItems` SHALL contain every entry exactly once, ordered by start descending and id descending.

**Validates: Requirements 1.1, 1.2**

## Error Handling

| Category | Condition | Behaviour |
|---|---|---|
| Empty list | Day without entries | `buildHistoryItems` returns an empty list |
| Entry with end before start | Corrupt or imported row | Its end does not move the latest end back, so it never produces a gap |
| Unparseable timestamp | Corrupt row | Same as today: `DateTime.parse` throws; the screen's error state is not extended |

## Testing Strategy

- **Unit** (`flutter_test`, `test/time_tracking/domain/history_timeline_test.dart`): ordering and tie-break, gap
  threshold (4, 5, 6 minutes), overlap, midnight, with a seeded random generator for Properties 1 and 2.
- **Widget** (`test/time_tracking/ui/screens/time_screens_test.dart`): rows are in newest-first order, a Gap_Row shows
  the pause, no Gap_Row for a short interval or an empty day, the end time sits above the start time, the existing
  tap/swipe/delete test still passes.
- **Goldens**: `test/goldens/history_{light,dark}.png` show four entries with two pauses.
