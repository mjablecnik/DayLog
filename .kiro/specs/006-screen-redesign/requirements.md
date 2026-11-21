# Requirements Document

## Introduction

This spec moves every screen of DayLog onto the visual language of spec `004-design-system` inside the navigation of
spec `005-module-navigation`. Martin approved the result on 2026-11-21 in three review rounds; the agreed screens are
in `.design/redesign-preview/` (read its `README.md` first). The level of change is "between small and medium":
keep the character and the habits of the app, fix readability and order, never trade information density for effect.

This is a visual redesign. Every feature, every data flow and every text keeps working as it does. Exactly four
interaction changes were approved and are listed in Requirement 1; nothing else may change behaviour. Where a mockup
and a criterion here differ, the criterion wins; where a criterion is silent, the mockup and the twelve consistency
rules of spec 004 decide.

Scope: the Time module (`lib/time_tracking/ui/`), the Quests, Calendar and Notes modules (`lib/quests/ui/`,
`lib/calendar/ui/`, `lib/notes/ui/`), the Settings pages (`lib/settings/ui/`, `lib/time_tracking/ui/screens/
reminder_settings_screen.dart`, `time_settings_groups.dart`) and the shared splash, banner and empty states. Specs 004
and 005 are prerequisites of this one. Project location: `/workspace/DayLog`.

## Glossary

- **App**: The DayLog Flutter app at `/workspace/DayLog`.
- **Visual_Reference**: The folder `.design/redesign-preview/`; a render is named by its file, e.g. `r3-history` means `renders/light/r3-history.png` and `renders/dark/r3-history.png`.
- **Timer_Screen**: `lib/time_tracking/ui/screens/timer_screen.dart` and its widgets.
- **Statistics_Screen**: `lib/time_tracking/ui/screens/statistics_screen.dart`.
- **History_Screen**: `lib/time_tracking/ui/screens/history_screen.dart`.
- **Entry_Sheet**: The sheets that create or edit a time entry: `description_sheet.dart` (after the timer), `manual_entry_sheet.dart` and `edit_sheet.dart` in `lib/time_tracking/ui/widgets/sheets/`.
- **Board_Screen**: The Quest board, `lib/quests/ui/board/board_screen.dart`.
- **Missions_Screen**: `lib/quests/ui/missions/missions_screen.dart`.
- **Mission_Detail**: `lib/quests/ui/mission_detail/mission_detail_screen.dart`.
- **Form_Sheets**: `quest_sheet.dart`, `mission_sheet.dart` and `rule_sheet.dart` in `lib/quests/ui/sheets/`.
- **Calendar_Screen**: `lib/calendar/ui/screens/calendar_screen.dart` with `month_grid.dart` and `week_lanes.dart`.
- **Day_Sheet**: `lib/calendar/ui/screens/day_sheet.dart`.
- **Event_Screens**: `event_detail_screen.dart`, `event_form_screen.dart`, `event_search_screen.dart` and the sheets in `lib/calendar/ui/sheets/`.
- **Notes_Screen**: `lib/notes/ui/screens/notes/notes_screen.dart` showing the root or a folder.
- **Note_Editor**: `lib/notes/ui/screens/note_editor/note_editor_screen.dart`.
- **Trash_Screen**: `lib/notes/ui/screens/notes/trash_screen.dart` and `trash_preview_screen.dart`.
- **Settings_Page**: `lib/settings/ui/settings_screen.dart`.
- **Reminders_Screen**: `lib/time_tracking/ui/screens/reminder_settings_screen.dart` with `widgets/reminders/`.
- **Reminder_Sheet**: The form that creates or edits a recurring reminder (today `reminder_edit_dialog.dart`).
- **Level_Card**: The tinted card with the level ring, the hero name, the level and the XP line.
- **Day_Navigator**: The row with the previous and next day buttons and the day label (History and Statistics).
- **App_Header**, **Header_Action**, **Grouped_List**, **List_Row**, **Icon_Tile**, **Add_Row**, **Section_Label**, **Count_Header**, **Swipe_Actions**, **App_Sheet**, **Confirm_Dialog**, **Choice_Chip**, **Type_Tag**, **Segmented_Control**, **Form_Field**, **Primary_Button**, **Tonal_Button**, **Destructive_Button**, **Pill_Button**, **Check_Circle**, **Effort_Pips**, **Empty_State**, **Glow**, **Title_Weight**: As defined in spec `004-design-system`.
- **Guard_Tests**: As defined in spec `004-design-system`.
- **Event_Type**: As defined in spec `004-design-system`.
- **Swipe_Action**: One action (edit or delete) revealed by Swipe_Actions.
- **Module_Bar**, **Module**, **Menu_Button**, **Deep_Link**: As defined in spec `005-module-navigation`.

