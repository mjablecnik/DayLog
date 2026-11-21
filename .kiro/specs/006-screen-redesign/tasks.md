# Implementation Plan: Screen Redesign

## Overview

Move every screen onto the design system of spec 004 inside the module navigation of spec 005, one module at a time:
Time, Quests, Calendar, Notes, Settings. Each module ends with its tests, regenerated goldens and the real Linux app
compared with its renders in `.design/redesign-preview/renders/`. Behaviour stays as it is, except the four approved
changes of Requirement 1.2, which have their own tasks. Before each screen, open its render and "now" shot from the
screen map in `design.md`.

## Tasks

- [ ] 1. Preparation
  - [ ] 1.1 Check the prerequisites and the reference
    - Confirm specs 004 and 005 are complete (`AppHeader`, `GroupedList`, `ModuleBar` exist; `scripts/check.sh` green)
    - Read `.design/redesign-preview/README.md`; open `index.html` and `round2.html` in a browser or read the PNGs in `renders/`
    - _Requirements: 1.3, 1.4, 24.1_

  - [ ] 1.2 Small additions to the shared widgets
    - `AppHeader.titleSuffix` and `AppSheet.subtitle` as in `design.md` ("Small additions to spec 004 widgets"), with widget tests
    - _Requirements: 12.1, 13.2_

  - [ ] 1.3 Add the strings
    - Add the keys of the "New strings" table in `design.md` to `app_cs.arb` (with descriptions) and `app_en.arb`; run `flutter gen-l10n`; reuse existing keys wherever a text already exists
    - _Requirements: 1.1, 4.8, 21.7_

- [ ] 2. Time module
  - [ ] 2.1 Timer screen
    - `timer_screen.dart`, `timer_controls.dart`, `duration_adjuster.dart`, `ring_painter.dart`: layout of render `r2-timer` — 290 px ring, 8 px `lineStrong` track, 8 px `brass` arc with round caps and ring Glow, time 80/600 tabular, 36 px gaps
    - Remove the phase label; put the phase into the ring's semantics label
    - Duration stepper as one pill (card fill, hairline, 44 px tonal round buttons, value 17/650); stop and finish as 58 px card circles with `lineStrong` outline and the labels `time_timerStopShort` / `time_timerFinishShort`; unavailable controls at 50 %; start/pause 84 px `brass` with 32 px icon and button Glow
    - Reset confirmation through `confirmDestructive`
    - `ringing_overlay.dart`: keep the pulse, glow from the ring Glow role, title in the page title role, dismiss as `AppButton.primary`
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5, 2.6, 2.7, 2.8, 2.9, 2.10, 6.1_

  - [ ] 2.2 Statistics screen
    - `statistics_screen.dart`, `day_navigator.dart`, `day_selector.dart`, `timeline_painter.dart`, `bar_painter.dart`: render `r2-stats` with the Menu_Button leading; Day/Week `AppSegmented` in the header; Day_Navigator with 40 px tonal buttons and the two-line label; `StatTiles`; 12 px share bar; timeline with `tone` track, square blocks, grid lines and one label row; week tracks with labels only under the last; activities and projects as Grouped_Lists
    - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5, 3.6, 3.7, 3.8, 3.9_

  - [ ] 2.3 History screen (approved behaviour change a)
    - New `widgets/cards/history_row.dart` (`HistoryRow`), delete `history_entry_card.dart` after moving its edit and delete logic into `history_screen.dart`
    - Render `r3-history`: header with plus Header_Action, Day_Navigator, summary pills (`time_historyEntriesCount` on `tone`, `time_historyTotalShort` on `brassSoft`), Grouped_List of `SwipeActions(edit, delete)` around `HistoryRow`s, hint `time_historyHint`, Empty_State when empty
    - Tap opens the edit Entry_Sheet; delete confirms with `confirmDestructive(time_historyDeleteEntryTitle, time_historyDeleteEntryBody)`
    - _Requirements: 1.2, 4.1, 4.2, 4.3, 4.4, 4.5, 4.6, 4.7, 4.8, 4.9, 6.1_

  - [ ]* 2.4 Property and widget tests for History
    - **Property 3: Swipe and tap reach the same edit form**
    - In `test/time_tracking/ui/screens/history_screen_test.dart`: for generated entries, tap and the edit swipe action open the sheet with equal initial values; delete asks first and deletes only on confirm; no edit/delete icon buttons are present
    - **Validates: Requirements 4.4, 4.5**

  - [ ] 2.5 Entry sheets
    - `description_sheet.dart`, `manual_entry_sheet.dart`, `edit_sheet.dart`, `activity_picker/*`: `AppSheet` with the clear-form Header_Action (`refresh`), activity `ChoiceChipX` with dots in the activity colours, subtype panel (`tone`, radius 16, `time_descriptionRefine`, `time_descriptionChooseOne`, `AppSegmented` for ≤ 3 subtypes else chips), project and description fields in the Form_Field look with the counter, Primary_Button „Uložit“, text button „Přeskočit“ only after the timer, start/end `FormFieldBox`es for manual and edit
    - Keep suggestions, validation and save behaviour
    - Open the sheets from `timer_screen.dart` and `history_screen.dart` through `showAppSheet` instead of `showModalBottomSheet`
    - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5, 5.6, 5.7, 5.8_

  - [ ]* 2.6 Update the Time module tests
    - Existing tests in `test/time_tracking/ui/` adapted to the new structure (finders by key or text, not by removed icons); phase label absent but present in semantics; chips carry the activity colour
    - _Requirements: 2.4, 5.2, 5.7, 24.4_

  - [ ] 2.7 Verify the Time module
    - Regenerate the affected goldens and add History goldens (light, dark) to `test/goldens/screens_golden_test.dart`; run `test/a11y/`
    - Real Linux app: Timer at rest and running, Statistics day and week, History with a swiped row, the entry sheet; light and dark; compare with `r2-timer`, `r2-stats`, `r3-history`, `r3-logsheet`, `r3-dialog`
    - _Requirements: 24.1, 24.2, 24.3, 24.4_

