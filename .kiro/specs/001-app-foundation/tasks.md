# Implementation Plan: App Foundation

## Overview

Create the DayLog project by copying QuestLog 1.5.0, rename it, regroup its files into feature folders, add the Shell with the Drawer and the `daylog://` deep links, and make `scripts/check.sh` green. The TimeLog features arrive in spec `002-time-tracking-port`; this spec leaves a Timer placeholder Destination that `002` replaces. Testing is the ported QuestLog suite plus new tests for the Shell, the Database and the import rule.

## Tasks

- [x] 1. Scaffold the project
  - [x] 1.1 Copy QuestLog into `/workspace/DayLog`
    - Copy `/workspace/QuestLog` without `.git`, `build/`, `.agents/`, `screenshots/` and `ios/`; keep `.design/`, `assets/`, `test/`, `drift_schemas/`
    - Copy `ios/` from `/workspace/TimeLog/timelog_app` at tag `v1.2.0` (Runner, `TimeLogWidgetExtension`, entitlements, notification sounds), then merge QuestLog's `CFBundleURLTypes` and `FlutterDeepLinkingEnabled` into `Info.plist`
    - The git repository and the author identity already exist
    - _Requirements: 1.1_

  - [x] 1.2 Rename the package and the Working_Name
    - `pubspec.yaml`: `name: daylog`, version `0.0.1+1` until the first release, SDK constraint unchanged
    - Replace `package:questlog/` imports; rename `QuestlogApp`, `QuestlogDatabase`, `QuestlogPalette` to `DayLogApp`, `AppDatabase`, `QuestPalette`
    - Display name, bundle identifier `com.jablecnik.daylog`, App Group `group.com.jablecnik.daylog` and URL scheme `daylog` in `ios/Runner/Info.plist`, `ios/Runner.xcodeproj`, both entitlements files and `app_name` in both ARB files
    - Rename the extension target and folder to `DayLogWidgetExtension` and fix the Xcode project references
    - Placeholder app icon from QuestLog's `.design/icon`; keep the launch screen colour of QuestLog
    - iOS deployment target 18.0
    - _Requirements: 1.1, 9.1, 9.2, 9.3, 9.4_

  - [x] 1.3 Create the empty feature folders and the scripts
    - Create the folders listed in Requirement 1.2 with a `.gitkeep`
    - Copy `scripts/check-structure.sh` from `tool-configs/templates/scripts/`; keep `scripts/check.sh` from QuestLog
    - _Requirements: 1.2, 1.3_

- [x] 2. Regroup the files into feature folders
  - [x] 2.1 Move shared code to `core/`, `database/` and `theme/`
    - `lib/core/{clock,errors,validation,board_day}.dart` stay; `lib/data/database.dart` becomes `lib/database/app_database.dart`; Drift table classes of all features are referenced from there
    - Move `database_export.dart` and `export_service.dart` to `lib/database/export/`
    - Move `lib/ui/theme/*` to `lib/theme/`
    - _Requirements: 1.2, 2.1_

  - [x] 2.2 Move Quest_Module files to `lib/quests/`
    - Tables, models, mappers, `quest_service`, `mission_service`, `recurrence_service`, `xp_engine`, XP rules, cadence, board and mission screens, sheets, cards, hero and reward widgets, state files into `data/`, `domain/`, `services/`, `ui/`
    - Keep every directory at 15 files or fewer
    - _Requirements: 1.2, 3.1_

  - [x] 2.3 Move Calendar_Module files to `lib/calendar/`
    - `lib/core/calendar/`, `lib/data/calendar/`, `lib/services/calendar/`, calendar screens, sheets and widgets, `calendar_state.dart`, `event_task_actions.dart`
    - _Requirements: 1.2, 3.2_

  - [x] 2.4 Move Notes_Module files to `lib/notes/`
    - `lib/core/notes/`, `lib/data/notes/`, `lib/services/notes/`, notes and note editor screens, sheets, widgets, `notes_state.dart`
    - _Requirements: 1.2, 3.3_

  - [x] 2.5 Move Settings to `lib/settings/`
    - `settings_screen.dart`, `export_row.dart`, `rule_row.dart`, `rules_section.dart`, `shortcut_guide.dart`, `settings_service.dart`, `preferences.dart`
    - _Requirements: 1.2, 6.1, 6.4_

  - [x] 2.6 Move the tests to mirror `lib/` and fix imports
    - Move `test/` files and goldens; run `dart run build_runner build` and `flutter gen-l10n`
    - _Requirements: 3.4, 3.5_

  - [x]* 2.7 Write the folder boundary test
    - `test/architecture/feature_imports_test.dart` scans `lib/` and fails when `core`, `theme`, `ui_kit` or `l10n` import a feature, when `time_tracking` imports anything beyond the shared folders and `database`, or when a QuestLog module imports `time_tracking` or `shell`
    - Fix any violation by moving the shared piece into `core/`, `ui_kit/` or `theme/`
    - **Property 3: Folder boundaries hold**
    - **Validates: Requirements 1.4, 1.5, 1.6, 1.7**

