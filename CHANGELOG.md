# Changelog

All notable changes to DayLog are listed here, newest first. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and the versions follow
[Semantic Versioning](https://semver.org). `scripts/release.sh` adds a section for
every release from the commit messages.

## [Unreleased]

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

