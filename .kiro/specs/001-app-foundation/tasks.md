# Implementation Plan: App Foundation

## Overview

Create the Zafling project by copying QuestLog 1.5.0, rename it, regroup its files into feature folders, add the Shell with the Drawer and the `zafling://` deep links, and make `scripts/check.sh` green. The TimeLog features arrive in spec `002-time-tracking-port`; this spec leaves a Timer placeholder Destination that `002` replaces. Testing is the ported QuestLog suite plus new tests for the Shell, the Database and the import rule.

## Tasks

- [ ] 1. Scaffold the project
  - [ ] 1.1 Copy QuestLog into `/workspace/Zafling`
    - Copy `/workspace/QuestLog` without `.git`, `build/`, `.agents/`, `screenshots/` and `ios/`; keep `.design/`, `assets/`, `test/`, `drift_schemas/`
    - Copy `ios/` from `/workspace/TimeLog/timelog_app` at tag `v1.2.0` (Runner, `TimeLogWidgetExtension`, entitlements, notification sounds), then merge QuestLog's `CFBundleURLTypes` and `FlutterDeepLinkingEnabled` into `Info.plist`
    - The git repository and the author identity already exist
    - _Requirements: 1.1_

  - [ ] 1.2 Rename the package and the Working_Name
    - `pubspec.yaml`: `name: zafling`, version `0.1.0+1`, SDK constraint unchanged
    - Replace `package:questlog/` imports; rename `QuestlogApp`, `QuestlogDatabase`, `QuestlogPalette` to `ZaflingApp`, `AppDatabase`, `QuestPalette`
    - Display name, bundle identifier `com.jablecnik.zafling`, App Group `group.com.jablecnik.zafling` and URL scheme `zafling` in `ios/Runner/Info.plist`, `ios/Runner.xcodeproj`, both entitlements files and `app_name` in both ARB files
    - Rename the extension target and folder to `ZaflingWidgetExtension` and fix the Xcode project references
    - Placeholder app icon from QuestLog's `.design/icon`; keep the launch screen colour of QuestLog
    - iOS deployment target 18.0
    - _Requirements: 1.1, 9.1, 9.2, 9.3, 9.4_

  - [ ] 1.3 Create the empty feature folders and the scripts
    - Create the folders listed in Requirement 1.2 with a `.gitkeep`
    - Copy `scripts/check-structure.sh` from `tool-configs/templates/scripts/`; keep `scripts/check.sh` from QuestLog
    - _Requirements: 1.2, 1.3_

- [ ] 2. Regroup the files into feature folders
  - [ ] 2.1 Move shared code to `core/`, `database/` and `theme/`
    - `lib/core/{clock,errors,validation,board_day}.dart` stay; `lib/data/database.dart` becomes `lib/database/app_database.dart`; Drift table classes of all features are referenced from there
    - Move `database_export.dart` and `export_service.dart` to `lib/database/export/`
    - Move `lib/ui/theme/*` to `lib/theme/`
    - _Requirements: 1.2, 2.1_

  - [ ] 2.2 Move Quest_Module files to `lib/quests/`
    - Tables, models, mappers, `quest_service`, `mission_service`, `recurrence_service`, `xp_engine`, XP rules, cadence, board and mission screens, sheets, cards, hero and reward widgets, state files into `data/`, `domain/`, `services/`, `ui/`
    - Keep every directory at 15 files or fewer
    - _Requirements: 1.2, 3.1_

  - [ ] 2.3 Move Calendar_Module files to `lib/calendar/`
    - `lib/core/calendar/`, `lib/data/calendar/`, `lib/services/calendar/`, calendar screens, sheets and widgets, `calendar_state.dart`, `event_task_actions.dart`
    - _Requirements: 1.2, 3.2_

  - [ ] 2.4 Move Notes_Module files to `lib/notes/`
    - `lib/core/notes/`, `lib/data/notes/`, `lib/services/notes/`, notes and note editor screens, sheets, widgets, `notes_state.dart`
    - _Requirements: 1.2, 3.3_

  - [ ] 2.5 Move Settings to `lib/settings/`
    - `settings_screen.dart`, `export_row.dart`, `rule_row.dart`, `rules_section.dart`, `shortcut_guide.dart`, `settings_service.dart`, `preferences.dart`
    - _Requirements: 1.2, 6.1, 6.4_

  - [ ] 2.6 Move the tests to mirror `lib/` and fix imports
    - Move `test/` files and goldens; run `dart run build_runner build` and `flutter gen-l10n`
    - _Requirements: 3.4, 3.5_

  - [ ]* 2.7 Write the cross-feature import test
    - `test/architecture/feature_imports_test.dart` scans `lib/<feature>/**.dart` and fails when a file imports `lib/<other feature>/`
    - Fix any violation found by moving the shared piece into `core/`, `database/` or `theme/`
    - **Property 3: No feature imports another feature**
    - **Validates: Requirements 1.4, 1.5**

- [ ] 3. Checkpoint — moved code is green
  - Ensure `scripts/check.sh` passes with all QuestLog tests; list regenerated goldens, ask the user if questions arise