- [ ] 3. Checkpoint — Time module
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 4. Quests module
  - [ ] 4.1 Level card and board
    - New `quests/ui/hero/level_card.dart` (`LevelCard`) per Requirement 7.2
    - `board_screen.dart`, `quest_list.dart`, `section_header.dart`, `quest_row.dart`, `quest_card.dart`: render `r2-quests` — header „Nástěnka“ with the date subtitle, `LevelCard`, `CountHeader` with count and XP pill, sections as Grouped_Lists, rows with `CheckCircle`, name 16/600, meta with event dot/type/time and `EffortPips`, XP pill; done rows filled and struck through; plain-plus add button; hint kept
    - Keep swipe actions, drag reordering, completion, reward and the empty-section texts (empty drop zones as `tone` boxes radius 18 with the existing text)
    - _Requirements: 7.1, 7.2, 7.3, 7.4, 7.5, 7.6, 7.7, 7.8_

  - [ ] 4.2 Missions screen
    - `missions_screen.dart`, `mission_card.dart`, `progress_ring.dart`: render `r3-missions` — header „Mise“ with the open count subtitle, `LevelCard`, Count_Headers and Grouped_Lists; ring 50 px stroke 5 with the progress arc and the remaining-quest number inside (18/800, same source as today); name, remaining XP, bonus pill; swipe actions and completed missions kept
    - _Requirements: 8.1, 8.2, 8.3, 8.4, 8.5_

  - [ ]* 4.3 Property test for the mission ring
    - **Property 1: The mission ring shows the remaining quests**
    - In `test/quests/ui/missions_ring_test.dart`: for generated (total, done) pairs, the centre text is `total − done` and the arc sweep is `done / total` (0 when total is 0)
    - **Validates: Requirements 8.2, 8.3**

  - [ ] 4.4 Mission detail
    - `mission_detail/*`: render `r3-mission` — App_Header back + „Mise“ + more action (existing menu, restyled as an App_Sheet of List_Rows with delete in `destructiveText`), name in `displayMedium`, progress text, progress card with `mission_progressLabel`, bonus pill and 8 px bar, „Zbývá“ group with `mission_remainingQuestsXp` and the Add_Row, „Splněno“ group, `AppButton.primary(mission_completeAction)` when ready, completed state with seal restyled
    - _Requirements: 9.1, 9.2, 9.3, 9.4, 9.5, 9.6, 9.7, 9.8, 6.1_

  - [ ] 4.5 Form sheets
    - `quest_sheet.dart` with the new `quests/ui/widgets/effort_grid.dart` (`EffortGrid`, replaces the layout of `effort_picker.dart`), mission `ChoiceChipX`s, board `AppSegmented`, deadline and note fields, locked fields of a done quest, primary „Vyvěsit quest“ with arrow-up
    - `mission_sheet.dart`: bonus `AppSegmented` with XP under each label, quest rows and Add_Row; `rule_sheet.dart`: repeat chips, posting day List_Row with chevron, reward segmented, quests with Add_Row; the posting-day choice (`_showChoiceDialog`) becomes an App_Sheet of List_Rows with a selection mark
    - _Requirements: 10.1, 10.2, 10.3, 10.4, 10.5, 10.6, 10.7_

  - [ ] 4.6 Reward overlay and quest confirmations
    - `quests/ui/reward/*`: palette roles of spec 004 and the button as `AppButton.primary`; rays, figures, texts and timing unchanged
    - Quest and mission delete and discard confirmations through `confirmDestructive`
    - _Requirements: 11.1, 11.2, 6.1, 6.2_

  - [ ]* 4.7 Update the Quests module tests
    - Existing tests in `test/quests/` and `test/e2e/e2e_scenario_test.dart`, `haptics_flow_test.dart` adapted; effort grid selection; locked fields; reward overlay still over pushed routes
    - _Requirements: 7.6, 10.4, 11.1, 24.4_

  - [ ] 4.8 Verify the Quests module
    - Regenerate `board_*` and `missions_*` goldens and review; run `test/a11y/`; real Linux app: board, missions, mission detail (open, ready, completed), new-quest sheet, reward; light and dark; compare with `r2-quests`, `r3-missions`, `r3-mission`, `r3-questadd`
    - _Requirements: 24.1, 24.2, 24.4_

