# Implementation Plan: Module Navigation

## Overview

Replace the five-tab bottom bar and the flat drawer with navigation by Modules: a `Module` enum and `ShellLocation`
in `lib/shell/module.dart`, the `ModuleBar` with the Module_Button, the `ModuleLauncher` sheet, a rebuilt
`AppDrawer`, device preferences in `lib/core/ui_preferences.dart` (Experiment_Settings and Last_Location), the
Experiments group on the Settings page and the header changes of the pages that became tabs. Spec
`004-design-system` must be complete first (App_Header, Header_Action, Grouped_List, App_Sheet, Segmented_Control,
glow roles, `buildTheme(titleWeight)`). Unit and property tests cover the model and the store; widget tests cover the
bar, the launcher, the drawer and the Shell; the real Linux app is checked at the end. Look at
`.design/redesign-preview/renders/{light,dark}/r2-nav2-*.png` and `r2-nav1-timer-drawer.png` before starting.

## Tasks

- [ ] 1. Model and preferences
  - [ ] 1.1 Create `lib/shell/module.dart`
    - `Module` enum with `pages` (time: timer, history, statistics; quests: quests, missions; calendar; notes; settings), `launchable`, `icon`, `label(AppLocalizations)`
    - `ShellLocation` with `initial`, `at`, `destination`, `show`, `switchTo`, `back` as in `design.md` Component 1
    - Add `Destination.module` in `lib/shell/destination.dart`
    - _Requirements: 1.1, 1.2, 1.3, 1.4, 3.7, 3.8, 4.1, 4.2, 4.3, 5.1_

  - [ ]* 1.2 Property tests for the model
    - **Property 1: Every Destination belongs to exactly one Module**
    - **Property 2: Navigation sequences keep a consistent location**
    - In `test/shell/module_test.dart` with `glados`: generated sequences of `show` / `switchTo` / `back`; check the invariants of `design.md`
    - **Validates: Requirements 1.2, 1.4, 3.7, 3.8, 4.1, 4.2, 4.3, 5.1**

  - [ ] 1.3 Create `lib/core/ui_preferences.dart`
    - `ModuleButtonSide`, `UiPreferences`, `UiPreferenceKeys`, `UiPreferencesStore`, `SharedPrefsUiPreferencesStore`, `initialUiPreferencesProvider`, `uiPreferencesStoreProvider`, `UiPreferencesNotifier`, `uiPreferencesProvider`
    - `load` maps missing or invalid values to defaults; setters update state first, then write without awaiting the UI
    - _Requirements: 5.2, 8.5, 8.8, 8.9_

  - [ ]* 1.4 Property test for the store
    - **Property 3: Preferences round-trip and fall back**
    - In `test/core/ui_preferences_test.dart` with `SharedPreferences.setMockInitialValues`: random valid values round-trip; random garbage under the four keys loads as defaults
    - **Validates: Requirements 5.2, 5.4, 8.8, 8.9**

  - [ ] 1.5 Load the preferences at start and feed the theme
    - `lib/startup.dart`: create the store from `SharedPreferences.getInstance()`, `await load()`, override `initialUiPreferencesProvider` and `uiPreferencesStoreProvider`; pass the stored Destination (link name → `Destination`) as `AppShell.initial` when there is no launching Deep_Link
    - `lib/app.dart`: watch `uiPreferencesProvider.select((p) => p.titleWeight)` and pass it to `buildTheme` for both palettes
    - Update `test/startup_test.dart` with a fake store; keep its time limit
    - _Requirements: 5.3, 5.4, 8.5, 8.7_

  - [ ] 1.6 Ignore `ui_` keys on import
    - `lib/database/import/preferences_writer.dart`: `isImportedPreference` returns false for keys starting with `ui_`
    - _Requirements: 8.10_

  - [ ]* 1.7 Property test for the importer
    - **Property 4: Import never touches device UI preferences**
    - In the existing preferences writer test: generated maps with mixed keys never write a `ui_` key and still write the others
    - **Validates: Requirements 8.10**

