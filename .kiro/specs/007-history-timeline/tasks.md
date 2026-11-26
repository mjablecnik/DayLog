# Implementation Plan: History Timeline

## Overview

Add a Day_Strip and Gap_Rows to the History_Screen and put the end time above the start time in the History_Row, as in
variant C of `.design/history-timeline/`. The logic is one pure domain file (History_Timeline) with unit tests; the
widgets are `DayStrip` and `GapRow`; the History_Screen builds its list from the History_Timeline items. Tests are
Flutter unit and widget tests plus the regenerated History goldens.

## Tasks

- [x] 1. History_Timeline
  - [x] 1.1 Pure functions
    - Create `lib/time_tracking/domain/history_timeline.dart` with `historyGapThreshold`, `HistoryItem`, `HistoryEntryItem`, `HistoryGapItem`, `buildHistoryItems`, `dayStripRange`, `dayStripTicks` as in `design.md`
    - _Requirements: 1.1, 1.2, 2.1, 2.3, 2.4, 2.5, 3.4, 3.5, 3.7, 3.8, 4.1_

  - [x]* 1.2 Unit tests
    - Create `test/time_tracking/domain/history_timeline_test.dart`: ordering and tie-break, gap at 4/5/6 minutes, overlap, no gap at the ends, entry across midnight, range with and without `now`, minimum span, tick step and count
    - **Property 1: Gaps lie exactly between neighbours**
    - **Property 2: Entries are kept and ordered**
    - **Property 3: Strip range covers the day**
    - **Validates: Requirements 1.1, 1.2, 2.1, 2.3, 2.4, 2.5, 3.5, 3.8, 4.1**

- [x] 2. Strings
  - [x] 2.1 Add the strings
    - Add `time_historyGap` and `time_historyStripLabel` to `lib/l10n/app_cs.arb` (with descriptions) and `app_en.arb`; run `flutter gen-l10n`
    - _Requirements: 5.4_

- [x] 3. Widgets
  - [x] 3.1 Gap_Row and History_Row
    - Create `widgets/cards/gap_row.dart`; swap the two times in `history_row.dart`
    - _Requirements: 1.3, 1.4, 2.2, 2.6, 5.1_

  - [x] 3.2 Day_Strip
    - Create `widgets/cards/day_strip.dart` as in `design.md`; palette colours, tokens, square segments, one semantics node
    - _Requirements: 3.2, 3.3, 3.4, 3.6, 3.9, 4.2, 5.1, 5.2_

  - [x] 3.3 History_Screen
    - Show the Day_Strip between the pills and the list (not for an empty day); build the Grouped_List children from `buildHistoryItems`
    - _Requirements: 2.5, 2.7, 3.1, 3.10, 5.3_

  - [x]* 3.4 Widget tests
    - In `test/time_tracking/ui/screens/time_screens_test.dart`: order newest first, Gap_Row shows the pause, no Gap_Row for a 3-minute interval, Day_Strip present for entries and absent for an empty day, entry count unchanged by Gap_Rows
    - _Requirements: 1.1, 2.1, 2.3, 2.7, 3.1, 3.10_

- [x] 4. Checkpoint — verification
  - Regenerate `test/goldens/history_light.png` and `history_dark.png` and look at them next to the mockup; run `scripts/check.sh`; the History golden (four seeded entries, two pauses) stands in for running the Linux app, since startup is untouched

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP.
- Where this spec and spec 006 Requirement 4 differ for the History_Screen, this spec wins; spec 006 is not edited.
- `lib/time_tracking/` is exempt from the literal-colour guard tests until `.agents/REFACTOR.md` is done, but the new files use palette and tokens anyway.
- The Gap_Threshold is a constant; a setting for it is out of scope.