- [ ] 5. Calendar module
  - [ ] 5.1 Month view and week lanes
    - `calendar_screen.dart`, `month_grid.dart`, `week_lanes.dart`, `widgets/event_chip.dart`: render `r2-calendar` — header with month and `titleSuffix` year, search and filter Header_Actions, navigation row (38 px tonal buttons, „Dnes“ chip), weekday caps, horizontal hairlines only, `tone` outside days, 24 px day circle with `brass` today, one chip style for every type (26 % fill, 40 % text mix, radius 5, 11/650, clipped), max three chips plus „+N“, multi-day spans, grid height leaving the add button clear of the last week
    - _Requirements: 12.1, 12.2, 12.3, 12.4, 12.5, 12.6, 12.7, 12.8, 12.9_

  - [ ]* 5.2 Property test for chip contrast
    - **Property 2: Calendar chips are readable for every type**
    - In `test/theme/event_colors_test.dart`: for every Event_Type and both palettes, the chip text on the chip fill reaches 4.5 : 1
    - **Validates: Requirements 12.6**

  - [ ] 5.3 Day sheet
    - `day_sheet.dart`, `event_task_card.dart`: render `r2-calendar-sheet` — App_Sheet with weekday-date title, count subtitle and close action; event cards (times 14 `textDim`, 4 px colour bar, title 17/700, type 14 `textDim`); Primary_Button with plus; the tapped cell gets `brassSoft` while open
    - _Requirements: 13.1, 13.2, 13.3, 13.4_

  - [ ] 5.4 Event screens and sheets
    - `event_detail_screen.dart`: close + more only, title once in `displayMedium` inside the card, Type_Tag, compact start→end, details/repeat/address as List_Rows with Icon_Tiles, Primary_Button „Upravit“
    - `event_form_screen.dart`, `calendar_fields.dart`, `event_type_picker.dart`, `address_suggestions.dart`: App_Header back + title + small Primary_Button save (enabled only when savable), type grid of dot chips, all-day switch row, values as Form_Fields
    - `event_search_screen.dart`: search Form_Field in the header, results Grouped_List (dot, title, type · date), Empty_State „Nic nenalezeno“
    - `sheets/type_filter_sheet.dart`, `month_picker_sheet.dart`, `delete_event_sheet.dart`: App_Sheet header, List_Rows; filter switches in a Grouped_List, „Zobrazit všechny typy“ Tonal_Button, „Hotovo“ Primary_Button; repeating-event delete choices as List_Rows in `destructiveText`; single delete via `confirmDestructive`
    - _Requirements: 14.1, 14.2, 14.3, 14.4, 14.5, 14.6, 14.7, 6.1, 6.3_

  - [ ]* 5.5 Update the Calendar module tests
    - Existing tests in `test/calendar/ui/` and `test/e2e/calendar_e2e_test.dart` adapted; today marker; chip style for every type; day sheet opens on tap as before
    - _Requirements: 12.5, 12.6, 13.1, 24.4_

  - [ ] 5.6 Verify the Calendar module
    - Regenerate `calendar_*` goldens and review; run `test/a11y/`; real Linux app: month, day sheet, detail, form, search, filter, delete; light and dark; compare with `r2-calendar`, `r2-calendar-sheet` and the calendar rows of the „Ostatní obrazovky“ table
    - _Requirements: 24.1, 24.2, 24.4_

