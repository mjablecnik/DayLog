# Requirements Document

## Introduction

DayLog was assembled from two apps, and their two visual languages are still visible side by side: the TimeLog screens
use grey outlined cards with an edit and a delete icon in every card and forms in centred dialogs, while the QuestLog
screens use white cards, bottom sheets and large primary buttons. Martin reviewed three rounds of mockups on
2026-11-21 and agreed on one visual language. This spec builds that language as a design system: palette roles,
typography, glow and the shared widgets in `lib/theme/` and `lib/ui_kit/`. It changes no behaviour and no screen layout
by itself; spec `005-module-navigation` builds the new navigation on it and spec `006-screen-redesign` moves every
screen onto it.

The visual reference is `.design/redesign-preview/` (read its `README.md` first). The rules of the design system are
the twelve consistency rules of round 3 (`.design/redesign-preview/index.html`, section "Pravidla konzistence"); each
of them is a requirement below. Exact values (sizes, weights, alphas) are given in the acceptance criteria and in the
token tables of `design.md`; where a mockup and a value here differ, the value here wins.

The blue theme stays the base: no existing colour of `AppPalette.daylight` or `AppPalette.guildBoard` changes. New
roles are added beside them. The project location is `/workspace/DayLog` (Flutter, Riverpod 3).

## Glossary

- **App**: The DayLog Flutter app at `/workspace/DayLog`.
- **App_Palette**: The class `AppPalette` in `lib/theme/tokens.dart`, one instance per theme brightness (`daylight`, `guildBoard`).
- **Typography**: The display and body text themes built in `lib/theme/typography.dart` and exposed as `context.displayText` and `context.bodyText`.
- **Title_Weight**: The font weight of page and sheet titles, one of 500, 600, 700, 800; 600 by default.
- **Glow**: The soft brass light around the timer ring, the primary round buttons, the add button and the Primary_Button.
- **App_Header**: The shared header row of every screen in `lib/ui_kit/common/app_header.dart`.
- **Header_Action**: A tonal square icon button used in the trailing part of an App_Header and as the close button of an App_Sheet.
- **Menu_Button**: The existing leading button that opens the drawer (`lib/ui_kit/common/menu_button.dart`).
- **Grouped_List**: A card that holds several rows of the same kind separated by hairline dividers (`lib/ui_kit/common/grouped_list.dart`).
- **List_Row**: One row of a Grouped_List with an optional Icon_Tile, a title, an optional subtitle, an optional trailing value and an optional chevron.
- **Icon_Tile**: A small rounded square with the accent-soft fill and an accent icon, at the start of a List_Row.
- **Add_Row**: The last row of a Grouped_List that adds an item: a plus icon and a label in the accent colour.
- **Section_Label**: The caps label above a group (for example `SLOŽKY`).
- **Count_Header**: A group header with a title, a faint count and an optional trailing pill (for example `Dnes 3 … +60 XP`).
- **Swipe_Actions**: The shared row wrapper that reveals actions when a row is dragged to the left (`lib/ui_kit/common/swipe_actions.dart`).
- **App_Sheet**: The shared bottom sheet scaffold in `lib/ui_kit/sheet/app_sheet.dart`.
- **Confirm_Dialog**: The shared confirmation dialog in `lib/ui_kit/sheet/confirm_destructive.dart`.
- **Choice_Chip**: A selectable rounded label, optionally with a colour dot (`lib/ui_kit/common/choice_chip.dart`).
- **Type_Tag**: A small non-interactive tinted label that names an activity or event type.
- **Segmented_Control**: The existing `AppSegmented` widget in `lib/ui_kit/common/app_segmented.dart`.
- **Form_Field**: The shared look of a text or value field (`lib/ui_kit/forms/form_field_box.dart` plus the input decoration theme).
- **Primary_Button**, **Tonal_Button**, **Destructive_Button**, **Pill_Button**: The shared buttons in `lib/ui_kit/common/app_buttons.dart`.
- **Check_Circle**: The round "mark as done" control, open or filled (`lib/ui_kit/common/check_circle.dart`).
- **Effort_Pips**: The four short bars that show the effort of a Quest (`lib/ui_kit/common/effort_pips.dart`).
- **Empty_State**: The shared empty-state widget in `lib/ui_kit/common/empty_state.dart`.
- **Icon_Set**: The bundled SVG icons in `assets/icons/` listed in `IconAsset` (`lib/ui_kit/common/app_icon.dart`).
- **Guard_Tests**: The existing tests that forbid literal colours, spacing and durations, `DateTime.now` and icon-font icons outside the allowed places (`test/theme/token_usage_test.dart`, `test/core/clock_usage_test.dart`, `test/assets_test.dart`).
- **Visual_Reference**: The folder `.design/redesign-preview/` with its pages and the PNG renders in `renders/light/` and `renders/dark/`.
- **Event_Type**: A calendar event type with its fixed colour (`lib/core/event_type.dart`, `eventColor` in `lib/theme/tokens.dart`).
- **Event_Chip**: The small coloured label of an event in a calendar cell (`lib/calendar/ui/widgets/event_chip.dart`), restyled in spec `006-screen-redesign`.
- **Structure_Check**: `scripts/check-structure.sh`, which fails when a directory holds more than 15 source files.
- **Drawer_Enabled**: The experiment switch of spec `005-module-navigation` that removes the drawer and the Menu_Button.