- [x] 3. Checkpoint — moved code is green
  - Ensure `scripts/check.sh` passes with all QuestLog tests; list regenerated goldens, ask the user if questions arise

- [x] 4. Shell, Drawer and deep links
  - [x] 4.1 Add `Destination` and the deep-link parser
    - `lib/shell/destination.dart` with the enum from the design; `destinationFromUri`
    - `lib/shell/deep_link.dart` moved from QuestLog, scheme `daylog`, host or first path segment as the name
    - _Requirements: 5.1, 5.2, 5.4_

  - [x]* 4.2 Write property tests for Destination and links
    - **Property 1: Every Destination is reachable**
    - **Property 2: Foreign links are ignored**
    - **Validates: Requirements 4.2, 4.3, 5.1, 5.2, 5.4**

  - [x] 4.3 Add the `BottomBar` and the `AppDrawer`
    - `BottomBar` from QuestLog's tab bar (rename `ShellTabBar`): tabs Timer, Quests, Calendar, Notes, Settings; marks the parent tab of History, Statistics and Missions
    - `AppDrawer` lists every Destination: Timer, History, Statistics (group Time), Quests, Missions, Calendar, Notes (group Planning) and Settings; labels from l10n; closes on selection
    - _Requirements: 4.2, 4.3, 4.5_

  - [x] 4.4 Rebuild `AppShell` around `Destination` and `IndexedStack`
    - Move the Reconciliation state machine, lifecycle observer, splash and reconcile banner unchanged
    - Initial Destination is `timer`, or the one of the launching link
    - The Timer Destination is a placeholder screen until spec `002` replaces it, and does not wait for the Reconciliation; the Quest Destinations show the splash until it is done
    - Host the reward overlay in `DayLogApp.builder`
    - _Requirements: 4.1, 4.5, 4.7, 4.8, 4.9, 4.10, 5.3_

  - [x]* 4.5 Write Shell widget tests
    - First screen is the Timer; Drawer lists all Destinations; selecting closes the Drawer; state of a Destination survives switching; a launching link opens its Destination
    - _Requirements: 4.1, 4.2, 4.3, 4.5, 4.7, 5.3, 10.3, 10.4_

  - [x] 4.5a Add `MenuButton` to every Destination header
    - Add `lib/ui_kit/common/menu_button.dart` (`ShellMenuScope`, `MenuButton`) and place the button in the existing header of Board, Missions, Calendar, Notes and Settings; the Timer, History and Statistics headers are done in spec `002`; hide it on pushed routes
    - _Requirements: 4.11, 4.12_

  - [x] 4.6 Update the shortcut guide in Settings
    - List all eight links with the `daylog://` scheme; keep the guide's steps (Open URL, Add to Home Screen)
    - _Requirements: 5.5_

- [x] 5. Theme, settings and localisation
  - [x] 5.1 Add the theme registry
    - `lib/theme/theme_registry.dart` with `ThemeDefinition`, `blueTheme` (`guildBoard`, `daylight`), `themeRegistry`, `activeThemeIdProvider`; rename `QuestPalette` to `AppPalette`
    - `DayLogApp` builds `theme` and `darkTheme` from the active definition; the Drawer and the status bar follow it
    - Test: the registry holds the blue theme, every palette defines every role, and the provider returns the blue id
    - _Requirements: 7.1, 7.2, 7.3, 7.4_

  - [x] 5.2 Settings groups and shared language and theme
    - Keep the QuestLog groups; add empty-group slots for the Time_Module settings that spec `002` fills
    - `language` and `themeMode` live in `app_state`; `DayLogApp` reads both
    - _Requirements: 6.1, 6.2, 6.3, 6.6_

  - [x]* 5.3 Write the ARB parity test
    - Every key exists in `app_cs.arb` and `app_en.arb`; keys of merged features carry their feature prefix
    - _Requirements: 8.1, 8.3, 8.4_