- [ ] 4. Shell, Drawer and deep links
  - [ ] 4.1 Add `Destination` and the deep-link parser
    - `lib/shell/destination.dart` with the enum from the design; `destinationFromUri`
    - `lib/shell/deep_link.dart` moved from QuestLog, scheme `zafling`, host or first path segment as the name
    - _Requirements: 5.1, 5.2, 5.4_

  - [ ]* 4.2 Write property tests for Destination and links
    - **Property 1: Every Destination is reachable**
    - **Property 2: Foreign links are ignored**
    - **Validates: Requirements 4.2, 5.1, 5.2, 5.4**

  - [ ] 4.3 Add the `AppDrawer`
    - Groups Time, Planning and Notes, App with the Destination list; labels from l10n; closes on selection
    - _Requirements: 4.2, 4.3_

  - [ ] 4.4 Rebuild `AppShell` around `Destination` and `IndexedStack`
    - Move the Reconciliation state machine, lifecycle observer, splash and reconcile banner unchanged
    - Initial Destination is `timer`, or the one of the launching link
    - The Timer Destination is a placeholder screen until spec `002` replaces it, and does not wait for the Reconciliation; the Quest Destinations show the splash until it is done
    - Host the reward overlay in `ZaflingApp.builder`
    - _Requirements: 4.1, 4.3, 4.4, 4.5, 4.6, 4.7, 5.3_

  - [ ]* 4.5 Write Shell widget tests
    - First screen is the Timer; Drawer lists all Destinations; selecting closes the Drawer; state of a Destination survives switching; a launching link opens its Destination
    - _Requirements: 4.1, 4.2, 4.3, 4.4, 5.3, 10.3, 10.4_

  - [ ] 4.5a Add `ShellMenuButton` to every Destination header
    - Place it in the existing header of Board, Missions, Calendar, Notes, Settings; the Timer, History and Statistics headers are done in spec `002`; hide it on pushed routes
    - _Requirements: 4.8, 4.9_

  - [ ] 4.6 Update the shortcut guide in Settings
    - List all eight links with the `zafling://` scheme; keep the guide's steps (Open URL, Add to Home Screen)
    - _Requirements: 5.5_

- [ ] 5. Theme, settings and localisation
  - [ ] 5.1 Add per-Destination themes
    - `lib/theme/shell_theme.dart` with `themeForDestination`; Quest palettes from QuestLog; the Time palettes are plugged in by spec `002` (until then the Timer placeholder uses the Quest palettes)
    - Wrap each Destination, the Drawer and the status bar style in the matching `Theme`
    - _Requirements: 7.1, 7.2, 7.3, 7.4_

  - [ ] 5.2 Settings groups and shared language and theme
    - Keep the QuestLog groups; add empty-group slots for the Time_Module settings that spec `002` fills
    - `language` and `themeMode` live in `app_state`; `ZaflingApp` reads both
    - _Requirements: 6.1, 6.2, 6.3, 6.6_

  - [ ]* 5.3 Write the ARB parity test
    - Every key exists in `app_cs.arb` and `app_en.arb`; keys of merged features carry their feature prefix
    - _Requirements: 8.1, 8.3, 8.4_

- [ ] 6. Database, export, docs and gate
  - [ ] 6.1 Reset the schema to version 1
    - New `schemaVersion = 1` with `onCreate: createAll`; no upgrade steps; delete the QuestLog schema dumps and write the new `drift_schemas/drift_schema_v1.json`
    - File name `zafling.sqlite`; calendar seed runs once on create
    - _Requirements: 2.1, 2.4, 2.5, 2.6_

  - [ ]* 6.2 Write the Database tests
    - Empty Database has every expected table; no two tables share a name; the seed runs once
    - **Property 4: Table names are unique**
    - **Validates: Requirements 2.2, 2.3, 2.5, 10.2**

  - [ ] 6.2a Extend the export
    - `lib/database/export/` writes all tables and the SharedPreferences (as in TimeLog's `ExportService`), format `zafling-export`, file `zafling-export-YYYY-MM-DD.json`
    - Port the QuestLog and TimeLog export tests; add one for the preferences
    - _Requirements: 6.4, 6.5_

  - [ ] 6.3 Write the project documents
    - `CLAUDE.md`, `README.md`, `DOCS.md`, `FEATURES.md` in English: layout, commands, the import rule, the two palettes, the Working_Name locations
    - Add `.gitignore` for `build/`, `.dart_tool/`, `ios/Pods`, `.import/`
    - _Requirements: 1.6, 8.2, 9.1_

  - [ ] 6.4 Rename-check
    - Grep the project for `questlog`, `Questlog`, `QuestLog` outside the Quest_Module's user-visible name; list the remaining hits in the checkpoint report
    - _Requirements: 9.1, 9.4_

- [ ] 7. Checkpoint — foundation is green
  - Ensure `scripts/check.sh` passes; commit in logical steps (scaffold, move, shell, docs); ask the user if questions arise

## Notes

- Tasks marked with `*` are optional and can be skipped for a faster MVP, but the Property tests guard the structure and should run.
- Commit in Conventional Commits, English, no tool attribution; dependency changes in their own commit. Never push. Tag `v0.1.0` on the version commit.
- Run the Flutter toolchain after `git config --global --add safe.directory /opt/flutter` (skill `sandbox-flutter`); Drift codegen takes about 50 s, run it in the background.
- The iOS build and every on-device check are Martin's; the sandbox has no iOS.
- The two day boundaries (04:00 Board day, 03:00 logical day) stay separate; unifying them is a later decision.
- The Working_Name can change in one pass over the places in Requirement 9.1 plus the Dart package name.
- Moving files must keep `git mv`-style history only inside this new repository; QuestLog and TimeLog are not modified.