- [ ] 6. Checkpoint — Time, Quests and Calendar
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 7. Notes module
  - [ ] 7.1 Notes root and folder
    - `notes_screen.dart`, `breadcrumb.dart`, `folder_row.dart`, `note_row.dart`, `node_swipe_row.dart`, `widgets/node_tiles.dart`, `widgets/trash_button.dart`: renders `r3-notes` and `r3-folder` — root header with counts subtitle and trash Header_Action with badge; folder header back + name + left-ellipsized path subtitle + more action; no breadcrumb row and no Menu_Button below the header; „Složky“ and „Poznámky“ Grouped_Lists (40 px folder Icon_Tile radius 12, count value, chevron; note title 16/650, short date 13 `textFaint`, preview 14.5 `textDim`); shared `SwipeActions`; Module_Bar stays
    - _Requirements: 15.1, 15.2, 15.3, 15.4, 16.1, 16.2, 16.3, 16.4_

  - [ ] 7.2 Editor, sheets and trash
    - `note_editor_screen.dart`, `note_title_field.dart`: App_Header back (parent name or „Poznámky“) + more + „Hotovo“ text action; title in `displaySmall`; toolbar unchanged
    - `sheets/add_sheet.dart`, `move_sheet.dart`, `name_sheet.dart`, `link_sheet.dart`, `screens/notes/node_menu.dart`: App_Sheet header, List_Rows with Icon_Tiles
    - `trash_screen.dart`, `trash_row.dart`, `trash_preview_screen.dart`: header back + „Koš“ + count; `tone` info box radius 16; Grouped_List rows with Icon_Tile, name, „z <place> · <when>“ and Pill_Button „Obnovit“; Destructive_Button „Vysypat koš“ with `confirmDestructive`; delete forever confirmed the same way; preview screen with App_Header back + item name, restore as Primary_Button and delete forever as Destructive_Button
    - _Requirements: 17.1, 17.2, 17.3, 18.1, 18.2, 18.3, 18.4, 18.5, 6.1_

  - [ ]* 7.3 Update the Notes module tests
    - Existing tests in `test/notes/` and `test/e2e/notes_e2e_test.dart` adapted; folder header path; trash restore and empty
    - _Requirements: 15.4, 16.1, 18.4, 24.4_

  - [ ] 7.4 Verify the Notes module
    - Add or regenerate notes goldens; run `test/a11y/`; real Linux app: root, nested folder, editor, add sheet, trash; light and dark; compare with `r3-notes`, `r3-folder`
    - _Requirements: 24.1, 24.2, 24.4_