## Requirements

### Requirement 1: Scope and approved behaviour changes

**User Story:** As Martin, I want the new look without losing anything the app does today, so that the redesign never costs me a feature.

#### Acceptance Criteria

1. THE App SHALL keep every feature, data flow, validation and Deep_Link of every screen in this spec, and every text except the texts this spec adds, shortens or removes by name.
2. THE App SHALL change behaviour only in these four approved ways: (a) a History row opens its edit form on tap and offers edit and delete through Swipe_Actions instead of icon buttons; (b) a Reminder row opens its edit form on tap and offers delete through Swipe_Actions instead of icon buttons; (c) the Reminder_Sheet is a bottom sheet instead of a centred dialog; (d) the hero name is edited in a sheet opened from the profile card instead of an inline field.
3. THE App SHALL build every screen of this spec from the App_Header, Grouped_List, List_Row, App_Sheet, Confirm_Dialog, Choice_Chip, Form_Field and button widgets of spec 004 wherever such an element appears.
4. THE App SHALL show every screen at the Title_Weight chosen in the Experiments group.
5. WHEN this spec is complete, THE App SHALL no longer use `ScreenHeader`, `SubPageHeader`, `SettingsNavRow`, Material `AlertDialog`s or Material icon-font icons in the screens of this spec.

### Requirement 2: Timer

**User Story:** As Martin, I want a calm timer whose ring shows the time passing, so that I read the state at a glance.

#### Acceptance Criteria

1. THE Timer_Screen SHALL match render `r2-timer`: an App_Header titled „Časovač“, the ring, the duration stepper and the three controls, vertically centred with 36 logical pixels between them.
2. THE Timer_Screen ring SHALL be 290 logical pixels wide with an 8 logical pixel `lineStrong` track and an 8 logical pixel `brass` arc with round caps and the ring Glow, the arc showing the remaining share of the duration.
3. THE Timer_Screen SHALL show the remaining time inside the ring in 80 logical pixels at weight 600 with tabular figures.
4. THE Timer_Screen SHALL NOT show the phase label (`PŘIPRAVENO`, `SOUSTŘEDĚNÍ`, `PAUZA`, `ČAS VYPRŠEL`, `UKLÁDÁNÍ`) and SHALL keep the phase in the semantics label of the ring.
5. WHILE the timer is ready, THE Timer_Screen SHALL show the duration stepper as one pill: the `card` fill, a hairline border, two 44 logical pixel round minus and plus buttons with the `tone` fill and the value in 17 logical pixels at weight 650 between them.
6. THE Timer_Screen SHALL show the stop and finish controls as 58 logical pixel circles with the `card` fill and a `lineStrong` outline, with the labels „Zapsat“ and „Dokončit“ under them in 12.5 logical pixels at weight 600.
7. WHILE a secondary control is unavailable, THE Timer_Screen SHALL draw it and its label at 50 % opacity.
8. THE Timer_Screen SHALL show the start / pause control as an 84 logical pixel `brass` circle with a 32 logical pixel `inkOnBrass` icon and the button Glow.
9. THE Timer_Screen SHALL keep the reset confirmation and show it as a Confirm_Dialog matching render `r3-dialog`.
10. THE Timer_Screen SHALL keep the time-up overlay (`ringing_overlay.dart`) with its pulsing animation, draw its glow from the ring Glow role, its title in the page title role and its dismiss action as a Primary_Button.

### Requirement 3: Statistics

**User Story:** As Martin, I want the totals first and the detail under them, so that the main answer is visible without scrolling.

#### Acceptance Criteria

