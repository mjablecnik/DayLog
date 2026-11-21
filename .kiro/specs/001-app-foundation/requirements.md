# Requirements Document

## Introduction

DayLog is a single personal Flutter app for iOS that replaces two existing apps by Martin: TimeLog (`/workspace/TimeLog/timelog_app`, tag `v1.2.0`) and QuestLog (`/workspace/QuestLog`, tag `v1.5.0`). The name DayLog is a working name; it lives in exactly one place per layer (see Requirement 9) so it can be renamed cheaply.

This spec creates the new project and everything that QuestLog already provides: Quests, Missions, the Calendar, Notes, Settings, the data export and the deep links. QuestLog is the base of the new project, because it already has the structure the new app needs (Riverpod 3, one Drift database, feature folders, l10n, structure check). This spec also builds the Shell: the Timer is the first screen, and the other destinations are reached from a navigation drawer and through deep links.

This is a pure move. No new functionality is added: no Today page, no XP from the timer, no mini timer bar, no AI, no journal. Specs `002-time-tracking-port` (TimeLog features) and `003-legacy-import` (data from the two old apps) build on this one. The old apps stay untouched as archive and backup.

## Glossary

- **App**: The new Flutter project at `/workspace/DayLog`, Dart package `daylog`.
- **Quest_Module**: The Quests, Missions, XP, recurring rules and Quest Deadline features moved from QuestLog.
- **Calendar_Module**: The Calendar feature moved from QuestLog.
- **Notes_Module**: The Notes feature moved from QuestLog.
- **Time_Module**: The time tracking features moved from TimeLog (specified in `002-time-tracking-port`).
- **Shell**: The root screen that hosts the destinations, the navigation drawer, the splash and the Reconciliation.
- **Destination**: One reachable page of the App: Timer, History, Statistics, Quests, Missions, Calendar, Notes, Settings.
- **Bottom_Bar**: The bottom navigation bar with five tabs: Timer, Quests, Calendar, Notes, Settings.
- **Drawer**: The side panel that lists the complete navigation: every Destination, including the tabs of the Bottom_Bar.
- **Deep_Link**: A URL `daylog://<destination>` that opens a Destination.
- **Database**: The single Drift database of the App, stored in one SQLite file.
- **Legacy_App**: TimeLog or QuestLog in the frozen versions named above.
- **Structure_Check**: `scripts/check-structure.sh`, which fails when a directory holds more than 15 source files.
- **Time_Preferences**: The SharedPreferences keys of the Time_Module (defined in spec `002-time-tracking-port`).
- **Row_Counts**, **Importer**: As defined in spec `003-legacy-import`.
- **UI_Kit**: The folder `lib/ui_kit/` with the shared widgets (icons, sheets, snackbar, segmented control, form helpers).
- **Changelog**: The file `CHANGELOG.md`, a list of released versions with their changes.
- **Release_Script**: `scripts/release.sh`, which bumps the version, updates the Changelog, commits and tags.
- **Working_Name**: The string `DayLog` and its derivatives (package name, bundle identifier, URL scheme, display name).

## Requirements

### Requirement 1: Project scaffold

**User Story:** As the developer, I want a new project with a fixed feature-first layout, so that new features can be added later without reorganising.

#### Acceptance Criteria

1. THE App SHALL be a Flutter project in `/workspace/DayLog` with its own git repository and the author identity `Martin Jablečník <martin.jablecnik@email.cz>`.
2. THE App SHALL contain the folders `lib/core`, `lib/database`, `lib/ui_kit`, `lib/shell`, `lib/theme`, `lib/l10n`, `lib/settings`, `lib/quests`, `lib/calendar`, `lib/notes` and `lib/time_tracking`, created before any code is moved into them.
3. THE App SHALL contain `scripts/check.sh` that runs analysis, all tests and the Structure_Check, and `scripts/check-structure.sh` copied from `tool-configs/templates/scripts/`.
4. THE folders `core`, `theme`, `ui_kit` and `l10n` SHALL NOT import a feature folder.
5. THE folder `time_tracking` SHALL import only itself, `core`, `theme`, `ui_kit`, `l10n` and `database`.
6. THE folders `quests`, `calendar`, `notes` and `settings` (the QuestLog modules, one product that grew together) SHALL NOT import `time_tracking` or `shell`; imports among them are allowed.
7. IF an import breaks Criterion 4, 5 or 6, THEN THE App test suite SHALL fail.
8. THE App SHALL contain `CLAUDE.md`, `README.md`, `DOCS.md` and `FEATURES.md` in English, describing the layout in this spec.

### Requirement 2: One Database

**User Story:** As the user, I want one local database for everything, so that the data of both old apps lives together and is backed up as one unit.

#### Acceptance Criteria

