# Redesign QA: implementation vs specs 004–006

Review date: 2026-11-22. Reviewed build: commit `6be91c6` ("feat: redesign DayLog around module navigation").
Screenshots: `.screenshots-qa/run-2026-11-22-redesign/` (74 screens × light/dark, English UI, 390×844 pt @2x).
Reference: specs `004-design-system`, `005-module-navigation`, `006-screen-redesign` and the renders in
`.design/redesign-preview/renders/` (precedence per that folder's `README.md`: spec values > round 3 renders >
round 2 renders).

Each finding was checked against the code where the screenshot alone was not conclusive; file references point at
the cause. Mockups are in Czech, the screenshots in English: texts were compared through the ARB files.

**Severity**

- **SPEC**: contradicts an acceptance criterion (named).
- **MOCKUP**: the spec is silent, the agreed render differs.
- **MINOR**: small polish or consistency issue.

**How to use this list**: fix section A first. Each item there is one change in a shared widget or asset that fixes
several screens at once. Then work through section B by module. Section C needs Martin's decision before anyone
changes it. After fixing, re-take the affected screenshots and compare them with the render named in each item
(006 R24.2).

---

## A. Systemic issues (fix once, many screens)

### A1. Segmented control grows to the height of its parent — SPEC (004 R10)

- Seen in: 12/25 Statistics (the Day/Week control fills the whole 64 pt header and touches the top edge), 08
  Settings (Language/Appearance rows much taller than the other rows, Appearance taller still), 16/20 entry sheet
  subtype panel, 30 quest sheet Board, 41/91 reward segments, 93 interval.
- Cause: `lib/ui_kit/common/app_segmented.dart` ~L133–145. Each segment is an `AnimatedContainer(minHeight: 44)`
  whose child is a `Center`. A `Center` without `heightFactor` expands to the full height its parent allows: the
  header's 64 pt, or the row height.
- Fix: `Center(heightFactor: 1, …)` or a min-size column. Keep the 44 pt hit area, but draw the selected segment
  compact (render `r2-settings`/`r2-stats`: track ≈ 36–40 pt). Every row of a Settings group should then have the same
  height as in `r2-settings`.

### A2. Icon set uses mixed grids and stroke widths — SPEC (004 R16.1 "24 × 24 grid … like the existing icons")

- Seen in: 01/13 the timer stepper "+" is much bolder than "−". 11/12/24 the "<" chevron is larger and heavier than
  ">". 03/16/20/… the close "×" and the history "+" header action look black and heavy, unlike the thin icons in
  every render.
- Cause, in `assets/icons/`:
  - `plus.svg`: viewBox 14, stroke 2 (≈ 3.4 px at 24)
  - `close.svg`: viewBox 12, stroke 2 (≈ 4 px)
  - `chevron_left.svg`: 12×20, stroke 2.2; `chevron_right.svg`: 8×14, stroke 1.8 (not mirrors of each other)
  - `search`/`filter`/`trash`/`repeat`: 20 grid
  - `minus`/`arrow_left`/`refresh`: 24 grid, stroke 1.8
- Fix: redraw at least `plus`, `close`, `chevron_left`, `chevron_right` on the 24 grid with stroke 1.8 (chevrons as
  exact mirrors). Audit the rest so that the visual stroke is equal at the rendered size. Check the result in the
  stepper, the header actions and every sheet close button.

### A3. Count headers are upper-cased — SPEC (004 R5.10, 006 R7.3, R8.1, R9.4)

- Seen in: 04/32/33 Board ("TODAY 3", "TODO 2", "DONE TODAY 1", pill "1 QUEST · 10 XP"), 05 Missions
  ("IN PROGRESS 2"), 40/44/46 Mission detail ("REMAINING", "DONE", "1 QUEST · 25 XP").
- Spec: the Count_Header title is in the group header role (17/700, normal case). The renders show "Dnes 3",
  "Rozpracované 2", "Zbývá … 1 quest · 25 XP".
- Cause: `.toUpperCase()` in `lib/quests/ui/board/section_header.dart:39` and `:52`,
  `lib/quests/ui/missions/missions_screen.dart:370`, `lib/quests/ui/mission_detail/detail_sections.dart:28` and
  `:30`.