1. THE Statistics_Screen SHALL match render `r2-stats` with the Menu_Button as leading element instead of the back arrow drawn there.
2. THE Statistics_Screen SHALL show the Day / Week Segmented_Control as the trailing element of its App_Header.
3. THE Day_Navigator SHALL show 40 logical pixel tonal previous and next buttons and, centred between them, the period label in 19 logical pixels at weight 750 with the full date (or week range) under it in 13 logical pixels with the `textDim` colour.
4. THE Statistics_Screen SHALL show two number tiles side by side: „Sledováno“ with the tracked total in `brassText` and „Nesledováno“ with the untracked time in `textDim`, both in 34 logical pixels at weight 800 under a caps label.
5. THE Statistics_Screen SHALL show a share bar of 12 logical pixels with one segment per activity type in its colour, 2 logical pixels apart, with rounded ends.
6. THE Statistics_Screen SHALL draw the timeline track with the `tone` fill and a corner radius of 8, the activity blocks with square edges, faint vertical grid lines at a quarter, a half and three quarters, and the hour labels 3:00, 9:00, 15:00, 21:00 and 3:00 once under the track.
7. WHILE the week period is shown, THE Statistics_Screen SHALL show one track per day with the day label at its start and the hour labels only once under the last track.
8. THE Statistics_Screen SHALL show the activity types in one Grouped_List, each row with a colour dot, the name at weight 650, the duration and share right-aligned and an 8 logical pixel bar, with the subtypes indented under it in 14 logical pixels with the `textDim` colour.
9. THE Statistics_Screen SHALL show the projects in a Grouped_List under the Section_Label „Podle projektu“.

### Requirement 4: History

**User Story:** As Martin, I want my day as a readable list and to edit an entry the same way as a quest, so that I stop hunting for small icons.

#### Acceptance Criteria

1. THE History_Screen SHALL match render `r3-history`: an App_Header titled „Historie“ with a plus Header_Action, the Day_Navigator, two summary pills and the entries in one Grouped_List.
2. THE History_Screen SHALL show the summary as a `tone` pill with the entry count and a `brassSoft` pill with the total, in 13 logical pixels at weight 750.
3. THE History_Screen entry row SHALL show the start and end times stacked in a 42 logical pixel column in 13.5 logical pixels with the `textDim` colour, a 4 logical pixel bar in the activity colour, the description in 16 logical pixels at weight 650, a Type_Tag with the activity name and the project and subtype in 13 logical pixels with the `textDim` colour, and the duration right-aligned in 14.5 logical pixels at weight 650.
4. WHEN an entry row is tapped, THE History_Screen SHALL open the Entry_Sheet to edit that entry.
5. WHEN an entry row is dragged to the left, THE History_Screen SHALL reveal the edit and delete Swipe_Actions.
6. WHEN the delete Swipe_Action is pressed, THE History_Screen SHALL ask with a Confirm_Dialog and delete the entry only after confirmation.
7. THE History_Screen SHALL NOT show edit or delete icon buttons in the rows.
8. THE History_Screen SHALL show the hint „Klepnutím upravíš · tažením doleva smažeš“ under the list in 12.5 logical pixels with the `textFaint` colour.
9. IF the day has no entries, THEN THE History_Screen SHALL show an Empty_State with the existing empty texts.

### Requirement 5: Entry sheets

**User Story:** As Martin, I want to see the colour of an activity type already when I pick it, so that logging time feels like the rest of the app.

#### Acceptance Criteria

1. THE Entry_Sheet SHALL match render `r3-logsheet`: an App_Sheet with the title, the clear-form Header_Action (icon `refresh`), the type chips, the subtype panel, the project and description fields and the Primary_Button „Uložit“.
2. THE Entry_Sheet SHALL show each activity type as a Choice_Chip with the dot and the colour of that type.
3. WHILE an activity type with subtypes is selected, THE Entry_Sheet SHALL show a panel with the `tone` fill and a corner radius of 16 containing „Upřesnit · <type>“, the hint „vyber jednu“ and the subtypes as a Segmented_Control when there are at most three, or as Choice_Chips otherwise.
4. THE Entry_Sheet SHALL show the project and description inputs as Form_Fields, the description with its character counter at the bottom right.
5. WHERE the sheet follows the timer, THE Entry_Sheet SHALL show the skip action as a text button „Přeskočit“ in `textDim` under the Primary_Button.
6. WHERE the sheet creates or edits an entry from History, THE Entry_Sheet SHALL show the start and end times as two Form_Fields side by side above the type chips.
7. THE Entry_Sheet SHALL keep its suggestions, validation and save behaviour.
8. THE App SHALL open every Entry_Sheet through the shared App_Sheet route (`showAppSheet`) instead of `showModalBottomSheet`, so that the dismissal rules of spec 004 apply.

