# Implementation Plan: Design System

## Overview

Extend `lib/theme/` with the new palette roles, typography and glow, and build the shared widgets of the agreed
visual language in `lib/ui_kit/layout/`, `lib/ui_kit/controls/`, `lib/ui_kit/forms/` and the restyled
`lib/ui_kit/sheet/` and `lib/ui_kit/common/` widgets. No screen layout changes here (spec 006 does that), but every
screen that already uses `AppSheet`, `confirmDestructive`, `AppSegmented`, `EmptyState` or the typography roles takes
the new look at once. Widget tests sit next to each widget task; property tests cover the palette, the title weight
and contrast. Before starting, read `.design/redesign-preview/README.md` and look at `renders/light/r3-questadd.png`,
`renders/light/r3-mission.png` and `renders/light/r3-dialog.png` (and their `dark/` twins).

## Tasks

- [ ] 1. Theme layer
  - [ ] 1.1 Add the palette roles to `lib/theme/tokens.dart`
    - Add `tone`, `lineStrong`, `card` (defaulting to `parchment` in light and `boardRaised` in dark), `glowRing`, `glowRingBlur`, `glowButton`, `glowButtonBlur`, `glowButtonOffsetY` to `AppPalette`
    - Fill them in `AppPalette.daylight` and `AppPalette.guildBoard` with the values of the token table in `design.md`; change no existing value
    - Add the `Radii`, `Metrics` and `Space.s3` entries listed in `design.md` Component 1
    - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5_

  - [ ]* 1.2 Property test for the palette roles
    - **Property 1: Palette roles exist for every theme brightness**
    - In `test/theme/tokens_test.dart`: for every `ThemeDefinition` in `themeRegistry` and both brightnesses the new roles exist; for the blue theme they equal the table values; every pre-existing value is unchanged (compare against a copied list of the old constants)
    - **Validates: Requirements 1.1, 1.2, 1.3, 1.4, 1.5**

  - [ ] 1.3 Retune `lib/theme/typography.dart`
    - Add `defaultTitleWeight = FontWeight.w600` and the `titleWeight` parameter of `buildDisplayTextTheme`
    - Set `headlineLarge` and `headlineMedium` to 22 px at `titleWeight`; add `displayMedium` 28/700 and `displaySmall` 26/600
    - Body: `labelSmall` 12 px w700 letter spacing `0.09 * 12`; add `titleLarge` 17 px w700
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5, 2.6, 2.8, 2.9_

  - [ ] 1.4 Extend `lib/theme/app_theme.dart`
    - `buildTheme({required AppPalette palette, FontWeight titleWeight = defaultTitleWeight})` passes the weight to the display theme
    - Add `AppGlow.button(p)` (BoxShadow from `glowButton`, `glowButtonBlur`, `Offset(0, glowButtonOffsetY)`) and `AppGlow.ring(p, strokeWidth:)` (Paint with `MaskFilter.blur(BlurStyle.normal, glowRingBlur)`)
    - Set `inputDecorationTheme` to the Form_Field look (fill `card`, hairline `boardLine` border, `Radii.field`, 2 px `brass` focused border, padding 10/14, hint 16 px `textFaint`, label 12 px w600 `textFaint`)
    - Bottom sheet theme: top corners `Radii.sheetTop`
    - Date and time picker themes from the palette (`sheet` surface, `brass` selection with `inkOnBrass`, `text`/`textDim` labels, `Radii.dialog`)
    - _Requirements: 2.7, 11.1, 11.2, 11.3, 11.4, 11.5, 11.6, 15.1, 15.2_

  - [ ]* 1.5 Property test for the title weight
    - **Property 2: Title weight touches only the title roles**
    - In `test/theme/theme_test.dart`: for each weight in {500, 600, 700, 800}, every role except `headlineLarge` and `headlineMedium` equals the role built with 600; the two title roles carry the weight
    - **Validates: Requirements 2.1, 2.2, 2.7**

  - [ ] 1.6 Move the timer glow onto the roles
    - `lib/time_tracking/theme/time_theme.dart`: `glow` and `glowSoft` derive from `palette.glowRing`; add `track` from `palette.lineStrong`
    - `lib/time_tracking/ui/painters/ring_painter.dart`: glow pass uses `AppGlow.ring`, track uses `lineStrong`
    - `lib/time_tracking/ui/widgets/controls/timer_controls.dart` and `lib/ui_kit/common/add_fab.dart`: shadows from `AppGlow.button`
    - `lib/time_tracking/ui/widgets/controls/ringing_overlay.dart`: keep the animation, colour from `glowRing`
    - Add no new literal values in `time_tracking/` (the folder is exempt from the guard, but new code follows it)
    - _Requirements: 15.1, 15.2, 15.3_