## Requirements

### Requirement 1: Palette roles

**User Story:** As Martin, I want the new surfaces, lines and glows to come from the theme, so that both themes look consistent and a later theme can redefine them.

#### Acceptance Criteria

1. THE App_Palette SHALL keep every existing colour value of `daylight` and `guildBoard` unchanged.
2. THE App_Palette SHALL provide a `tone` role: a neutral tinted fill of 5 % text colour in the light theme (`0x0D15202B`) and 6 % in the dark theme (`0x0FE6EAF2`).
3. THE App_Palette SHALL provide a `lineStrong` role: 13 % text colour in the light theme (`0x2115202B`) and 14 % in the dark theme (`0x24E6EAF2`), used for the timer ring track, empty Effort_Pips, open Check_Circles and secondary button outlines.
4. THE App_Palette SHALL provide a `card` role equal to `parchment` (`#FFFFFF`) in the light theme and to `boardRaised` (`#18202B`) in the dark theme, used as the fill of every card, Grouped_List and Form_Field.
5. THE App_Palette SHALL provide the Glow roles listed in the design token table: ring glow colour and blur, button glow colour, blur and vertical offset, each with a light and a dark value.
6. THE App SHALL read every colour of a new or changed widget from App_Palette roles, never from a literal colour.

### Requirement 2: Typography

**User Story:** As Martin, I want lighter and smaller titles, so that a heading no longer outweighs the content under it.

#### Acceptance Criteria

1. THE Typography SHALL set the page title role (`displayText.headlineLarge`) to 22 logical pixels at the Title_Weight.
2. THE Typography SHALL set the sheet title role (`displayText.headlineMedium`) to 22 logical pixels at the Title_Weight.
3. THE Typography SHALL provide a detail title role (`displayText.displayMedium`) of 28 logical pixels at weight 700 for the name of a Mission and the title of an event on their detail screens.
4. THE Typography SHALL provide a note title role (`displayText.displaySmall`) of 26 logical pixels at weight 600 for the title in the note editor.
5. THE Typography SHALL set the caps label role (`bodyText.labelSmall`) to 12 logical pixels, weight 700 and a letter spacing of 0.09 em.
6. THE Typography SHALL provide a group header role (`bodyText.titleLarge`) of 17 logical pixels at weight 700 for Count_Headers.
7. WHEN `buildTheme` receives a Title_Weight, THE Typography SHALL apply it to the page and sheet title roles and to no other role.
8. IF no Title_Weight is given, THEN THE Typography SHALL use weight 600.
9. THE Typography SHALL keep Figtree as the only family and keep the bundled weights 400 to 800.

### Requirement 3: App header

**User Story:** As Martin, I want every screen to start with the same header, so that I always find the title, the way back and the actions in the same place.

#### Acceptance Criteria

1. THE App_Header SHALL be 64 logical pixels high with 12 logical pixels of horizontal padding.
2. THE App_Header SHALL show one leading element: the Menu_Button, a back button, a close button or none.
3. THE App_Header back button SHALL draw a left arrow icon in a 44 × 44 hit area and pop the current route.
4. THE App_Header close button SHALL draw a cross icon in a 44 × 44 hit area and pop the current route.
5. THE App_Header SHALL show the title in the page title role, on one line, truncated with an ellipsis when it does not fit.
6. WHERE a subtitle is given, THE App_Header SHALL show it under the title in 12.5 logical pixels with the `textDim` colour.
7. THE App_Header SHALL show at most two trailing widgets, each a Header_Action or a Segmented_Control.
8. THE App_Header SHALL replace `ScreenHeader` and `SubPageHeader`; both SHALL be removed once no screen uses them.
9. THE App_Header SHALL mark the title as a semantics header.
10. THE App SHALL NOT use a text link (for example `‹ Mise`) or a breadcrumb row as a way back.