### Requirement 6: Confirmations

**User Story:** As Martin, I want every confirmation to look the same, so that I recognise a serious question at once.

#### Acceptance Criteria

1. THE App SHALL show every confirmation of an action as a Confirm_Dialog: timer reset, delete entry, delete reminder, delete quest, delete mission, delete event, delete a repeating event, move to trash, delete forever, empty trash, discard changes, replace data on import and post a recurring mission now.
2. THE App SHALL use the destructive variant for deletions, resets and discards, and the action variant for posting a recurring mission now.
3. WHERE a confirmation offers more than two choices (deleting one or all occurrences of a repeating event), THE App SHALL show the choices as List_Rows in an App_Sheet, the destructive ones in the `destructiveText` colour.

### Requirement 7: Quest board

**User Story:** As Martin, I want a tidy board where the level and the quests are clearly separated, so that I see what to do and what it earns.

#### Acceptance Criteria

1. THE Board_Screen SHALL match render `r2-quests`: an App_Header titled „Nástěnka“ with the date as subtitle, the Level_Card, the sections and the add button.
2. THE Level_Card SHALL have the `brassSoft` fill, a corner radius of 22 and 16 logical pixels of padding, with a 64 logical pixel ring (6 logical pixel stroke, `lineStrong` track, `brass` progress), the level number inside in 24 logical pixels at weight 800 in `brassText`, the hero name in 13 logical pixels with `textDim`, „Úroveň N“ in 19 logical pixels at weight 800 and the XP line „<xp> / <threshold> XP · ještě <rest>“ in 13 logical pixels.
3. THE Board_Screen SHALL head each section with a Count_Header (title, count, XP pill in `brassSoft`) and show its quests in one Grouped_List.
4. THE Board_Screen quest row SHALL show a Check_Circle, the name in 16 logical pixels at weight 600, a meta line with the event dot, type and time for calendar quests and the Effort_Pips, and the XP as a `brassSoft` pill at the right.
5. THE Board_Screen SHALL show done quests with a filled Check_Circle and the name struck through in `textFaint`.
6. THE Board_Screen SHALL keep the swipe actions, drag reordering, completion, reward and empty-section texts of today.
7. THE Board_Screen SHALL keep the hint „Tažením doleva upravíš nebo smažeš · klepnutím na kroužek splníš“ under the lists in 12.5 logical pixels with the `textFaint` colour.
8. THE Board_Screen SHALL show the add button as a plain plus without a label.

### Requirement 8: Missions

**User Story:** As Martin, I want to see which mission is almost finished, so that I am motivated to complete it.

#### Acceptance Criteria

1. THE Missions_Screen SHALL match render `r3-missions`: an App_Header titled „Mise“ with the open count as subtitle, the Level_Card of the Board_Screen and the missions in Grouped_Lists under Count_Headers.
2. THE Missions_Screen mission row SHALL show a 50 logical pixel ring with a 5 logical pixel stroke whose `brass` arc shows the share of done quests.
3. THE Missions_Screen SHALL show inside the ring the number of quests still remaining, in 18 logical pixels at weight 800, exactly as the number shown today.
4. THE Missions_Screen mission row SHALL show the name in 16.5 logical pixels at weight 600, the remaining XP line in 13.5 logical pixels with `textDim` and the completion bonus as a `brassSoft` pill „+<bonus> XP“ at the right.
5. THE Missions_Screen SHALL keep its swipe actions, its completed missions and its empty state texts.

### Requirement 9: Mission detail

**User Story:** As Martin, I want the mission detail to look like the rest of the app, so that the name does not push the quests off the screen.

#### Acceptance Criteria