- Fix: remove these. Caps belong only to the Section_Label.

### A4. Add_Row looks like an ordinary row with an icon tile — SPEC (004 R5.8)

- Seen in: 40/44 mission detail, 41 mission sheet, 81 recurring missions, 91 rule sheet.
- Cause: `AddRow` in `lib/ui_kit/layout/grouped_list.dart:187–200` is a `ListRow` with `IconTile(IconAsset.plus)` and
  the label in `text`.
- Spec and `r3-mission`: a bare 20 pt plus icon, then the label in 15.5/650, both `brassText`.
- Fix: one change in `AddRow`. It must also be the last row of its Grouped_List; see B-Q6 and B-Q10.

### A5. Text fields still use the old QuestLog/TimeLog field styles — SPEC (004 R11, 006 R5.4, R10, R14.4, R22.2)

The Form_Field is: `card` fill, hairline `boardLine` border, radius 14, label above the value inside the box, 2 pt
`brass` border on focus, and any counter inside at the bottom right. Places that do not match:

| Screen | What is wrong | Where |
|---|---|---|
| 16/20 entry sheet, project | Box inside a box: an old `Container` (panel fill, radius 12 literal, border, padding 12/4, `TextStyle(fontSize: 15)`) wraps a `TextField` that also gets the theme decoration | `lib/time_tracking/ui/widgets/activity_picker/suggestion_field.dart:52–75` |
| 16/20/21 entry sheet, description | Counter `0/500` is drawn under the field (Material counter) | `description_sheet.dart:232`, `manual_entry_sheet.dart`, `edit_sheet.dart` |
| 30/31/34/43 quest sheet, name and note | Own `InputDecoration` with `palette.field`/`fieldActive` tinted fill, thin border, no border when unfocused | `lib/quests/ui/sheets/quest_sheet.dart:529–535` |
| 41/91 mission and rule sheets | Name and quest rows: grey fill, no border | `mission_sheet.dart`, `rule_sheet.dart` |
| 56/59 event form | Title, details, date and time fields: grey fill, no border (date/time should be `FormFieldBox`) | `lib/calendar/ui/screens/event_form_screen.dart` |
| 53 event search | Tinted fill | `event_search_screen.dart` |
| 80 hero name sheet | Material outlined floating label notched into the border; counter `6 / 40` under the box | `settings_screen.dart` (hero name sheet) |
| 93/94 reminder sheet | Name counter `0 / 100` under the box (render `r3-reminderadd`: inside on the right) | reminder sheet |

### A6. Custom chips instead of the shared Choice_Chip — SPEC (004 R9.1–R9.5)

- `lib/ui_kit/controls/choice_chip.dart` matches the spec: card fill, radius 12; when selected, the chip's own colour
  at 20 %, its border at 50 % and the label colour mixed into `text`.
- These screens use their own chips instead:
  - 56/59 event type picker: tone fill; selected = thick 2 pt brass outline, label stays `text`. R9.5 forbids the
    thick outline, and the type colour must tint the selected chip. In `event_form_screen.dart`.
  - 91 rule sheet repeat chips: `_CadenceChip` (`rule_sheet.dart:607`), tone fill, pill radius.
  - 30 quest sheet: `_PickChip` (`quest_sheet.dart:674`), pill radius.
- Fix: use `AppChoiceChip` everywhere (006 R1.3).

### A7. Previous/next buttons are not the tonal 38–40 pt squares — SPEC (006 R3.3, R12.2)

- 11/12/24/25 Day_Navigator (`lib/time_tracking/ui/widgets/controls/day_navigator.dart:105`): Material `IconButton`,
  which is a circle. When disabled (next on today) the tone fill disappears completely.
  - Renders `r3-history`/`r2-stats`: rounded square (radius ≈ 12), 40 pt. A disabled button keeps a faint tonal
    square.
- 06/55 calendar (`calendar_screen.dart:141–152`, `_IconTap`): bare chevrons without any fill. Spec: 38 pt tonal
  buttons.