- [x] 6. Database, export, docs and gate
  - [x] 6.1 Reset the schema to version 1
    - New `schemaVersion = 1` with `onCreate: createAll`; no upgrade steps; delete the QuestLog schema dumps and write the new `drift_schemas/drift_schema_v1.json`
    - File name `daylog.sqlite`; calendar seed runs once on create
    - _Requirements: 2.1, 2.4, 2.5, 2.6_

  - [x]* 6.2 Write the Database tests
    - Empty Database has every expected table; no two tables share a name; the seed runs once
    - **Property 4: Table names are unique**
    - **Validates: Requirements 2.2, 2.3, 2.5, 10.2**

  - [x] 6.2a Extend the export
    - `lib/database/export/` writes all tables and the SharedPreferences (as in TimeLog's `ExportService`), format `daylog-export`, file `daylog-export-YYYY-MM-DD.json`
    - Port the QuestLog and TimeLog export tests; add one for the preferences
    - _Requirements: 6.4, 6.5_

  - [x] 6.3 Write the project documents
    - `CLAUDE.md`, `README.md`, `DOCS.md`, `FEATURES.md` in English: layout, commands, the import rule, the two palettes, the Working_Name locations
    - Add `.gitignore` for `build/`, `.dart_tool/`, `ios/Pods`, `.import/`
    - _Requirements: 1.8, 8.2, 9.1_

  - [x] 6.4 Rename-check
    - Grep the project for `questlog`, `Questlog`, `QuestLog` outside the Quest_Module's user-visible name; list the remaining hits in the checkpoint report
    - _Requirements: 9.1, 9.4_

- [x] 7. Changelog and first release
  - [x] 7.1 Write the Release_Script and the Changelog
    - `scripts/release.sh <version>` (bash, Script Portability pattern): validates the version and a clean tree, collects `git log <previous tag>..HEAD` subjects, groups `feat`, `fix`, others (skips `chore: bump`), prepends a section to `CHANGELOG.md`, sets `version:` in `pubspec.yaml` (build number kept), commits, creates the annotated tag
    - `CHANGELOG.md` with the header and an empty `Unreleased` section; document the script in `DOCS.md`
    - _Requirements: 11.1, 11.2, 11.3, 11.4, 11.5, 11.6_

  - [x]* 7.2 Test the Release_Script
    - A bats-free shell test in `test/scripts/release_test.dart` runs the script in a temporary git repository: groups, tag, clean-tree refusal, bad version refusal, pre-release version
    - _Requirements: 11.2, 11.3, 11.4, 11.5_

  - [x] 7.3 Release `1.0.0-dev.0`
    - Run `scripts/release.sh 1.0.0-dev.0` after specs `001` to `003` are done and `scripts/check.sh` is green
    - _Requirements: 11.7_

- [x] 8. Checkpoint — foundation is green
  - Ensure `scripts/check.sh` passes; commit in logical steps (scaffold, move, shell, docs); ask the user if questions arise

## Notes

- Tasks marked with `*` are optional and can be skipped for a faster MVP, but the Property tests guard the structure and should run.
- Commit in Conventional Commits, English, no tool attribution; dependency changes in their own commit. Never push. The first tag is `v1.0.0-dev.0`, made by `scripts/release.sh` after specs 001 to 003.
- Run the Flutter toolchain after `git config --global --add safe.directory /opt/flutter` (skill `sandbox-flutter`); Drift codegen takes about 50 s, run it in the background.
- The iOS build and every on-device check are Martin's; the sandbox has no iOS.
- The two day boundaries (04:00 Board day, 03:00 logical day) stay separate; unifying them is a later decision.
- The Working_Name can change in one pass over the places in Requirement 9.1 plus the Dart package name.
- Moving files must keep `git mv`-style history only inside this new repository; QuestLog and TimeLog are not modified.
- Deviations from the plan, found while implementing: the app icon and the launch screen are still TimeLog's (the
  iOS project came from TimeLog); a new icon and the Quest launch colour (Requirement 9.6) are left for when the
  name is settled. The folder rule allows the QuestLog modules to import each other (Requirement 1.6), because the
  Board, the calendar and the XP engine are coupled. `ShellMenuScope` and `MenuButton` live in `ui_kit/`, so the
  QuestLog modules can place the button without importing the shell.