1. THE Mission_Detail SHALL match render `r3-mission`: an App_Header with the back element, the title „Mise“ and a more Header_Action that opens the existing mission menu.
2. THE Mission_Detail SHALL show the mission name in the detail title role and the progress text under it in 14.5 logical pixels with `textDim`.
3. THE Mission_Detail SHALL show a progress card with „Postup“, the bonus pill „+<bonus> XP za dokončení“ and an 8 logical pixel `brass` progress bar.
4. THE Mission_Detail SHALL show the remaining quests under a header „Zbývá“ with „<n> quest · <xp> XP“ at the right, in a Grouped_List whose last row is the Add_Row „Přidat quest do mise“.
5. THE Mission_Detail SHALL show the done quests under „Splněno“ in a Grouped_List with filled Check_Circles, struck-through names and the completion date.
6. WHILE every quest is done and the mission is not completed, THE Mission_Detail SHALL show the Primary_Button „Dokončit misi“ above the lists.
7. THE Mission_Detail SHALL keep the completed state with its seal and bonus line, restyled with the new tokens.
8. THE Mission_Detail SHALL NOT show the Module_Bar (it is a pushed route).

### Requirement 10: Form sheets

**User Story:** As Martin, I want the quest form to fit on one screen, so that I post a quest without scrolling.

#### Acceptance Criteria

1. THE Form_Sheets SHALL match render `r3-questadd`: App_Sheet header, Section_Labels, Form_Fields, Choice_Chips, Segmented_Controls and a full-width Primary_Button.
2. THE quest sheet SHALL show the effort options as a two-by-two grid of cards (name 16 logical pixels weight 700, time 13 logical pixels `textDim`, „+<xp> XP“ 14 logical pixels weight 750 in `brassText` with the Effort_Pips), the selected card with a 2 logical pixel `brass` border and an 8 % `brass` tint.
3. THE quest sheet SHALL show the mission choice as Choice_Chips and the board choice as a Segmented_Control with the options the sheet offers today.
4. THE quest sheet SHALL keep the deadline and note inputs, the locked fields of a done quest and the primary action „Vyvěsit quest“ with the arrow-up icon.
5. THE mission sheet SHALL show the bonus as a Segmented_Control with the XP under each label and the quests of the mission as rows with an Add_Row „Přidat quest“.
6. THE rule sheet SHALL show the repeat options as Choice_Chips, the posting day as a List_Row with a chevron, the reward as a Segmented_Control and the quests with an Add_Row.
7. WHEN the posting day row is tapped, THE rule sheet SHALL offer the same choices as today as List_Rows with a selection mark in an App_Sheet, replacing the centred choice dialog.

### Requirement 11: Reward overlay

**User Story:** As Martin, I want to keep the reward moment as it is, so that the most playful part of the app stays special.

#### Acceptance Criteria

1. THE App SHALL keep the reward and level-up overlay (`lib/quests/ui/reward/`) with its rays, figure, texts and timing.
2. THE App SHALL draw the reward overlay with the palette roles of spec 004 and its button as a Primary_Button.

### Requirement 12: Calendar month

**User Story:** As Martin, I want big day cells that still show the names of my events, so that the month stays readable.

#### Acceptance Criteria

1. THE Calendar_Screen SHALL match render `r2-calendar`: an App_Header with the month name and the year in weight 500 `textDim`, the search and filter Header_Actions, a navigation row and the month grid.
2. THE Calendar_Screen navigation row SHALL show 38 logical pixel tonal previous and next buttons at the left and the „Dnes“ chip at the right with the `brassSoft` fill, a corner radius of 12 and its label in 14 logical pixels at weight 700 in `brassText`.
3. THE Calendar_Screen grid SHALL show the weekday names in caps at 11.5 logical pixels weight 700 `textFaint` and separate the weeks with horizontal hairlines only.
4. THE Calendar_Screen SHALL fill the cells of days outside the shown month with `tone` and draw their numbers in `textFaint`.
5. THE Calendar_Screen SHALL draw the day number in 13 logical pixels at weight 600 centred in a 24 logical pixel circle and fill that circle with `brass` (number in `inkOnBrass`) for today, without a cell border.
6. THE Calendar_Screen event chip SHALL use 11 logical pixels at weight 650, a corner radius of 5 and padding of 4, the event colour at 26 % over the ground as fill and the event colour mixed 40 % into `text` as text colour, for every Event_Type alike.
7. THE Calendar_Screen SHALL keep the event names in the cells, clipped at the cell edge, at most three chips per cell plus „+N“, and multi-day chips spanning their days.
8. THE Calendar_Screen SHALL size the grid so that the add button does not cover any cell of the last week.
9. THE Calendar_Screen SHALL apply the same chip and today styles to the week lanes view.

