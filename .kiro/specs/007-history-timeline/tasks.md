# Implementation Plan: History Timeline

## Overview

Add Gap_Rows to the History_Screen and put the end time above the start time in the History_Row, as in variant C of
`.design/history-timeline/` (without its day strip). The logic is one pure domain file (History_Timeline) with unit
tests; the widget is `GapRow`; the History_Screen builds its list from the History_Timeline items. Tests are Flutter
unit and widget tests plus the regenerated History goldens.

## Tasks

- [x] 1. History_Timeline
  - [x] 1.1 Pure function
    - Create `lib/time_tracking/domain/history_timeline.dart` with `historyGapThreshold`, `HistoryItem`, `HistoryEntryItem`, `HistoryGapItem`, `buildHistoryItems` as in `design.md`
    - _Requirements: 1.1, 1.2, 2.1, 2.3, 2.4, 2.5, 3.1_

  - [x]* 1.2 Unit tests
    - Create `test/time_tracking/domain/history_timeline_test.dart`: ordering and tie-break, gap at 4/5/6 minutes, overlap, no gap at the ends, entry across midnight
    - **Property 1: Gaps lie exactly between neighbours**
    - **Property 2: Entries are kept and ordered**
    - **Validates: Requirements 1.1, 1.2, 2.1, 2.3, 2.4, 2.5, 3.1**

- [x] 2. Strings
  - [x] 2.1 Add the string
    - Add `time_historyGap` to `lib/l10n/app_cs.arb` (with description) and `app_en.arb`; run `flutter gen-l10n`
    - _Requirements: 4.3_

- [x] 3. Widgets
  - [x] 3.1 Gap_Row and History_Row
    - Create `widgets/cards/gap_row.dart`; swap the two times in `history_row.dart`
    - _Requirements: 1.3, 1.4, 2.2, 2.6, 4.1_

  - [x] 3.2 History_Screen
    - Build the Grouped_List children from `buildHistoryItems`
    - _Requirements: 2.5, 2.7, 4.2_

  - [x]* 3.3 Widget tests
    - In `test/time_tracking/ui/screens/time_screens_test.dart`: order newest first, Gap_Row shows the pause, no Gap_Row for a 2-minute interval or an empty day, entry count unchanged by Gap_Rows, end time above start time
    - _Requirements: 1.1, 1.3, 2.1, 2.3, 2.7_

- [x] 4. Checkpoint — verification
  - Regenerate `test/goldens/history_light.png` and `history_dark.png`; run `scripts/check.sh`

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP.
- Where this spec and spec 006 Requirement 4 differ for the History_Screen, this spec wins; spec 006 is not edited.
- The Gap_Threshold is a constant; a setting for it is out of scope.
- A day strip (Requirements 3 and 4.2 of the first version of this spec) was built and removed on 2026-11-26; commit `eb3e032` has it if it is wanted again.