### A8. A non-dismissible sheet still draws a disabled close button — SPEC/MOCKUP (004 R7, `r3-logsheet`)

- 16 timer finish sheet: `dismissible: false` → `AppSheet` passes `onCancel: null`
  (`lib/ui_kit/sheet/app_sheet.dart` ~L251 and L394). A disabled "×" without tone fill appears next to the tonal
  refresh button.
- Fix: do not render the close action when the sheet is not dismissible. The render shows only the refresh action.

### A9. Separate cards where a Grouped_List is required — SPEC (004 R5.11)

- 40/44/46 mission detail: every done quest is its own card with a gap; the remaining quest and the add row are two
  cards. 006 R9.4/R9.5: one Grouped_List per section, with the Add_Row as the last row of "Zbývá".
- 73 notes "Add" sheet: the two options are separate tone cards. 006 R17.3 requires List_Rows. The mission and event
  menus (42, 58) already use a Grouped_List.

### A10. The Board list does not clip rows while swiping — SPEC (004 R5.1)

- 32: the swiped row slides out of the card. Its text ("…il klientovi") is visible left of the card edge at screen
  x = 0, and the row loses the card's rounded shape. History (22) and Reminders (95) clip correctly.
- Wrap the board's sections in the clipping Grouped_List, or clip the swipe row.

### A11. Destructive menu rows keep the accent icon tile — MINOR

- 42 "Delete mission", 58 "Delete": the label is `destructiveText`, but the Icon_Tile is still teal. Tint the tile
  (destructive soft fill + destructive icon) so the row reads as one.

---

## B. Per-screen findings

### Time module

- **B-T1 Timer, captions** (01) — MINOR. The captions "Log"/"Finish" use `bodySmall` (12.5/400 + w600) in `text`
  colour at 50 %. They read darker than in `r2-timer`, where they are faint. The size matches. Use `textDim` before
  the 50 % opacity. (`timer_controls.dart:163–170`)
- **B-T2 Timer, stepper buttons** (01) — SPEC 006 R2.5. Material `IconButton` (40 pt visual) with an 18 pt icon.
  Spec: 44 pt round buttons. Together with A2, "+" and "−" then look the same.
  (`duration_adjuster.dart:32–46`)
- **B-T3 Statistics, share bar placement** (12/25) — MOCKUP `r2-stats`. The share bar sits outside the timeline card;
  the render has the share bar and the timeline in one card. (`statistics_screen.dart:367–389`)
- **B-T4 Statistics, activity rows** (12/25) — SPEC 006 R3.8. Still the old TimeLog style: name 14/500 without a
  colour dot, duration 12 `dim`, subtypes 12 px with dots, literal sizes. Spec: colour dot, name 650, duration and
  share right-aligned (duration bold as in the render), 8 pt bar, subtypes indented in 14 `textDim`.
  (`_ActivityTypeBar`, `statistics_screen.dart:446–570`)
- **B-T5 Statistics week, label alignment** (25) — MINOR. The last day label ("Su") sits lower than its track,
  because it is aligned with the track plus the hour-label block.
- **B-T6 History, summary pill and date** (11) — MINOR. The count pill text is `textDim`; in `r3-history` it is
  `text`. The date line adds the year ("…, 2026"), which the render does not show.
- **B-T7 Entry sheet, skip button** (16) — SPEC 006 R5.5. "Skip" is a default `TextButton` in brass; spec `textDim`.
  (`description_sheet.dart:216–220`)
- **B-T8 Reset confirm and every confirm dialog** (15/23/35/60/90) — MOCKUP `r3-dialog`. Icon, title and body are
  centred (`confirm_destructive.dart:137`, `:144`); the render aligns them left. Also slightly less space between body
  and buttons than in the render.

### Quests module

- **B-Q1 Board subtitle** (04) — SPEC 006 R7.1. "5 open · Sunday, November 22" (`board_subtitle`). Spec and render:
  the date only.