### Requirement 4: Header action

**User Story:** As Martin, I want header buttons that look like buttons, so that I see at a glance what can be tapped.

#### Acceptance Criteria

1. THE Header_Action SHALL be 44 × 44 logical pixels with a corner radius of 14 and the `tone` fill.
2. THE Header_Action SHALL draw its icon at 24 logical pixels in the `textDim` colour.
3. WHERE a badge count is given, THE Header_Action SHALL draw a pill of at least 18 × 18 logical pixels with the `brass` fill and the count in `inkOnBrass` at its top right corner.
4. THE Header_Action SHALL require a semantics label.

### Requirement 5: Grouped lists

**User Story:** As Martin, I want items of the same kind in one card with dividers, so that lists are calm, dense and look the same in every module.

#### Acceptance Criteria

1. THE Grouped_List SHALL draw one card with the `card` fill, a hairline `boardLine` border and a corner radius of 18, clipping its rows.
2. THE Grouped_List SHALL separate its rows with full-width hairline dividers in the `boardLine` colour.
3. THE List_Row SHALL be at least 56 logical pixels high with padding of 13 vertical and 16 horizontal logical pixels.
4. THE List_Row SHALL show the title in 16 logical pixels at weight 600 and the optional subtitle in 13.5 logical pixels with the `textDim` colour.
5. WHERE a trailing value is given, THE List_Row SHALL show it right-aligned in 14.5 logical pixels with the `textDim` colour.
6. WHERE the row opens another page, THE List_Row SHALL end with a 20 logical pixel chevron in the `textFaint` colour.
7. THE Icon_Tile SHALL be 34 × 34 logical pixels with a corner radius of 10, the `brassSoft` fill and a 19 logical pixel icon in the `brassText` colour.
8. THE Add_Row SHALL show a 20 logical pixel plus icon and its label in 15.5 logical pixels at weight 650 in the `brassText` colour.
9. THE Section_Label SHALL show its text upper-cased in the caps label role with the `textFaint` colour, 10 logical pixels above its group.
10. THE Count_Header SHALL show the title in the group header role, the count in the `textFaint` colour at weight 600 and an optional trailing pill.
11. THE App SHALL use a stand-alone card only for a summary (level, profile, number tiles); rows of the same kind SHALL be in a Grouped_List.
12. THE App SHALL NOT use a dashed outline box as a way to add an item; an Add_Row SHALL be used instead.

### Requirement 6: Swipe actions

**User Story:** As Martin, I want to edit or delete any item the same way, so that I do not have to look for small icons in every card.

#### Acceptance Criteria

1. THE Swipe_Actions SHALL reveal its actions when the row is dragged to the left.
2. THE Swipe_Actions SHALL draw an edit action with the `tone` fill and the `text` colour, and a delete action with the `destructive` fill and the `inkOnDestructive` colour.
3. THE Swipe_Actions SHALL give each action the width `Metrics.swipeAction`, an icon above a label, and the label in 13 logical pixels at weight 650.
4. WHILE one row of a group is open, THE Swipe_Actions SHALL close it when another row of the same group opens.
5. THE Swipe_Actions SHALL offer every action to assistive technology as a custom semantics action.
6. THE Swipe_Actions SHALL be importable by `lib/time_tracking/` (it lives in `lib/ui_kit/`).
7. THE existing swipe rows of Quests, Missions and Notes SHALL keep their behaviour and their action sets.

### Requirement 7: Sheets

**User Story:** As Martin, I want every sheet to look and close the same way, so that forms feel like one app.

#### Acceptance Criteria

1. THE App_Sheet SHALL show the grabber, then a header row with the title left-aligned in the sheet title role and a close Header_Action with a cross icon at the right.
2. THE App_Sheet SHALL NOT show a text "Zrušit" button and SHALL NOT centre the title.
3. WHERE a primary label is given, THE App_Sheet SHALL show a Primary_Button across the full width at the bottom of the sheet.
4. WHEN the close Header_Action is pressed, THE App_Sheet SHALL behave as the former "Zrušit" button: ask the discard question when the sheet is dirty and close straight away otherwise.
5. THE App_Sheet SHALL accept up to one extra Header_Action before the close button (the entry sheet uses it to clear the form).
6. THE App_Sheet SHALL keep every existing dismissal rule: drag down, scrim tap and back gesture ask first when dirty.
7. THE App SHALL show every form in an App_Sheet; a form SHALL NOT be shown in a centred dialog.