### Requirement 13: Day sheet

**User Story:** As Martin, I want to keep opening a day in a sheet, so that the month stays as it is.

#### Acceptance Criteria

1. WHEN a day is tapped, THE Calendar_Screen SHALL open the Day_Sheet as today and mark the tapped cell with the `brassSoft` fill while the sheet is open.
2. THE Day_Sheet SHALL match render `r2-calendar-sheet`: an App_Sheet header with the weekday and date as title, the event count as subtitle and the close Header_Action.
3. THE Day_Sheet SHALL show each event in a card with the start and end times stacked at the left in 14 logical pixels `textDim`, a 4 logical pixel bar in the event colour, the title in 17 logical pixels at weight 700 and the type in 14 logical pixels `textDim`.
4. THE Day_Sheet SHALL show the Primary_Button „Přidat událost“ with the plus icon.

### Requirement 14: Event screens

**User Story:** As Martin, I want the event detail, form, search and filter to follow the same rules, so that the calendar feels finished.

#### Acceptance Criteria

1. THE event detail screen SHALL keep the close element, show only a more Header_Action besides it and show the title once, in the detail title role, inside its card.
2. THE event detail screen SHALL show the type as a Type_Tag, the start and end as a compact pair, the details, repeat and address as List_Rows with Icon_Tiles, and the Primary_Button „Upravit“ at the bottom.
3. THE event form screen SHALL use an App_Header with the back element, the title „Nová událost“ or „Upravit událost“ and the save action as a small Primary_Button at the right, enabled only when the form can be saved.
4. THE event form screen SHALL show the type picker as a two-column grid of Choice_Chips with dots, the all-day switch and every value as Form_Fields.
5. THE event search screen SHALL show the search input as a focused Form_Field in its header and the results in a Grouped_List with a dot, the title and „<type> · <date>“.
6. THE type filter sheet SHALL use the App_Sheet header, show the types as List_Rows with a dot and a switch in a Grouped_List and keep „Zobrazit všechny typy“ as a Tonal_Button and „Hotovo“ as the Primary_Button.
7. THE month picker sheet and the delete event sheet SHALL use the App_Sheet header and List_Rows.

### Requirement 15: Notes

**User Story:** As Martin, I want folders and notes as clean lists, so that the notes module matches the others.

#### Acceptance Criteria

1. THE Notes_Screen at the root SHALL match render `r3-notes`: an App_Header titled „Poznámky“ with „<n> složky · <m> poznámka“ as subtitle and the trash Header_Action with its count badge.
2. THE Notes_Screen SHALL show folders under the Section_Label „Složky“ as List_Rows in a Grouped_List with a 40 logical pixel folder Icon_Tile (corner radius 12), the name, the note count as value and a chevron.
3. THE Notes_Screen SHALL show notes under the Section_Label „Poznámky“ in a Grouped_List, each row with the title in 16 logical pixels at weight 650, the short date („14. 11.“) right-aligned in 13 logical pixels `textFaint` and the text preview under the title in 14.5 logical pixels `textDim`.
4. THE Notes_Screen SHALL keep its swipe actions, its move and rename flows and its add button.

### Requirement 16: Folder

**User Story:** As Martin, I want one clear header in a folder, so that I always know where I am and how to go back.

#### Acceptance Criteria

1. WHILE a folder is shown, THE Notes_Screen SHALL match render `r3-folder`: an App_Header with the back element, the folder name as title, the path „Poznámky › <folder>“ as subtitle and a more Header_Action that opens the folder menu.
2. WHILE a folder is shown, THE Notes_Screen SHALL NOT show the separate breadcrumb row or a Menu_Button below the header.
3. WHILE a folder is shown, THE Notes_Screen SHALL keep the Module_Bar visible.
4. WHILE a nested folder is shown, THE Notes_Screen SHALL shorten the subtitle path from the left with an ellipsis when it does not fit.

### Requirement 17: Note editor and notes sheets

**User Story:** As Martin, I want the editor and the notes sheets to follow the same rules, so that nothing looks left over from the old app.

#### Acceptance Criteria