- **B-Q2 Level card XP line** (04/05) — SPEC 006 R7.2. "30 / 250 XP · 220 XP to level 5" (`hero_xpRemaining` =
  "{xp} XP do úrovně {level}"). Spec: "<xp> / <threshold> XP · ještě <rest>". In the render the current XP is bold.
  (`lib/quests/ui/hero/level_card.dart:80–81`, ARB both languages)
- **B-Q3 Calendar quest row icon** (04) — MOCKUP `r2-quests`. An extra calendar icon before the XP pill. The meta
  line already shows the event dot, type and time (006 R7.4).
- **B-Q4 Swipe hint position** (33) — MINOR. With a "Done today" section the hint sits between Todo and Done; it
  belongs under all lists (006 R7.7).
- **B-Q5 Missions bonus pill** (05) — SPEC 006 R8.4. Drawn as a two-line box "+200 / ON COMPLETION" (caption 10 px,
  caps). Spec: one `brassSoft` pill "+200 XP". (`lib/quests/ui/cards/mission_card.dart:117–150`)
- **B-Q6 Mission detail header** (40) — SPEC 006 R9.2. An extra caps kicker "MISSION" above the name
  (`mission_header.dart:48`). Spec: the name in the detail title role, then the progress text.
- **B-Q7 Mission detail progress card** (40/44) — SPEC 006 R9.3. The "Postup" label and the pill
  "+<bonus> XP za dokončení" are missing; a brass sentence "+200 XP for completing the mission" is shown instead.
  After completion (46) the card is an empty box with only a bar in it.
- **B-Q8 Mission detail XP values** (40/44/46) — MOCKUP `r3-mission`. XP is plain brass text "+25"; the render uses
  `brassSoft` pills as on the Board.
- **B-Q9 Mission detail shadow** (42) — MINOR. The remaining-quest card has a drop shadow; no other list card does.
- **B-Q10 Mission and rule sheets** (41/91) — SPEC 006 R10.5/R10.6. The quests of the mission must be rows with an
  Add_Row in one group; see A4/A5. In the rule sheet, "Always post on" is a tone box with a brass value; spec: a
  List_Row with a chevron.
- **B-Q11 Quest sheet effort cards** (30/31/34/43) — SPEC 006 R10.2. The unselected cards have a tone fill without a
  border (render: card plus hairline border). "+XP" sits top right in `text` at regular weight (spec 14/750
  `brassText`; render: bottom left with the pips at the right). The selected border is about 1 pt (spec 2 pt `brass`
  plus an 8 % tint). (`lib/quests/ui/widgets/effort_picker.dart`)