### Requirement 8: Confirm dialog

**User Story:** As Martin, I want one clear confirmation for every serious action, so that I never delete something by mistake.

#### Acceptance Criteria

1. THE Confirm_Dialog SHALL show a 48 logical pixel round icon badge, a title, a short body text (scrollable when it is longer than the screen allows) and two buttons, on the `sheet` fill with a corner radius of 26 and 26 logical pixels of side margin.
2. THE Confirm_Dialog SHALL show the cancel button as a Tonal_Button and the confirm button as a Destructive_Button for destructive actions.
3. WHERE the action is not destructive, THE Confirm_Dialog SHALL show the confirm button as a Primary_Button and the icon badge in the accent colours.
4. THE Confirm_Dialog SHALL place both buttons side by side at equal width and stack them vertically when the labels do not fit.
5. THE Confirm_Dialog SHALL keep the existing result contract: `true` only when the confirm button was pressed, `false` on cancel, scrim tap or back.
6. WHEN the destructive confirm button is pressed, THE Confirm_Dialog SHALL give the existing medium haptic tap.
7. THE App SHALL use a centred dialog only to confirm an action or to pick a date or a time (Requirement 11.6).

### Requirement 9: Chips and type tags

**User Story:** As Martin, I want selected options to be tinted rather than outlined, so that choices look light and the colour of a type is visible already when I pick it.

#### Acceptance Criteria

1. THE Choice_Chip SHALL have a corner radius of 12, padding of 8 vertical and 12 horizontal logical pixels, the `card` fill, a hairline `boardLine` border and its label in 15 logical pixels at weight 600.
2. WHERE a colour is given, THE Choice_Chip SHALL draw an 8 logical pixel dot of that colour before the label.
3. WHILE selected, THE Choice_Chip SHALL fill with its colour at 20 % over `card`, draw its border in its colour at 50 % and draw the label in its colour mixed 45 % into `text`.
4. IF no colour is given, THEN THE Choice_Chip SHALL use `brass` as its colour.
5. THE Choice_Chip SHALL NOT draw a thick outline in the selected state.
6. THE Type_Tag SHALL have a corner radius of 8, padding of 3 vertical and 8 horizontal logical pixels, its colour at 20 % over `card` as fill and its label in 12.5 logical pixels at weight 650 in its colour mixed 45 % into `text`.

### Requirement 10: Segmented control

**User Story:** As Martin, I want one-of-a-few choices to look the same everywhere, so that Den/Týden, Dnes/Todo and the theme switch read alike.

#### Acceptance Criteria

1. THE Segmented_Control SHALL draw a track with the `tone` fill, a corner radius of 12 and 3 logical pixels of padding.
2. THE Segmented_Control SHALL draw the selected segment with the `card` fill, a corner radius of 9 and, in the light theme only, the card shadow.
3. THE Segmented_Control SHALL draw the selected label in the `brassText` colour and the others in `textDim`, all at weight 600.
4. THE Segmented_Control SHALL NOT draw an outline around the selected segment.
5. THE Segmented_Control SHALL support segments with an icon only, each with a semantics label.

### Requirement 11: Form fields

**User Story:** As Martin, I want every field to look the same, so that forms in the timer, quests, calendar and settings feel like one app.

#### Acceptance Criteria

1. THE Form_Field SHALL have the `card` fill, a hairline `boardLine` border, a corner radius of 14 and padding of 10 vertical and 14 horizontal logical pixels.
2. WHERE a label is given, THE Form_Field SHALL show it above the value in 12 logical pixels at weight 600 with the `textFaint` colour.
3. THE Form_Field SHALL show a value in 17 logical pixels at weight 600 and a placeholder in 16 logical pixels with the `textFaint` colour.
4. WHILE a Form_Field has focus, THE Form_Field SHALL draw a 2 logical pixel `brass` border.
5. THE App SHALL apply the Form_Field look to `TextField` through the input decoration theme and to tappable value fields (dates, times) through `FormFieldBox`.
6. THE App SHALL style the system date and time pickers (`showDatePicker`, `showTimePicker`) from the App_Palette: the `sheet` surface, `brass` for the selection with `inkOnBrass` on it, `text` and `textDim` for the labels and the dialog corner radius; they are the only dialogs besides the Confirm_Dialog.

### Requirement 12: Buttons

**User Story:** As Martin, I want three kinds of buttons with fixed meanings, so that I always know which action is the main one and which one is dangerous.

#### Acceptance Criteria