1. THE Note_Editor SHALL show an App_Header with the back element, the parent folder name (or „Poznámky“) as title, a more Header_Action and the text action „Hotovo“ in `brassText` at weight 700.
2. THE Note_Editor SHALL show the note title in the note title role and keep the format toolbar unchanged.
3. THE add, move, name, link and node menu sheets of the Notes module SHALL use the App_Sheet header and show their options as List_Rows with Icon_Tiles.

### Requirement 18: Trash

**User Story:** As Martin, I want the trash to follow the same rules, so that restoring and emptying are clear.

#### Acceptance Criteria

1. THE Trash_Screen SHALL show an App_Header with the back element, the title „Koš“ and the item count as subtitle.
2. THE Trash_Screen SHALL show the retention note in a box with the `tone` fill and a corner radius of 16.
3. THE Trash_Screen SHALL show deleted items as List_Rows in a Grouped_List with an Icon_Tile, the name, „z <place> · <when>“ as subtitle and a Pill_Button „Obnovit“ at the right.
4. THE Trash_Screen SHALL show „Vysypat koš“ as a Destructive_Button at the bottom, confirmed by a Confirm_Dialog.
5. THE trash preview screen SHALL use an App_Header with the back element and the item name as title and keep its restore and delete-forever actions as a Primary_Button and a Destructive_Button.

### Requirement 19: Empty states, splash and banner

**User Story:** As Martin, I want empty and loading screens to look the same everywhere, so that nothing looks broken.

#### Acceptance Criteria

1. THE App SHALL show every empty list and empty screen of this spec with the Empty_State of spec 004 and the existing texts, the Quest board included (the pinned blank slip is retired).
2. THE App SHALL draw the splash screen and the reconcile banner with the palette roles of spec 004, the banner's retry action as a Pill_Button.
3. THE App SHALL keep the skeleton placeholders with the `tone` fill and the `card` corner radius.

### Requirement 20: Settings page

**User Story:** As Martin, I want settings grouped with icons and current values, so that I find any setting in two seconds.

#### Acceptance Criteria

1. THE Settings_Page SHALL match render `r2-settings`: an App_Header titled „Nastavení“, the profile card and the groups „Vzhled a jazyk“, „Plánování“, „Zařízení a data“, „Experimenty“ (spec 005) and „O aplikaci“, in this order.
2. THE Settings_Page profile card SHALL show a 54 logical pixel `brassSoft` circle with the initial of the hero name in `brassText` at 22 logical pixels weight 800, the hero name in 18 logical pixels at weight 750, „Celkem <xp> XP“ in 13.5 logical pixels `textDim` and a pencil Header_Action.
3. WHEN the pencil is pressed, THE Settings_Page SHALL open an App_Sheet „Jméno hrdiny“ with the name Form_Field, its counter „<n> / 40“ and the Primary_Button „Uložit“, saving through the existing settings service.
4. THE Settings_Page SHALL show the language as a List_Row with the `globe` Icon_Tile and a Segmented_Control „CZ“ / „EN“ whose segments carry the full language names as semantics labels.
5. THE Settings_Page SHALL show the appearance as a List_Row with the `contrast` Icon_Tile and an icon-only Segmented_Control with sun, moon and monitor for light, dark and system.
6. THE Settings_Page group „Plánování“ SHALL hold „Pravidelné mise“ with the active count as value, „Opakované připomínky“ and „Testování“, each with an Icon_Tile (`repeat`, `bell`, `flask`) and a chevron.
7. THE Settings_Page group „Zařízení a data“ SHALL hold „Zkratka na ploše“, „Exportovat data“ and „Importovat data“ with the Icon_Tiles `smartphone`, `upload` and `download`, keeping the export and import flows and their messages.
8. THE Settings_Page group „O aplikaci“ SHALL hold „Licence“ with a chevron and the version as a List_Row value.
9. THE Settings_Page SHALL keep the module group slot through which the Time module adds its rows, now rendered as List_Rows inside the „Plánování“ group.
10. WHEN an import file has been read, THE Settings_Page SHALL ask „Nahradit data?“ with the destructive Confirm_Dialog whose body lists the existing summary lines.
11. WHEN an import has finished, THE Settings_Page SHALL show the existing result texts in an App_Sheet titled „Import hotov“ with the Primary_Button „Zavřít“, replacing the result dialog.

