# Requirements Document

## Introduction

The History screen of DayLog lists the entries of one logical day. It is hard to see at a glance how the day went: the
rows do not show the gaps between entries, and the two times of a row run in the opposite direction to the order of
the list, so consecutive rows do not link up. This spec adds a Day_Strip above the list, shows the gaps between
entries as Gap_Rows, and arranges the times of a row so that the end of one row continues into the start of the row
below it. Martin chose this design (variant "C", with the newest entry on top) on 2026-11-26 from the mockups in
`.design/history-timeline/`.

The change is limited to `lib/time_tracking/` (the History_Screen, its widgets and one new domain file) and the two
ARB files. Where this spec and spec 006 (Requirement 4) differ for the History_Screen, this spec wins. Nothing else
changes: tapping, swiping, deleting, the summary pills, the empty state and the entry tag style stay as they are.

## Glossary

- **History_Screen**: `lib/time_tracking/ui/screens/history_screen.dart`, the screen listing the entries of one logical day.
- **History_Row**: `lib/time_tracking/ui/widgets/cards/history_row.dart`, one entry in the list.
- **Gap_Row**: A non-interactive row of the list that shows an unrecorded interval between two entries.
- **Gap_Threshold**: The shortest interval that gets a Gap_Row: 5 minutes.
- **Day_Strip**: A card above the list with a horizontal bar that shows the entries of the day as coloured segments placed on a time axis.
- **Strip_Range**: The time interval the Day_Strip covers, from a whole hour at or before the first start to a whole hour at or after the last end.
- **History_Timeline**: `lib/time_tracking/domain/history_timeline.dart`, the pure functions that order entries, find gaps and compute the Strip_Range and its ticks.
- **Now_Marker**: The thin vertical line in the Day_Strip at the current time.
- **Activity_Color**: The colour of an entry given by `activityEntryColor` for its type and subtype.

## Requirements

### Requirement 1: Order and Time Column

**User Story:** As a user, I want the newest entry on top and the times of the rows to link up, so that I can read the day from evening to morning without jumping.

#### Acceptance Criteria

1. THE History_Screen SHALL list the entries ordered by start time, the latest start first.
2. IF two entries have the same start time, THEN THE History_Screen SHALL list the entry with the higher id first.
3. THE History_Row SHALL show the end time above the start time in its time column.
4. THE History_Row SHALL show the same Activity_Color bar, description, type tag, project, subtype and duration as before.

### Requirement 2: Gap Rows

**User Story:** As a user, I want to see the pauses between entries, so that I notice unrecorded time.

#### Acceptance Criteria

1. WHEN the interval between the latest end of the entries that start earlier and the start of an entry is at least the Gap_Threshold, THE History_Screen SHALL show a Gap_Row between that entry's row and the row below it.
2. THE Gap_Row SHALL show the length of the interval formatted as a duration, labelled as a pause.
3. IF the interval is shorter than the Gap_Threshold, THEN THE History_Screen SHALL NOT show a Gap_Row.
4. IF two entries overlap, THEN THE History_Screen SHALL NOT show a Gap_Row between them.
5. THE History_Screen SHALL NOT show a Gap_Row above the first row or below the last row.
6. THE Gap_Row SHALL NOT react to taps or swipes.
7. THE Gap_Row SHALL NOT count as an entry in the summary pills.

### Requirement 3: Day Strip

**User Story:** As a user, I want a bar for the whole day, so that I see at a glance when I worked and when I did not.

#### Acceptance Criteria

1. WHEN the day has at least one entry, THE History_Screen SHALL show the Day_Strip between the summary pills and the list.
2. THE Day_Strip SHALL draw each entry as a segment in its Activity_Color, positioned and sized by its start and end within the Strip_Range.
3. THE Day_Strip SHALL leave the time without an entry as the empty track colour.
4. THE Day_Strip SHALL show hour labels under the bar at whole hours of the Strip_Range.
5. THE Day_Strip SHALL show at most five hour labels, choosing the smallest step of 1, 2, 3, 6, 12 or 24 hours that gives at most five.
6. WHEN the selected day is today and the current time lies within the Strip_Range, THE Day_Strip SHALL show the Now_Marker.
7. WHEN the selected day is today and the current time is later than the last end, THE Strip_Range SHALL extend to the whole hour after the current time.
8. THE Strip_Range SHALL span at least 6 hours.
9. THE Day_Strip SHALL be one element for assistive technologies, described by the first start and the last end of the day.
10. IF the day has no entries, THEN THE History_Screen SHALL NOT show the Day_Strip.

### Requirement 4: Entries Across Midnight

**User Story:** As a user, I want an entry that runs past midnight to appear correctly, so that the strip and the gaps are right on night shifts.

#### Acceptance Criteria

1. THE History_Timeline SHALL compute gaps, the Strip_Range and the segments from the stored timestamps, not from the hour of the day.
2. WHEN an entry ends after midnight, THE Day_Strip SHALL place its segment after the segments that start before midnight.

### Requirement 5: Appearance and Strings

**User Story:** As a user, I want the new elements to look like the rest of the app, so that the screen stays familiar.

#### Acceptance Criteria

1. THE Day_Strip and the Gap_Row SHALL read their colours from the palette and their spacing and radii from the tokens, in both themes.
2. THE Day_Strip segments SHALL have square edges.
3. THE History_Screen SHALL keep the list in one Grouped_List, with the Gap_Rows inside it.
4. THE App SHALL provide every new string in Czech and English through the ARB files, with the prefix `time_`.