1. THE Primary_Button SHALL be 54 logical pixels high with a corner radius of 16, the `brass` fill, the label in `inkOnBrass` at 16.5 logical pixels and weight 700, an optional leading icon and the button Glow.
2. WHILE disabled, THE Primary_Button SHALL be drawn at 45 % opacity without Glow.
3. THE Tonal_Button SHALL match the Primary_Button in size with the `tone` fill and the `text` colour.
4. THE Destructive_Button SHALL match the Primary_Button in size with the `destructive` fill and the `inkOnDestructive` colour.
5. THE Pill_Button SHALL be a small Tonal_Button 32 logical pixels high with a fully rounded shape and its label in 14 logical pixels at weight 650, inside a 44 logical pixel hit area.
6. THE App SHALL NOT use outlined buttons.

### Requirement 13: Check circle and effort pips

**User Story:** As Martin, I want "done" to look the same for a quest, a mission step and a reminder, so that the app speaks one language.

#### Acceptance Criteria

1. THE Check_Circle SHALL draw an open state as a 24 logical pixel ring with a 2 logical pixel `lineStrong` stroke inside a 44 × 44 hit area.
2. THE Check_Circle SHALL draw the done state as a filled `brass` circle with a check icon in `inkOnBrass`.
3. THE Check_Circle SHALL expose a checked semantics state and a semantics label.
4. THE Effort_Pips SHALL draw four bars of 12 × 4 logical pixels with a corner radius of 2 and 3 logical pixels apart, filled bars in `brass` and empty bars in `lineStrong`.
5. THE `quests` module SHALL use the shared Check_Circle and Effort_Pips instead of its own `check_circle.dart` and `difficulty_pips.dart`.

### Requirement 14: Empty states

**User Story:** As Martin, I want empty screens to look the same in every module, so that an empty list never looks broken.

#### Acceptance Criteria

1. THE Empty_State SHALL show a 64 logical pixel circle with the `tone` fill and a 28 logical pixel icon in `textDim`, a title in 17 logical pixels at weight 700 and one line of body text in `textDim`.
2. WHERE an action label is given, THE Empty_State SHALL show a Primary_Button under the text.
3. THE Empty_State SHALL keep its existing parameters (title, body, optional action) so that existing callers compile after adding an icon.

### Requirement 15: Glow

**User Story:** As Martin, I want to keep the glow I like, softer in the light theme, so that it never looks blurry.

#### Acceptance Criteria

1. THE App SHALL draw the timer ring Glow from the ring glow roles: `brass` at 30 % with a blur of 5 logical pixels in the light theme and `brass` at 55 % with a blur of 9 logical pixels in the dark theme.
2. THE App SHALL draw the button Glow under the round primary timer button, the add button, the module button and every enabled Primary_Button from the button glow roles: offset 4 logical pixels down, blur 16 and `brass` at 32 % in the light theme; no offset, blur 26 and `brass` at 45 % in the dark theme.
3. THE App SHALL keep the existing ringing overlay animation of the timer and take its colour from the ring glow role.

### Requirement 16: Icons

**User Story:** As a developer, I want every icon the new screens need in the bundled set, so that no screen falls back to the Material icon font.

#### Acceptance Criteria

1. THE Icon_Set SHALL contain stroke icons named `arrow_left`, `alert`, `refresh`, `globe`, `contrast`, `smartphone`, `flask`, `upload`, `download`, `bell`, `minus`, `play`, `pause`, `stop`, `flag` and `monitor`, drawn on a 24 × 24 grid with `currentColor` strokes like the existing icons.
2. THE `IconAsset` class SHALL list every new icon by name.
3. THE App SHALL use an Icon_Set icon in every widget this spec adds or changes.

### Requirement 17: Quality

**User Story:** As a developer, I want the design system covered by tests, so that later changes cannot silently break it.

#### Acceptance Criteria

1. THE Guard_Tests SHALL pass with every file this spec adds or changes.
2. THE App SHALL have a widget test for each new `lib/ui_kit/` widget that checks its key measures and states against the acceptance criteria above.
3. THE App SHALL keep every interactive element of the new widgets at least 44 × 44 logical pixels (the existing `test/a11y/touch_targets_test.dart` style).
4. THE App SHALL pass `test/theme/contrast_test.dart` with the new roles: body text on `card` and on `tone` at least 4.5 : 1, labels on selected Choice_Chips at least 4.5 : 1 for the activity and event colours.
5. WHEN this spec is complete, THE App SHALL pass `scripts/check.sh`, with the golden images in `test/goldens/` regenerated deliberately and reviewed.