### Requirement 21: Reminders

**User Story:** As Martin, I want reminders as a clean list where "done" looks like a done quest, so that the app speaks one language.

#### Acceptance Criteria

1. THE Reminders_Screen SHALL match render `r3-reminders`: an App_Header with the back element, the title „Opakované připomínky“ and a plus Header_Action, and the reminders in one Grouped_List.
2. THE Reminders_Screen row SHALL show a Check_Circle for today's completion at the left, the name in 16.5 logical pixels at weight 600, „<from>–<to> · každých <n> min“ in 14 logical pixels `textDim`, the active days in 13 logical pixels `textFaint` and the active switch at the right.
3. WHILE a reminder is inactive, THE Reminders_Screen SHALL draw its whole row at 50 % opacity.
4. WHEN a row is tapped, THE Reminders_Screen SHALL open the Reminder_Sheet for that reminder.
5. WHEN a row is dragged to the left, THE Reminders_Screen SHALL reveal the delete Swipe_Action, confirmed by a Confirm_Dialog.
6. THE Reminders_Screen SHALL NOT show edit or delete icon buttons in the rows.
7. THE Reminders_Screen SHALL show the hint „Klepnutím upravíš · tažením doleva smažeš · kroužkem označíš jako hotové“ under the list in 12.5 logical pixels `textFaint`.
8. THE reminder action screen (`reminder_action_screen.dart`, opened from a reminder notification) SHALL use an App_Header with the close element, show the reminder name in the detail title role with its window and interval under it, and show „Hotovo“ as a Primary_Button and „Odložit“ as a Tonal_Button, keeping their behaviour.

### Requirement 22: Reminder sheet

**User Story:** As Martin, I want the reminder form to be a sheet like every other form, so that creating a reminder feels familiar.

#### Acceptance Criteria

1. THE Reminder_Sheet SHALL be an App_Sheet matching render `r3-reminderadd` with the title „Nová připomínka“ or „Upravit připomínku“.
2. THE Reminder_Sheet SHALL show the name as a Form_Field with its counter, and the from and to times as two Form_Fields side by side.
3. WHILE the window spans midnight, THE Reminder_Sheet SHALL show the existing note under the times in 13 logical pixels `brassText`.
4. THE Reminder_Sheet SHALL show the repeat interval as a Segmented_Control with the values of today and the unit „minut“ under it.
5. THE Reminder_Sheet SHALL show the active days as seven 40 logical pixel circles, filled `brass` when active and `tone` when not.
6. THE Reminder_Sheet SHALL show „Aktivní“ as a card row with a switch and „Uložit“ as the Primary_Button.
7. THE Reminder_Sheet SHALL keep the existing validation, the discard question and the save behaviour.

### Requirement 23: Other settings pages

**User Story:** As Martin, I want the remaining settings pages to follow the same rules, so that no page looks unfinished.

#### Acceptance Criteria

1. THE recurring missions page (`lib/settings/ui/rules_screen.dart`) SHALL show its rules as List_Rows in a Grouped_List with the `repeat` Icon_Tile, the rule summary as subtitle and the Pill_Button „Vyvěsit hned“, and the Add_Row „Přidat pravidelnou misi“ as the last row.
2. THE home screen shortcut page SHALL show its title in full without truncation and offer the target screens as a Grouped_List per Module with a selection mark on the chosen screen.
3. THE home screen shortcut page SHALL keep the link field with its copy action and the numbered steps.
4. THE testing page and the licences page SHALL use the App_Header with the back element and show their content as List_Rows in Grouped_Lists.

### Requirement 24: Verification

**User Story:** As Martin, I want the result checked against the agreed mockups, so that the implementation does not drift from what we decided.

#### Acceptance Criteria

1. THE App SHALL pass `scripts/check.sh` with the golden images regenerated deliberately and reviewed against the Visual_Reference.
2. WHEN a module is complete, THE App SHALL be run as the real Linux app and its screens SHALL be screenshotted in light and dark and compared with the renders named in this spec.
3. THE App SHALL keep the Guard_Tests green and add no new literal colours, spacing, durations or icon-font icons, including in `lib/time_tracking/`.
4. THE App SHALL pass the accessibility tests in `test/a11y/` with every changed screen.