- [ ] 2. Icons
  - [ ] 2.1 Add the new SVG icons
    - Add `arrow_left`, `alert`, `refresh`, `globe`, `contrast`, `smartphone`, `flask`, `upload`, `download`, `bell`, `minus`, `play`, `pause`, `stop`, `flag`, `monitor` to `assets/icons/` as 24 × 24 stroke icons with `stroke="currentColor"`, matching the stroke width and caps of the existing files (the mockup `<symbol>` paths in `.design/redesign-preview/index.html` and `round2.html` are the shapes to use; `play`, `pause` and `stop` are filled shapes with `fill="currentColor"`)
    - List each in `IconAsset` (`lib/ui_kit/common/app_icon.dart`)
    - _Requirements: 16.1, 16.2_

  - [ ]* 2.2 Extend `test/assets_test.dart`
    - Every `IconAsset` name has a file; every new file uses `currentColor`
    - _Requirements: 16.1, 16.2_

- [ ] 3. Layout widgets (`lib/ui_kit/layout/`)
  - [ ] 3.1 `header_action.dart`: `HeaderAction`
    - 44 × 44, `Radii.headerAction`, `tone` fill, 24 px icon in `textDim`, optional badge (brass pill ≥ 18 px, count in `inkOnBrass`), required semantics label
    - _Requirements: 4.1, 4.2, 4.3, 4.4_

  - [ ] 3.2 `app_header.dart`: `AppHeader` and `HeaderLeading`
    - Height `Metrics.header`, padding `Space.s12`; leading menu (existing `MenuButton`), back (`arrow_left`, pops), close (`close`, pops) or none; title in `headlineLarge`, one line, ellipsis, header semantics; optional subtitle 12.5 px `textDim`; up to two trailing widgets (assert)
    - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5, 3.6, 3.7, 3.9_

  - [ ]* 3.3 Widget tests for `HeaderAction` and `AppHeader`
    - `test/ui_kit/layout/header_action_test.dart`, `app_header_test.dart`: height 64, 44 px targets, back and close pop a pushed route, long title ellipsizes, subtitle colour, badge appears only for a count > 0
    - _Requirements: 3.1, 3.3, 3.4, 3.5, 3.6, 4.1, 4.3, 17.3_

  - [ ] 3.4 `grouped_list.dart`: `GroupedList`, `ListRow`, `IconTile`, `AddRow`
    - Card with `card` fill, hairline border, `Radii.group`, clipped; hairline dividers between rows
    - `ListRow`: min height 56, padding 13/16, title 16/600, subtitle 13.5 `textDim`, trailing value 14.5 `textDim`, optional trailing widget, optional chevron 20 px `textFaint`, `dimmed` at 50 % opacity, one merged semantics node
    - `IconTile` 34 px, `Radii.iconTile`, `brassSoft` fill, 19 px `brassText` icon; `AddRow` plus icon 20 px and label 15.5/650 in `brassText`
    - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5, 5.6, 5.7, 5.8_

  - [ ] 3.5 `section_headers.dart`: `SectionLabel`, `CountHeader`
    - `SectionLabel`: upper-cased `labelSmall` in `textFaint`, header semantics; `CountHeader`: `body.titleLarge` title, faint w600 count, optional trailing widget
    - Rewrite `lib/ui_kit/common/settings_group.dart` as `SectionLabel` + child (same constructor)
    - _Requirements: 5.9, 5.10_

  - [ ]* 3.6 Widget tests for the list widgets
    - `test/ui_kit/layout/grouped_list_test.dart`, `section_headers_test.dart`: dividers count = rows − 1, row min height, chevron only when asked, dimmed opacity, Add_Row colour, label upper-casing
    - _Requirements: 5.1, 5.2, 5.3, 5.6, 5.8, 5.9, 5.10_

  - [ ] 3.7 `swipe_actions.dart`: `SwipeActions` and `SwipeActionSpec`
    - Move the implementation of `lib/notes/ui/widgets/swipe_row.dart` here; add `SwipeActionSpec.edit` (`tone` fill, `text` colour, `edit` icon, label `common_edit`) and `SwipeActionSpec.delete` (`destructive` fill, `inkOnDestructive`, `trash` icon, label `common_delete`); action width `Metrics.swipeAction`, icon above label 13/650
    - Keep the one-open-row-per-group behaviour and the custom semantics actions
    - Point `notes/` at the shared widget (keep its three-action set and keys); leave the Quest and Mission rows as they are
    - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5, 6.6, 6.7_

  - [ ]* 3.8 Widget test for `SwipeActions`
    - `test/ui_kit/layout/swipe_actions_test.dart`: drag left reveals both actions, opening a second row closes the first, semantics actions call the callbacks; existing Notes swipe tests still pass
    - _Requirements: 6.1, 6.4, 6.5, 6.7_