1. THE App SHALL open exactly one Drift Database, stored in the file `daylog.sqlite` in the application documents directory.
2. THE Database SHALL contain every table of the Legacy_Apps under its original table name and columns.
3. IF a table name occurs in both Legacy_Apps, THEN THE App SHALL fail its test suite until the collision is resolved in this spec.
4. THE Database SHALL start at schema version 1 and record every later change as a Drift migration with a schema dump in `drift_schemas/`.
5. WHEN the Database is created, THE Calendar_Module SHALL seed its holidays, notable days and name days once, in `onCreate` and nowhere else, so a deleted holiday stays deleted.
6. THE App SHALL NOT read or write the database files of the Legacy_Apps.

### Requirement 3: Quest, Calendar and Notes behaviour is unchanged

**User Story:** As the user, I want Quests, Missions, the Calendar and Notes to work exactly as they do in QuestLog 1.5.0, so that moving does not cost me anything.

#### Acceptance Criteria

1. THE Quest_Module SHALL provide Quests with four effort tiers (10, 25, 50, 100 XP), Missions, the Board sections Today and Todo, XP and levels, recurring rules, the Reconciliation and the Quest Deadline exactly as in QuestLog 1.5.0.
2. THE Calendar_Module SHALL provide the month overview, day sheet, event detail, event form, search, type filter, eleven event types, repeats, multi-day bars, address history and the Board link of an event exactly as in QuestLog 1.5.0.
3. THE Notes_Module SHALL provide folders, the WYSIWYG editor, automatic saving, rename, move, delete, the 30-day Trash and the read-only Trash preview exactly as in QuestLog 1.5.0.
4. WHEN the QuestLog test suite is ported, THE App SHALL pass every ported test without weakening an assertion.
5. WHEN a golden test of a moved screen is ported, THE App SHALL match the QuestLog golden image unless the Shell chrome around it changed, in which case the golden SHALL be regenerated and listed in the checkpoint report.

### Requirement 4: Shell and navigation

**User Story:** As the user, I want the Timer on the first screen and every other page one tap away, so that the most frequent action is immediate.

#### Acceptance Criteria

1. WHEN the App starts, THE Shell SHALL show the Timer Destination first, after the splash.
2. THE Shell SHALL provide a Bottom_Bar with the tabs Timer, Quests, Calendar, Notes and Settings, in this order.
3. THE Shell SHALL provide a Drawer that lists every Destination: Timer, History and Statistics (group Time), Quests, Missions, Calendar and Notes (group Planning), and Settings.
4. WHEN the user selects a tab of the Bottom_Bar, THE Shell SHALL show its Destination.
5. WHEN the user selects a Destination in the Drawer, THE Shell SHALL show it and close the Drawer.
6. WHILE the Destination shown is not a tab, THE Bottom_Bar SHALL mark the tab it belongs to: Timer for History and Statistics, Quests for Missions.
7. THE Shell SHALL keep the state of a Destination while another is shown, so a running Timer, an open note and a calendar month survive switching.
8. WHILE the Reconciliation of the Quest_Module has not finished for the first time, THE Shell SHALL show the splash, and the Time_Module SHALL NOT wait for it.
9. THE Shell SHALL host the reward overlay above the Navigator, as QuestLog does.
10. THE Shell SHALL NOT show a mini timer, a Today page or any element that is not in a Legacy_App.
11. THE header of every Destination SHALL contain a menu button that opens the Drawer, placed in the header the screen already has, so no Destination gains a new bar.
12. WHILE a Destination has a pushed route open (Mission detail, note editor, event form), THE Shell SHALL keep the back button of that route and SHALL NOT show the menu button on it.

### Requirement 5: Deep links

**User Story:** As the user, I want to open each page from an iOS Shortcut, so that I can put pages on the Home Screen.

#### Acceptance Criteria

1. WHEN a link `daylog://timer`, `daylog://history`, `daylog://statistics`, `daylog://quests`, `daylog://missions`, `daylog://calendar`, `daylog://notes` or `daylog://settings` opens the App, THE Shell SHALL show that Destination.
2. IF a link has another scheme or an unknown host, THEN THE Shell SHALL ignore it and keep the current Destination.
3. WHEN the App is launched by a Deep_Link, THE Shell SHALL show the Destination of the link and not the Timer.
4. THE App SHALL NOT register the schemes `questlog` or `timelogapp`, so the Legacy_Apps keep working while installed beside it.
5. THE Settings Destination SHALL keep the Home Screen shortcut guide of QuestLog, updated to the new scheme and the full Destination list.

### Requirement 6: Settings

**User Story:** As the user, I want one Settings page, so that language, theme and data are set once for the whole App.

#### Acceptance Criteria

