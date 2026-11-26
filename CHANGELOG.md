# Changelog

All notable changes to DayLog are listed here, newest first. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and the versions follow
[Semantic Versioning](https://semver.org). `scripts/release.sh` adds a section for
every release from the commit messages.

## [Unreleased]

## [1.0.0] - 2026-11-26

### Features

- show a day strip and pause rows in History (time_tracking)
- compute history gaps and the day strip range (time_tracking)
- let entries be moved to another day and run past midnight (time_tracking)
- never store overlapping time entries (time_tracking)

### Other

- docs(design): keep the history timeline mockups
- docs(specs): add spec 007 for the History day strip and pause rows


## [1.0.0-dev.4] - 2026-11-23

### Features

- group the drawer in three sections: activity, tasks and goals, organization (shell)
- add the activity type course (time_tracking)
- add the activity types dance and doing nothing (time_tracking)
- bring back the search and filter buttons in the header (calendar)

### Fixes

- shorten the AI consultation subtype so it fits its segment (time_tracking)
- make the month pager less sensitive to up and down strokes (calendar)
- make the Skip button tappable on its text only (time_tracking)
- let a sheet scroll with the keyboard open and hide it on a tap outside a field (ui_kit)


## [1.0.0-dev.3] - 2026-11-22

### Features

- switch off the add button in the month header (calendar)
- scroll the level card with the Board and Missions lists (quests)
- list notes by their full name only (notes)
- add an experiment to try four styles of the History type tag (settings)
- scroll the day navigator away with History and Statistics (time_tracking)
- show today again whenever History or Statistics opens (time_tracking)
- turn the drawer into one flat list with two sections (shell)
- move the add button to the header and let the month fill the screen (calendar)
- offer gaming, doctor, office and hairdresser instead of date (calendar)
- make the description optional for meals (time_tracking)
- scroll the sheet buttons with the body while the keyboard is open (ui_kit)
- draw segmented controls lower than their tap area (ui_kit)

### Fixes

- keep the sheet body from being rebuilt when the keyboard opens (ui_kit)
- centre a single tab in the bottom bar (shell)
- never store an entry that ends before it starts (time_tracking)
- remove the hidden tap padding between rows of choice chips (ui_kit)

### Other

- test(goldens): regenerate the calendar goldens after removing the header add button
- test(goldens): regenerate the goldens after the layout changes


## [1.0.0-dev.2] - 2026-11-22

### Features

- scroll the level card with the Board and Missions lists (quests)
- list notes by their full name only (notes)
- add an experiment to try four styles of the History type tag (settings)
- scroll the day navigator away with History and Statistics (time_tracking)
- show today again whenever History or Statistics opens (time_tracking)
- turn the drawer into one flat list with two sections (shell)
- move the add button to the header and let the month fill the screen (calendar)
- offer gaming, doctor, office and hairdresser instead of date (calendar)
- make the description optional for meals (time_tracking)
- scroll the sheet buttons with the body while the keyboard is open (ui_kit)
- draw segmented controls lower than their tap area (ui_kit)

### Fixes

- centre a single tab in the bottom bar (shell)
- never store an entry that ends before it starts (time_tracking)
- remove the hidden tap padding between rows of choice chips (ui_kit)

### Other

- test(goldens): regenerate the goldens after the layout changes


## [1.0.0-dev.1] - 2026-11-22

### Features

- add the licences page and the About group (settings)
- restyle statistics, history, dialogs and reminder sheets (time-tracking)
- show note rows, folder counts and the add sheet as in the redesign (notes)
- match calendar screens and event forms to the redesign (calendar)
- match mission, board and quest sheet screens to the redesign (quests)
- add shared text field and step button, fix segmented control and icons (ui-kit)
- redesign DayLog around module navigation
- add a back button to History and Statistics (time-tracking)
- use the app blue in the Live Activity and end stale activities (ios)
- add a wide add-event button to the day sheet (calendar)
- list every page in the drawer (shell)

### Fixes

- keep the date on one line under the title (board)
- show the version from pubspec.yaml (settings)
- take the native timer texts from the ARB files (i18n)
- start the app when no widget listens for the settings yet

### Other

- docs: record the resolution of the redesign QA list
- test(goldens): regenerate the screen goldens after the redesign fixes
- test: update e2e and accessibility tests for the redesign fixes
- chore: update .gitignore to include screenshots directory
- docs(spec): add redesign specs 004-006 and their visual reference
- build: drop the unused cupertino_icons dependency
- chore(l10n): drop the strings no code uses any more
- refactor: remove functions nothing calls
- refactor(time-tracking): remove the pre-fill draft of the description
- chore(l10n): drop the strings of the removed reminder and button
- refactor(timer): remove the pre-fill description button
- refactor(settings): group the recurring reminders and the testing tools
- refactor(settings): open the Home Screen shortcut guide on its own page
- refactor(time-tracking): remove the daily start-the-timer reminder
- refactor(settings): open recurring missions and testing tools on their own pages
- refactor(ui): put the menu button in one shared screen header
- docs: refresh the Settings and drawer screenshots
- docs: document the texts passed to the native timer code
- refactor: rename the app from Zafling to DayLog
- docs: describe startup.dart and the rule to run the app after startup changes
- refactor: move the startup out of main into a tested buildApp
- docs: describe running the Linux app under Xvfb
- refactor: remove the Tasks of TimeLog with their data


## [1.0.0-dev.0] - 2026-11-21

### Features

- add the release script and the changelog
- import an export file from the Settings data group (settings)
- import the export files of QuestLog, TimeLog and the app (database)
- export the preferences with the tables (database)
- move the TimeLog features into the app (time-tracking)
- bottom bar with five tabs, side drawer and daylog:// deep links (shell)

### Fixes

- label the timer controls and drop the Sora font references (time-tracking)
- open the reminder screen under Riverpod 3 and add smoke tests of the time pages (time-tracking)

### Other

- docs: update the cleanup list and tick the checkpoints
- test: mirror every test under the folder of the code it covers
- docs(specs): mark the implemented tasks and note where the plan changed
- docs: record how the time tracking port differs from TimeLog
- docs: describe the merged app in README, FEATURES, DOCS and CLAUDE.md
- refactor(theme): add the theme registry and rename the palette and mode types
- test(time-tracking): mirror the tests under the feature folders
- build: add file_picker for choosing an export file
- refactor: remove dead time tracking code and unused translation keys
- refactor: move the database and clock providers out of the quest providers
- build: add the packages of the time tracking feature
- refactor(database): start the schema at version 1 and drop the migration code
- docs: start the refactoring notes
- refactor: rename the package to daylog and group the code into feature folders
- chore: copy QuestLog 1.5.0 and the TimeLog iOS project as the base
- docs: add the initial specs for merging TimeLog and QuestLog