- [ ] 8. Settings
  - [ ] 8.1 Settings page and hero name sheet (approved behaviour change d)
    - `settings_screen.dart`, `export_row.dart`, `import_row.dart`, `rules_section.dart`, `time_settings_groups.dart`: render `r2-settings` — header, profile card (initial avatar, name, total XP, pencil Header_Action), groups „Vzhled a jazyk“ (language `AppSegmented` CZ/EN with full-name semantics, appearance icon-only `AppSegmented`), „Plánování“ (recurring missions with active count, reminders, testing — the Time module rows come through the module group slot as List_Rows), „Zařízení a data“ (shortcut, export, import), „Experimenty“ (spec 005), „O aplikaci“ (licences, version)
    - New `settings/ui/hero_name_sheet.dart`: App_Sheet „Jméno hrdiny“ with the name field, counter „<n> / 40“ and Primary_Button „Uložit“ through `SettingsService.setHeroName`; remove the inline name field
    - `import_row.dart`: replace-data confirmation through `confirmDestructive` with the summary lines in the body; the result dialog becomes an App_Sheet „Import hotov“ with the existing texts and Primary_Button „Zavřít“ (`common_close`)
    - _Requirements: 1.2, 6.1, 20.1, 20.2, 20.3, 20.4, 20.5, 20.6, 20.7, 20.8, 20.9, 20.10, 20.11_

  - [ ] 8.2 Reminders list (approved behaviour change b)
    - New `widgets/reminders/reminder_row.dart` (`ReminderRow`), delete `reminder_card.dart`; `reminder_settings_screen.dart`: render `r3-reminders` — header back + title + plus action, one Grouped_List, Check_Circle for today's completion, name 16.5/600, `time_reminderWindow`, days 13 `textFaint`, active switch, inactive rows at 50 %, tap opens the Reminder_Sheet, delete via `SwipeActions` + `confirmDestructive(time_reminderDeleteTitle, time_reminderDeleteBody)`, hint `time_remindersHint`, no icon buttons
    - `reminder_action_screen.dart`: App_Header close, name in `displayMedium` with window and interval, „Hotovo“ `AppButton.primary`, „Odložit“ `AppButton.tonal`, behaviour unchanged
    - _Requirements: 1.2, 21.1, 21.2, 21.3, 21.4, 21.5, 21.6, 21.7, 21.8, 6.1_

  - [ ] 8.3 Reminder sheet (approved behaviour change c)
    - New `widgets/reminders/reminder_sheet.dart` (`ReminderSheet`, `showReminderSheet`), delete `reminder_edit_dialog.dart`; reuse `reminder_form_data.dart`: render `r3-reminderadd` — name field with counter, from/to fields side by side, midnight note in `brassText`, interval `AppSegmented` with „minut“, seven 40 px day circles, „Aktivní“ card row with switch, Primary_Button „Uložit“; dirty state drives the discard question
    - _Requirements: 1.2, 22.1, 22.2, 22.3, 22.4, 22.5, 22.6, 22.7_

  - [ ]* 8.4 Tests for the settings behaviour changes
    - `test/settings/ui/hero_name_sheet_test.dart` (counter, save, discard); `test/time_tracking/ui/screens/reminder_settings_screen_test.dart` (tap opens the sheet, swipe delete confirms, completion circle toggles, inactive opacity); `reminder_sheet_test.dart` (validation, overnight note, discard question)
    - _Requirements: 20.3, 21.4, 21.5, 22.7_

  - [ ] 8.5 Other settings pages
    - `rules_screen.dart`, `rule_row.dart`: Grouped_List rows with `repeat` Icon_Tile, summary subtitle, Pill_Button „Vyvěsit hned“ with `confirmAction`, Add_Row „Přidat pravidelnou misi“
    - `shortcut_screen.dart`, `shortcut_guide.dart`: full title, target screens as Grouped_Lists per Module with a check mark on the chosen one, link field and numbered steps kept
    - Testing page (in `time_settings_groups.dart`) and licences page: App_Header back, List_Rows in Grouped_Lists
    - _Requirements: 23.1, 23.2, 23.3, 23.4, 6.2_

  - [ ] 8.6 Verify Settings
    - Regenerate `settings_*` goldens and add Reminders goldens; run `test/a11y/`; real Linux app: Settings top and bottom, name sheet, reminders, reminder sheet, recurring missions, shortcut; light and dark; compare with `r2-settings`, `r3-reminders`, `r3-reminderadd`
    - _Requirements: 24.1, 24.2, 24.4_