1. THE Settings Destination SHALL contain the groups of QuestLog Settings (Profile, Language, Appearance, rules for recurring Missions, Data, About) and the settings of TimeLog (reminders, recurring reminders, notification permission), each in its own labelled group.
2. THE App SHALL keep one language setting (Czech, English or the device language) that applies to every Destination.
3. THE App SHALL keep one theme setting (light, dark or the device setting) that applies to every Destination.
4. THE Settings Destination SHALL keep the Data group with one export that writes every table of the Database and the Time_Preferences as one JSON file with `format` equal to `daylog-export`.
5. WHEN the export is built, THE App SHALL write the header and the Row_Counts in the layout of the Legacy_App exports, so one Importer reads all three formats.
6. WHEN the language is changed, THE App SHALL update every visible screen without restarting.

### Requirement 7: Appearance

**User Story:** As the user, I want the moved pages to look as they do now, so that the move does not restyle anything.

#### Acceptance Criteria

1. THE App SHALL provide one theme, the blue one of QuestLog, in a dark variant (`guildBoard`) and a light variant (`daylight`), and every Destination, including the Time_Module, SHALL use it.
2. THE App SHALL define themes in a registry of theme definitions, each with an id, a label, a light palette and a dark palette, so that a further theme is added by one new definition and no screen changes.
3. THE Shell SHALL apply the palette of the selected theme and brightness to the Drawer, the status bar and the system bars.
4. THE App SHALL read the active theme id from one provider that returns the blue theme until a second theme exists.
5. THE App SHALL load the fonts of both Legacy_Apps from bundled assets, register the licences of both font families, and fetch nothing from the network at runtime.
6. THE App SHALL use the day boundaries of the Legacy_Apps unchanged: the Board day of the Quest_Module starts at 04:00 and the logical day of the Time_Module at 03:00.

### Requirement 8: Localisation

**User Story:** As the user, I want the UI in Czech and English, so that it matches both old apps.

#### Acceptance Criteria

1. THE App SHALL provide every user-facing string in Czech and English through generated `AppLocalizations`.
2. THE App SHALL write code, comments, documentation and commit messages in English.
3. WHEN the ARB files of the Quest_Module and the Time_Module are merged, THE App SHALL prefix each key with its feature, so no key occurs twice.
4. IF a key is missing in one language, THEN THE App SHALL fail its test suite.

### Requirement 9: Identity and iOS target

**User Story:** As the user, I want the new app to install beside the old ones, so that I can compare and fall back.

#### Acceptance Criteria

1. THE App SHALL use a bundle identifier, URL scheme, display name and app icon derived from the Working_Name, each defined in one place (`pubspec.yaml`, `ios/Flutter/*.xcconfig`, `l10n` key `app_name`, `ios/Runner/Info.plist`).
2. THE App SHALL set the iOS deployment target to 18.0.
3. THE App SHALL use an App Group derived from the bundle identifier for data shared with the Live Activity extension.
4. THE App SHALL NOT share a bundle identifier, App Group or keychain item with a Legacy_App.
5. THE iOS project SHALL be the `ios/` folder of TimeLog `v1.2.0`, renamed, because it already holds the Live Activity extension target, the entitlements and the notification sounds; the URL scheme and deep-link entries of QuestLog are merged into its `Info.plist`.
6. THE App SHALL use a placeholder app icon until the user supplies one, and the launch screen SHALL use the Quest_Module launch colour.

### Requirement 10: Quality gate

**User Story:** As the developer, I want one command that proves the project is healthy, so that the App stays stable when it grows.

#### Acceptance Criteria

1. WHEN `scripts/check.sh` runs on a clean checkout, THE App SHALL report no analysis issue, no failing test and no Structure_Check violation.
2. THE App SHALL contain a test that opens the Database empty and asserts every expected table.
3. THE App SHALL contain a test that asserts the Drawer lists every Destination and that every Deep_Link opens its Destination.
4. THE App SHALL contain a test that asserts the first screen is the Timer.

### Requirement 11: Changelog and releases

**User Story:** As the developer, I want a changelog that updates itself when I raise the version, so that every release has its history without extra work.

#### Acceptance Criteria

1. THE App SHALL contain a Changelog in English in the Keep a Changelog layout, with an `Unreleased` section and one section per version, newest first.
2. WHEN the Release_Script runs with a version, THE Release_Script SHALL write the commits since the previous tag into a new Changelog section grouped by Conventional Commit type (Features, Fixes, Other), and leave `Unreleased` empty.
3. WHEN the Release_Script runs, THE Release_Script SHALL set the version in `pubspec.yaml` (the one source of the version), commit the Changelog and the version as `chore: bump version to <version>`, and create the annotated tag `v<version>` on that commit.
4. IF the working tree is not clean or the version is not a valid semantic version, THEN THE Release_Script SHALL stop without changing anything.
5. THE Release_Script SHALL accept a pre-release version such as `1.0.0-dev.0`.
6. THE Release_Script SHALL NOT push and SHALL NOT add a tool attribution to the commit or the tag.
7. THE first release of the App SHALL be `1.0.0-dev.0`.