- [ ] 2. Module bar and launcher
  - [ ] 2.1 Add the strings
    - Add the keys of the table in `design.md` ("New strings") to `lib/l10n/app_cs.arb` (with descriptions) and `app_en.arb`; run `flutter gen-l10n`
    - _Requirements: 11.4_

  - [ ] 2.2 Create `lib/shell/module_bar.dart`
    - `ModuleBar` and `ModuleButton` per `design.md` Component 4: button 50 px, radius 16, `brass` fill, `inkOnBrass` icon, `AppGlow.button`, 66 px slot; `lineStrong` separator inset 16 with 6 px space; tabs icon + 12 px label (w500, w700 selected), selected `brassText`, others `text` at 58 %, no pill; equal widths for several pages, max 92 px for one; `boardRaised` fill, hairline top border, 66 px content above the safe area; mirrored layout for the right side
    - Horizontal drag ≥ 24 px on the button calls `onPreviousModule` once per drag with `Haptics.light()`; semantics label and the custom action "Předchozí modul" while a Previous_Module exists
    - Add the tokens `Metrics.moduleButton`, `moduleSlot`, `barContent`, `singleTabMax`, `drawerEdge`, `drawerIcon`, `tileMin`, `launcherIcon` and `Radii.moduleButton`, `tile`, `launcherIcon`, `drawerIcon` to `lib/theme/tokens.dart`
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5, 2.6, 2.7, 2.8, 2.9, 2.10, 4.1, 4.4, 4.5, 8.6, 10.1, 10.2, 10.4_

  - [ ]* 2.3 Widget tests for the module bar
    - `test/shell/module_bar_test.dart`: three, two and one page layouts; left and right side order; selected colours and weights; no indicator; drag of 23 px does nothing and 24 px switches; semantics label and custom action; 44 px targets
    - _Requirements: 2.1, 2.5, 2.6, 2.7, 2.8, 4.1, 4.3, 4.5, 8.6, 10.1, 10.2, 10.4_

  - [ ] 2.4 Create `lib/shell/module_launcher.dart`
    - `showModuleLauncher` with `AppSheet(title: shell_modulesTitle)` and no primary button; two-column grid of the four launchable Modules (tile per Requirement 3.3, current tile per 3.4); Grouped_List with the Settings row; centred hint; tap closes with the chosen Module; reduced motion uses the existing sheet fade
    - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5, 3.6, 10.3, 10.5_

  - [ ]* 2.5 Widget tests for the launcher
    - `test/shell/module_launcher_test.dart`: four tiles with page names, current tile marked, Settings row, hint text, result of a tap, dismiss returns null, selected semantics
    - _Requirements: 3.2, 3.3, 3.4, 3.5, 3.6, 3.7, 10.3_

- [ ] 3. Shell and drawer
  - [ ] 3.1 Rewrite `lib/shell/app_drawer.dart`
    - Title „DayLog“ 26/800; rows for Time, Quests, Calendar, Notes (42 px icon tile radius 13, name 17/650); current Module row `brassSoft` with a `brass` tile; chips for `pages.skip(1)` indented 68; hairline; Settings row at the bottom; `sheet` fill, right corners rounded
    - Callbacks `onSelectModule` and `onSelectPage`; keys `drawerModuleKey(Module)` and `drawerItemKey(Destination)`
    - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5, 6.6, 10.4_

  - [ ] 3.2 Rework `lib/shell/app_shell.dart`
    - Replace `_destination` with `ShellLocation`; `_show`, `_switchModule`, `_previousModule`, `_openLauncher` per `design.md` Component 7; each change persists the Last_Location
    - Replace `BottomBar` with `ModuleBar` (side and drawer flag from `uiPreferencesProvider`); keep the `IndexedStack`, splash gating, Reconciliation, snackbar clearing and statistics refresh
    - Drawer only while Drawer_Enabled; `drawerEnableOpenDragGesture` follows it; `drawerEdgeDragWidth: Metrics.drawerEdge`
    - Deep links and `ShellMenuScope.openPage` go through `_show`; a link makes the Module shown before it the Previous_Module
    - Delete `lib/shell/bottom_bar.dart`; remove `Destination.tabs`, `tab`, `isTab`, `group`, `DestinationGroup`, `drawerItems` and the strings `shell_groupTime`, `shell_groupPlanning` once unused
    - _Requirements: 2.10, 2.11, 3.7, 3.8, 4.1, 4.2, 4.3, 5.1, 5.2, 5.5, 5.6, 6.5, 6.6, 6.7, 6.8, 7.5, 9.1, 9.3_

  - [ ] 3.3 Drawer switch in `lib/ui_kit/common/menu_button.dart`
    - `MenuButton` becomes a `ConsumerWidget` that draws nothing while `drawerEnabled` is false (and, as today, without a `ShellMenuScope`)
    - _Requirements: 6.8_

  - [ ] 3.4 Headers of the pages that became tabs
    - `timer_screen.dart`: `AppHeader(title: shell_tabTimer)`, no History/Statistics buttons
    - `history_screen.dart`, `statistics_screen.dart`: no back button, menu leading
    - `missions_screen.dart`: no back button, menu leading
    - Pushed routes keep their back or close element
    - _Requirements: 7.1, 7.2, 7.3, 7.4_

  - [ ]* 3.5 Widget tests for the drawer and the Shell
    - `test/shell/app_drawer_test.dart`: rows, chips per Module, current Module marked, callbacks, 44 px targets
    - Update `test/shell/app_shell_test.dart`: starts on the stored Last_Location; unknown location starts on Timer; tab tap; launcher switch; drag switches to the Previous_Module and back; deep link shows its Destination and keeps the Previous_Module; drawer absent and edge drag ignored while disabled; snackbars cleared and statistics refreshed on page change; existing Reconciliation and splash tests green
    - Update `destination_test.dart`, delete `bottom_bar_test.dart`
    - _Requirements: 5.3, 5.4, 5.5, 6.7, 6.8, 7.5, 9.1, 11.1, 11.2_