- [ ] 4. Controls (`lib/ui_kit/controls/`) and forms
  - [ ] 4.1 `app_buttons.dart`: `AppButton` (primary, tonal, destructive) and `PillButton`
    - 54 px high, `Radii.button`, label 16.5/700, optional leading icon; primary `brass`/`inkOnBrass` with `AppGlow.button`; disabled at 45 % opacity without glow; tonal `tone`/`text`; destructive `destructive`/`inkOnDestructive`; `PillButton` 32 px tonal, fully rounded, label 14/650, 44 px hit area
    - _Requirements: 12.1, 12.2, 12.3, 12.4, 12.5_

  - [ ] 4.2 `choice_chip.dart`: `ChoiceChipX`, `TypeTag`, `tintFill`, `tintInk`
    - Chip radius 12, padding 8/12, `card` fill, hairline border, label 15/600, optional 8 px dot; selected: fill 20 % over `card`, border 50 %, label mixed 45 % into `text`; default colour `brass`; no thick outline
    - Type_Tag radius 8, padding 3/8, fill 20 % over `card`, label 12.5/650 mixed 45 % into `text`
    - _Requirements: 9.1, 9.2, 9.3, 9.4, 9.5, 9.6_

  - [ ] 4.3 `check_circle.dart` and `effort_pips.dart`
    - Move `lib/quests/ui/cards/check_circle.dart` here, restyle: open 24 px ring with 2 px `lineStrong`, done filled `brass` with `check` icon in `inkOnBrass`, 44 px hit area, checked semantics; keep its animation, haptic and reduced-motion handling
    - `EffortPips`: four 12 × 4 bars, radius 2, gap 3, filled `brass`, empty `lineStrong`; replace `lib/quests/ui/cards/difficulty_pips.dart` and update its importers
    - _Requirements: 13.1, 13.2, 13.3, 13.4, 13.5_

  - [ ] 4.4 `lib/ui_kit/forms/form_field_box.dart`: `FormFieldBox`
    - Optional label above value (12/600 `textFaint`), value 17/600, placeholder 16 `textFaint`, focused 2 px `brass` border, optional trailing widget, tap callback
    - _Requirements: 11.1, 11.2, 11.3, 11.4, 11.5_

  - [ ]* 4.5 Widget tests for the controls
    - `test/ui_kit/controls/app_buttons_test.dart`, `choice_chip_test.dart`, `check_circle_test.dart`, `effort_pips_test.dart`, `test/ui_kit/forms/form_field_box_test.dart`: sizes, fills per kind, disabled opacity and no glow, selected chip colours computed with `tintFill`/`tintInk`, check states and semantics, pip count, focused border
    - _Requirements: 9.3, 12.1, 12.2, 13.1, 13.2, 13.3, 13.4, 11.4, 17.2, 17.3_

  - [ ]* 4.6 Property test for chip contrast
    - **Property 3: Selected chip labels stay readable**
    - In `test/theme/contrast_test.dart`: for every activity colour (`lib/time_tracking/domain/activity_types.dart`, both variants) and every Event_Type colour, in both palettes, the selected label colour on the selected fill reaches 4.5 : 1
    - **Validates: Requirements 9.3, 17.4**