- **B-Q12 Reward overlay in the dark theme** (45) — SPEC 006 R11.2. The card is light (#EEF2F7) on the dark screen.
  Cause: `reward_card.dart:91` `Material(color: p.parchment, side: p.parchmentEdge)`; `parchment` is light in both
  palettes, and the comment in `tokens.dart` says widgets must not read it. Use `p.card`/`p.sheet`.
- **B-Q13 Shared widgets bypassed** — MINOR/code, 004 R13.5. `lib/quests/ui/cards/check_circle.dart` and
  `difficulty_pips.dart` are still re-export shims imported by the mission detail, the sheets, the effort picker and
  `calendar/ui/widgets/event_task_card.dart`. Import `ui_kit/controls/` directly and delete the shims.

### Calendar module

- **B-C1 Navigation row** (06/50/55) — SPEC 006 R12.2. Besides A7: the "Today" chip uses `Radii.pill` (spec radius
  12) and `labelLarge` 15/600 (spec 14/700). It also sits right after the chevrons on the left; spec and render put
  it at the right end of the row. (`calendar_screen.dart:87–157`)
- **B-C2 Day numbers** (06) — SPEC 006 R12.5. `fontSize: 11` (`month_grid.dart:285`); spec 13/600. The numbers are
  left-aligned in the cell; the render centres them.
- **B-C3 Weekday names** (06) — SPEC 006 R12.3. 10.5 with letter spacing 0.5 (`calendar_screen.dart` ~L225); spec
  11.5/700. The "+N" label is 9.5 px — MINOR.
- **B-C4 Tapped day highlight** (50) — SPEC 006 R13.1. While the day sheet is open, the tapped cell does not get the
  `brassSoft` fill. `month_grid.dart` only calls `selectedDayProvider…select` (L321) and never paints the selection.
- **B-C5 Event detail type label** (51/58/61/62) — SPEC 006 R14.2, 004 R9.6. A saturated solid event colour with dark
  text and a black dot. It must be a Type_Tag: colour at 20 % over card, label in the colour mixed 45 % into `text`
  (`TypeTag` exists in `choice_chip.dart`).
- **B-C6 Event detail rows** (51) — SPEC 006 R14.2. Details, Repeat and Address are bare icon-plus-text rows. Spec:
  List_Rows with Icon_Tiles in a Grouped_List with dividers.
- **B-C7 Event form Save** (56) — MINOR 006 R14.3. While disabled, the header Save is a grey tonal pill instead of a
  small Primary_Button at 45 %.
- **B-C8 Event search** (53) — MINOR 006 R14.5. The search field sits below the header; spec: in the header.
- **B-C9 Repeating-event delete sheet** (62) — SPEC 004 R7.2. An extra text button "Cancel" under the options; the
  close "×" already does that.
- **B-C10 Event menu** (58) — MINOR. "Duplicate" uses the plus icon (there is no copy icon); see also A11.

### Notes module

- **B-N1 Folder rows** (07/73) — SPEC 006 R15.2. The note count is a subtitle ("1 note"); spec and `r3-notes`: a
  right-aligned value. (`lib/notes/ui/screens/notes/folder_row.dart:33`)
- **B-N2 Note rows** (07/70) — SPEC 006 R15.3. A generic `ListRow` with a leading `IconTile(note)`
  (`note_row.dart:35`). The date is a vertically centred value at 14.5 `textDim`. Spec and render: no icon, title
  16/650, the short date 13 `textFaint` right-aligned on the title line, the preview 14.5 `textDim` under it.
- **B-N3 Folder section label** (70) — MINOR. "NOTES" without a count; the render has "POZNÁMKY · 1".

### Settings

- **B-S1 About group** (09/10) — SPEC 006 R20.8. "Licenses" is a brass text link, and "DayLog  version …" is bare
  text outside any card (`settings_screen.dart:223–320`). Spec: a Grouped_List with a List_Row "Licence" plus
  chevron, and the version as a List_Row value.
- **B-S2 Licences page** (85) — SPEC 006 R23.4. Flutter's stock `showLicensePage` (old app bar, plain list). Spec:
  App_Header with the back element, content as List_Rows in Grouped_Lists.
- **B-S3 Recurring missions header** (81/90) — MINOR. The caps group header "RECURRING MISSIONS · 1 ACTIVE" repeats
  the page title (`rules_section.dart:73`, `:79`).
- **B-S4 Reminder sheet "Active"** (93/94) — SPEC 006 R22.6. A bare row; spec and `r3-reminderadd`: a card row with
  the switch. The unit "minutes" is left-aligned (render: right-aligned under the control) — MINOR.
- **B-S5 Reminder days text** (82) — MINOR. The English UI lists every day ("Mo, Tu, We, Th, Fr"); the render shows
  ranges ("Po–Pá", "Každý den"). Check what the Czech UI shows; ranges read better.

### Navigation (spec 005)

- **B-M1 Drawer, current module** (02) — MOCKUP `r2-nav1-timer-drawer`. The current module's name stays in `text`;
  the render draws it in `brassText`. The rows are also denser than in the render (row pitch ≈ 97 vs 120 px), and the
  title sits higher. Spec R6.1–6.4 is met otherwise.
- **B-M2 Quests module icon** (02/03/04) — MOCKUP. The module button, launcher tile, drawer and tab use a
  receipt-like glyph (`quests.svg`, 26 grid); every round 2 render shows a clipboard with a checklist.

---

## C. Needs Martin's decision

1. **Back/close leading button**: the code draws it as a tonal 44 pt square, the same as the trailing Header_Actions
   (`app_header.dart`). The renders `r3-mission`, `r3-folder` and `r3-reminders` draw a bare arrow. Spec 004 R3.3
   says only "arrow icon in a 44 × 44 hit area". Recommendation: the bare arrow from the mockups, so that the leading
   element stays visually lighter than the actions.
2. **Board subtitle "N open"** (B-Q1): the spec says date only. If Martin likes the open count there, update spec
   R7.1 instead of the code.
3. **Calendar icon on calendar quests** (B-Q3): remove it (mockup), or keep it as an extra cue?

---

## D. Checked and matching

- Timer: ring 290/8 pt, arc and glow (light softer than dark), 80 pt tabular digits, no phase label, 84 pt primary
  with glow, 58 pt secondaries with outline and 50 % when unavailable, running state, ringing overlay not exercised.
- Module bar: 50 pt brass button with glow in a 66 pt slot, hairline separator, tabs without a pill indicator,
  single-page modules (Calendar, Notes, Settings) with one narrow tab, right-side variant (86), drawer off (87/88),
  title weight 800 (89) applied immediately.
- Module launcher: 2×2 tiles with the selected border and tint, Settings row, hint.
- Day sheet layout (`r2-calendar-sheet`), calendar event chips (11/650, radius 5, 26 % / 40 %), outside-month tone
  fill, the today circle, the grid clearing the add button.
- History rows, Type_Tags, swipe actions (edit + delete, 84 pt, clipped), hint, delete confirm.
- Choice_Chips in the entry sheet, the subtype panel, Primary_Button (54 pt, glow, 45 % disabled), the destructive
  and action variants of Confirm_Dialog, the scrim covering the module bar in every dialog.
- Notes root header with the trash badge, folder header with the path subtitle, note editor, trash (retention box,
  Pill_Button "Restore", destructive "Empty Trash").
- Settings: profile card, groups and their order, Icon_Tiles, Experiments group (all three controls), Testing page,
  Home Screen shortcut page, recurring reminders list (`r3-reminders`), reminder action screen (96).

## E. Notes on this review

- Screenshots `09-settings-scrolled` and `10-settings-bottom` are identical; the bottom of Settings is covered by
  both.
- Reviewed screen by screen against renders and code: 01–08, 11–16, 20–25, 30–35, 40–46, 50, 51, 53, 54, 56,
  58–60, 62, 70, 71, 73, 74, 80–91, 93, 95, 96. The remaining screens (26, 27, 52, 55, 57, 61, 72, 92, 94, 97,
  90b) are variants of the reviewed ones and were not reviewed one by one.
- Not about looks, but worth knowing: none of the 117 tasks in `.kiro/specs/004–006/tasks.md` are ticked, and the
  whole redesign is one commit of 214 files, against the "one commit per task" rule in `CLAUDE.md`.

---

## F. Resolution (2026-11-22)

Every item of sections A and B is fixed in the working tree (not committed yet). Section C was decided in favour of the
mockups: the Back/Close element is a bare 44 pt arrow (`HeaderBareAction`), the Board subtitle is the date only (the
`board_subtitle` string is now unused) and the calendar icon on calendar quests is gone.

Notes on how some items were solved:

- A1: `AppSegmented` keeps a 44 pt hit area per segment but draws the track at 44 pt and the selected segment at 38 pt
  inside it, and no longer grows to the height of its parent.
- A5: one `AppTextField` (`lib/ui_kit/forms/app_text_field.dart`) is the Form_Field for typed text; `CalendarTextField`
  is a typedef of it. The counter is drawn inside the box.
- A7: `StepButton` (`lib/ui_kit/controls/step_button.dart`) is the 40/38 pt tonal square with a 44 pt hit area.
- B-Q13: only the `check_circle` shim was removed; `difficulty_pips.dart` maps a Difficulty to `EffortPips` and keeps
  its own semantics, so it stays.
- B-S2: `LicensesScreen` replaces Flutter's `showLicensePage`.
- Not done: B-C10 (no copy icon exists, "Duplicate" keeps the plus icon).

Re-checked in the running Linux app against the renders: Timer, Board, Missions, Mission detail and menu, Statistics,
Calendar and day sheet, event detail and form, Notes and add sheet, Settings, recurring missions and reminders sheets.