- [ ] 4. Checkpoint — navigation works
  - Ensure all tests pass (`flutter test test/shell test/core test/startup_test.dart`), ask the user if questions arise.

- [ ] 5. Experiments and shortcuts
  - [ ] 5.1 Create `lib/settings/ui/experiments_group.dart` and insert it
    - `SectionLabel(settings_groupExperiments)` + `GroupedList` with „Tlačítko modulů“ (`AppSegmented` Vlevo/Vpravo), „Boční menu“ (switch), „Tloušťka nadpisů“ (`AppSegmented` 500/600/700/800), all bound to `uiPreferencesProvider`
    - `settings_screen.dart`: insert the group directly before the About group
    - _Requirements: 8.1, 8.2, 8.3, 8.4, 8.5, 8.6, 8.7_

  - [ ]* 5.2 Widget test for the Experiments group
    - `test/settings/ui/experiments_group_test.dart`: each control changes the provider; the Module_Bar flips side, the Menu_Button disappears and the title weight of an `AppHeader` changes without a restart
    - _Requirements: 8.2, 8.3, 8.4, 8.5, 8.6, 8.7_

  - [ ] 5.3 Keep shortcuts working
    - Confirm `_shortcutTargets` still lists every Destination except Settings and `destinationFromUri` is unchanged; add a test that `daylog://statistics` shows Statistics inside the Time Module
    - _Requirements: 9.1, 9.2, 9.3_

- [ ] 6. Verification
  - [ ] 6.1 Goldens and accessibility
    - Regenerate `test/goldens` deliberately and review (the bottom bar changes on every screen golden); run `test/a11y/` (touch targets, semantics labels, reduced motion)
    - _Requirements: 10.4, 10.5, 11.3_

  - [ ] 6.2 Run the real app
    - Linux app via skill `sandbox-flutter-linux-run`: start, check the Module_Bar on the Timer, open the launcher, switch to Questy, drag back on the Module_Button, toggle the three experiments in Settings, restart and check the Last_Location; screenshots in light and dark compared with `renders/*/r2-nav2-*.png`
    - _Requirements: 11.3_

- [ ] 7. Checkpoint — spec complete
  - Ensure `scripts/check.sh` passes, ask the user if questions arise.

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP; the property and Shell tests are strongly recommended because navigation regressions are easy to miss.
- Spec `004-design-system` is a prerequisite. If `AppHeader` does not exist yet, stop and finish spec 004 first.
- `lib/settings/` and the other QuestLog modules must not import `lib/shell/` (`test/architecture/feature_imports_test.dart`); that is why the preference store lives in `lib/core/ui_preferences.dart` and stores the Last_Location as a link name string.
- Riverpod 3 pauses a provider nobody listens to; read the loaded preferences through the overridden `initialUiPreferencesProvider`, never `container.read(provider.future)` alone (see `CLAUDE.md`). Never change a provider while a widget builds; persist in callbacks.
- Widget tests that mount the Shell need `test/flutter_test_config.dart` (empty SharedPreferences, Figtree). Call `SharedPreferences.setMockInitialValues` before building when a test needs a stored Last_Location.
- The edge drag of the Drawer was disabled because of gesture collisions; keep it limited to `Metrics.drawerEdge` (20 px) and verify on the real app that swipe actions on Quest, Notes and History rows still open.
- Start-up changed: run the real Linux app and look at the first screen (skill `sandbox-flutter-linux-run`); the tests cannot see a hung start.
- The mockups `r2-nav2-*` draw no Menu_Button because they assume the drawer is off; with Drawer_Enabled on (the default) the App_Header shows it on the left.
- No literal colours, spacing or durations outside `time_tracking/`; add tokens. Every string through both ARB files.
- Commit per task group as a Conventional Commit with the author `Martin Jablečník <martin.jablecnik@email.cz>` and no tool-attribution trailers; never push.