- [ ] 5. Checkpoint — theme and new widgets
  - Ensure all tests pass (`flutter test test/theme test/ui_kit test/assets_test.dart`), ask the user if questions arise.

- [ ] 6. Restyle the existing shared widgets
  - [ ] 6.1 `lib/ui_kit/sheet/app_sheet.dart`
    - New header: title left in `headlineMedium`, optional `headerAction`, close `HeaderAction` (cross) at the right that runs the existing cancel path; remove the text "Zrušit" button and the centring
    - Primary button becomes a full-width `AppButton.primary` (icon kept); top corners `Radii.sheetTop`
    - Keep every dismissal rule and the dirty-discard question
    - _Requirements: 7.1, 7.2, 7.3, 7.4, 7.5, 7.6_

  - [ ]* 6.2 Update `test/ui_kit/sheet/app_sheet_test.dart`
    - Close button asks when dirty and closes when clean; no "Zrušit" text; title left-aligned; header action rendered before close; existing dismissal tests still pass
    - _Requirements: 7.1, 7.2, 7.4, 7.5, 7.6_

  - [ ] 6.3 `lib/ui_kit/sheet/confirm_destructive.dart`
    - New layout: icon badge 48 px, title 21/700, body 15.5 `textDim`, equal-width `AppButton.tonal` + `AppButton.destructive` side by side, stacked when they do not fit; `sheet` fill, `Radii.dialog`, 26 px side inset
    - Add `confirmAction` (brass badge and `AppButton.primary`) with the same result contract
    - _Requirements: 8.1, 8.2, 8.3, 8.4, 8.5, 8.6_

  - [ ]* 6.4 Update `test/ui_kit/sheet/confirm_destructive_test.dart`
    - Results true/false for confirm, cancel, scrim and back; destructive vs action styling; stacking under a large text scale; haptic on destructive confirm
    - _Requirements: 8.2, 8.3, 8.4, 8.5, 8.6_

  - [ ] 6.5 `lib/ui_kit/common/app_segmented.dart`
    - Track `tone` radius 12 padding 3; selected segment `card` radius 9 with the light-only shadow; labels w600, selected `brassText`; icon-only segments with required semantics labels; no outline
    - _Requirements: 10.1, 10.2, 10.3, 10.4, 10.5_

  - [ ] 6.6 `lib/ui_kit/common/empty_state.dart`
    - Optional `icon`; 64 px `tone` circle with 28 px `textDim` icon, title 17/700, one body line `textDim`, optional `AppButton.primary`; existing parameters unchanged
    - _Requirements: 14.1, 14.2, 14.3_

  - [ ]* 6.7 Update `app_segmented_test.dart` and `empty_state_test.dart`
    - Selected colours and no outline, icon-only semantics; empty-state layout and action button
    - _Requirements: 10.3, 10.4, 10.5, 14.1, 14.2_