- [ ] 9. Shared leftovers and clean-up
  - [ ] 9.1 Empty states, splash, banner, skeletons
    - Every empty list of the five modules through `EmptyState` with its existing texts (the Quest board's blank slip retired); `splash_screen.dart` and `reconcile_banner.dart` on the new roles with a Pill_Button retry; skeletons with `tone` and `Radii.card`
    - _Requirements: 19.1, 19.2, 19.3_

  - [ ] 9.2 Remove what no screen uses
    - Empty the allowlist of `test/theme/design_rules_test.dart` (spec 004 task 7.4); the test must pass with no entries
    - Delete `ScreenHeader`, `SubPageHeader`, `SettingsNavRow`, `BlankSlip` and any widget replaced above; grep that no screen of this spec uses `AlertDialog`, `showDialog` for a form, `Icons.` or a text-link back
    - Remove unused ARB keys from both files; update `.agents/REFACTOR.md` (delete the lines this spec finished: icon-font icons, literal `Colors.red`, any literals removed)
    - _Requirements: 1.5, 24.3_

  - [ ] 9.3 Documentation
    - Update `README.md` screenshots (`screenshots/`), `FEATURES.md` (navigation by modules, the four behaviour changes), `DOCS.md` (design system and where the Visual_Reference lives) and the Status of `CLAUDE.md`
    - _Requirements: 1.1_

- [ ] 10. Checkpoint — spec complete
  - Ensure `scripts/check.sh` passes and every module was compared on the real app, ask the user if questions arise.

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP; the tests of the four behaviour changes (2.4, 8.4) are strongly recommended.
- Do not change behaviour beyond Requirement 1.2. If a screen seems to need a functional change to match a mockup, keep the behaviour and note the difference for Martin instead.
- The mission ring keeps the number of remaining quests inside; only the arc around it is new (Martin's explicit wish).
- Calendar: keep the big cells with event names and the Day_Sheet; never replace names with dots and never add an inline day panel (both were rejected).
- The Quest board keeps the swipe hint (round 2 mockup omits it; the requirement wins).
- Mockup texts are Czech; use the existing ARB keys for both languages and add only the keys of the table in `design.md`.
- `time_tracking/` imports only itself, `core/`, `theme/`, `ui_kit/`, `l10n/` and `database/`; the QuestLog modules never import `time_tracking/` or `shell/` (`test/architecture/feature_imports_test.dart`).
- No literal colours, spacing or durations in `lib/` outside `time_tracking/`, and no new ones inside it; no icon-font icons; tokens go to `lib/theme/tokens.dart`.
- Riverpod 3: never change a provider while a widget builds; the TimeLog code still uses `flutter_riverpod/legacy.dart` — keep it, the conversion is not part of this spec.
- Widget tests that mount the Shell need `test/flutter_test_config.dart`; a query started while a widget mounts cannot finish in the fake-async zone.
- Never `pkill -f`; never `dart format` a whole file that is not already formatted.
- Commit per module (or per task when large) as a Conventional Commit with the author `Martin Jablečník <martin.jablecnik@email.cz>` and no tool-attribution trailers; never push.