- [ ] 7. Quality gate
  - [ ] 7.1 Accessibility and guard checks
    - Add the new widgets to `test/a11y/catalogue_test.dart` and `touch_targets_test.dart` (44 px minimum), run `token_usage_test.dart`, `clock_usage_test.dart`, `assets_test.dart`
    - Extend `contrast_test.dart`: body text on `card` and on `tone` ≥ 4.5 : 1 in both palettes
    - _Requirements: 17.1, 17.3, 17.4_

  - [ ] 7.2 Regenerate and review the goldens
    - `flutter test --update-goldens test/goldens`; open every changed PNG and check that only titles, sheet headers, segmented controls, dialogs and empty states changed
    - _Requirements: 17.5_

  - [ ] 7.3 Run the real app
    - Build and run the Linux app (skill `sandbox-flutter-linux-run`), take a screenshot of the Quest board, open the new-quest sheet and a delete confirmation, in light and dark; compare with `renders/*/r3-questadd.png` and `renders/*/r3-dialog.png`
    - _Requirements: 7.1, 8.1, 17.5_

  - [ ] 7.4 Add the design-rule guard test
    - New `test/theme/design_rules_test.dart` that scans `lib/` (outside `lib/ui_kit/`) and fails on `OutlinedButton`, `AlertDialog(`, `showDialog(` (except the date and time pickers), `ScreenHeader(`, `SubPageHeader(`, `SettingsNavRow(`, `Icons.` and the dashed add-box painter of the Quests module
    - Give it an explicit allowlist of the files that still use them today (most of `time_tracking/ui/`, `settings/ui/import_row.dart`, `quests/ui/sheets/rule_sheet.dart`, the screens with the old headers); the test also fails when an allowlisted file no longer needs its entry, so the list only shrinks
    - Spec `006-screen-redesign` empties the allowlist (its task 9.2); this test is how the app-wide rules below stay enforced
    - _Requirements: 1.6, 3.8, 3.10, 5.11, 5.12, 7.7, 8.7, 12.6, 16.3_

- [ ] 8. Checkpoint — spec complete
  - Ensure `scripts/check.sh` passes, ask the user if questions arise.

## Notes

- App-wide rules of this spec (1.6, 3.8, 3.10, 5.11, 5.12, 7.7, 8.7, 12.6, 16.3) are met screen by screen in spec `006-screen-redesign`; here task 7.4 only adds the guard test with an allowlist of today's offenders.
- Tasks marked with `*` are optional and can be skipped for faster MVP; they are strongly recommended here, because specs 005 and 006 build on these widgets.
- Read `.design/redesign-preview/README.md` before starting; it says which render shows which widget and which source wins when they disagree.
- The blue palette values must not change; only new roles are added. Do not rename `brass`, `slip*`, `board` (see `.agents/REFACTOR.md`).
- `lib/ui_kit/` may not import a feature folder (`test/architecture/feature_imports_test.dart`). The moved Check_Circle and swipe row must therefore lose every import of `quests/` and `notes/`; pass texts in from the caller.
- No literal colours, spacing or durations in `lib/` outside `time_tracking/` (guard tests); add tokens to `lib/theme/tokens.dart` instead. Do not add new literals in `time_tracking/` either.
- Every user-facing string goes through both ARB files with a feature prefix (`app_cs.arb` is the template, run `flutter gen-l10n`). This spec adds no new strings beyond what the moved widgets already use.
- `glados` clashes with `flutter_test` names: hide the clashing symbols in property tests.
- Never run `dart format` on a whole file that is not already formatted; never `pkill -f`.
- Commit per task group as a Conventional Commit with the author `Martin Jablečník <martin.jablecnik@email.cz>` and no tool-attribution trailers; no remote, never push.
