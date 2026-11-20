# Implementation Plan: Legacy Import

## Overview

Add a Replace_Import of the QuestLog and TimeLog Export_Files to the App: a pure parser and planner, a transactional importer with count and foreign key verification, a typed SharedPreferences writer, and a Settings row with a confirmation and a report. Property tests run against an in-memory Database; fixtures come from the Legacy_Apps' own export code. The real-data run happens on Martin's files.

## Tasks

- [ ] 1. Parse and plan
  - [ ] 1.1 Write `ExportFile` and `ExportHeader`
    - `lib/database/import/export_file.dart`: `ExportFile.parse(String)` validates `format`, `formatVersion` (known: 1), `rowCounts`, `tables`; `preferences` optional
    - Throw `ImportFailure` with the kinds `notJson`, `wrongFormat`, `newerFormat`, `missingSection`
    - _Requirements: 1.2, 1.3, 1.4, 1.5_

  - [ ] 1.2 Write `ImportPlan`
    - `lib/database/import/import_plan.dart`: match table names to `db.allTables` and column names to the table's columns; throw `unknownTable` and `unknownColumn`
    - _Requirements: 1.6_

  - [ ]* 1.3 Write unit tests for parsing and planning
    - One test per refusal rule; a valid QuestLog and a valid TimeLog header
    - _Requirements: 9.2_

- [ ] 2. Importer
  - [ ] 2.1 Write `DatabaseImporter`
    - `lib/database/import/database_importer.dart`: transaction with `PRAGMA defer_foreign_keys = ON`, delete per planned table, batched insert with bound parameters, `PRAGMA foreign_key_check`, count check against Row_Counts, roll back on any failure
    - Decode `{"$blob": …}` to bytes; keep primary keys
    - `currentCounts` for the confirmation
    - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5, 3.6, 4.1, 4.2, 4.4_

  - [ ]* 2.2 Write property tests for the importer
    - **Property 1: Round trip**
    - **Property 2: Idempotence**
    - **Property 3: Atomicity**
    - **Property 4: Blob fidelity**
    - **Property 5: Counts match**
    - **Validates: Requirements 1.3, 1.4, 1.5, 1.6, 3.1, 3.2, 3.3, 3.5, 3.7, 4.1, 4.2, 4.3**

  - [ ] 2.3 Write the report types
    - `import_report.dart`: `ImportReport`, `TableResult`, `ImportFailure`, `ImportFailureKind`
    - _Requirements: 4.2, 4.3_

- [ ] 3. Checkpoint — importer is green
  - Ensure `scripts/check.sh` passes, ask the user if questions arise

- [ ] 4. Preferences and app-specific rules
  - [ ] 4.1 Write the preferences writer
    - `preferences_writer.dart`: `ignoredPreferenceKeys`, typed writes; failure becomes `ImportFailure(preferences)` after the commit
    - _Requirements: 6.2, 6.3, 6.5, 6.6_

  - [ ]* 4.2 Write the preferences property test
    - **Property 6: Ignored preferences**
    - **Validates: Requirements 6.2, 6.3, 6.5**

  - [ ] 4.3 Handle QuestLog seed rows and settings
    - Replacing `calendar_events` removes the rows seeded by `onCreate`; `app_state` import carries the language, theme and profile
    - _Requirements: 5.1, 5.2, 5.3_

  - [ ] 4.4a Accept the `zafling-export` format
    - Parser accepts it; the rules of a `timelog-export` apply to preferences; a round-trip test: export from the App, import into an empty Database, compare
    - _Requirements: 1.3, 7.1, 7.2_

  - [ ] 4.4 Handle TimeLog tables
    - Replace the five tables; skip `app_language` and `selected_theme` in preferences
    - _Requirements: 6.1, 6.3_

  - [ ]* 4.5 Write the app-specific tests with fixtures
    - Generate fixtures with the QuestLog and TimeLog export code on a populated database; commit them under `test/database/import/fixtures/`; assert table equality and no doubled seed rows
    - _Requirements: 5.1, 5.2, 6.1, 9.1_

- [ ] 5. Settings integration
  - [ ] 5.1 Add `file_picker` to `pubspec.yaml`
    - In its own `build:` commit
    - _Requirements: 1.1_

  - [ ] 5.2 Write the Settings row
    - `lib/settings/data/import_row.dart`: picker, confirmation (app, version, time, Row_Counts, rows to be deleted), report view, busy guard, cancel path
    - Strings with the prefix `import_` in both ARB files
    - _Requirements: 1.1, 2.1, 2.2, 2.3, 4.3_

  - [ ] 5.3 Wire the hooks from the Shell
    - `lib/settings/data/import_hooks.dart` supplies the preferences writer, `rescheduleAll()` of the Time_Module and the Quest_Module reconcile request; the Importer never starts by itself
    - _Requirements: 5.4, 6.4, 8.2, 8.3_

  - [ ]* 5.4 Write the widget test for the row
    - Confirm shows counts; cancel changes nothing; a failure shows its message
    - _Requirements: 2.1, 2.2, 9.2_

  - [ ]* 5.5 Write the isolation test
    - Extend `feature_imports_test.dart` so `lib/database/import/` imports no feature folder
    - _Requirements: 8.1_

- [ ] 6. Documentation and real data
  - [ ] 6.1 Write the migration guide
    - `DOCS.md` section "Migrating from TimeLog and QuestLog": export in both apps, transfer files, import, compare counts with the old apps' screens, keep the old apps until compared
    - _Requirements: 9.4_

  - [ ] 6.2 Add the real-data test
    - `@Tags(['real-data'])` test reads `/workspace/Zafling/.import/*.json`; `.import/` in `.gitignore`; skipped when the folder is empty
    - _Requirements: 9.3_

  - [ ] 6.3 Run the import on Martin's files
    - When Martin has put his two Export_Files into `.import/`, run the tagged test and write the counts into `.agents/runs/003/REPORT.md`
    - _Requirements: 9.3_

- [ ] 7. Checkpoint — import is verified
  - Ensure `scripts/check.sh` passes; tag `v0.3.0` on the version commit; list the items Martin must check on the iPhone (file picker, import of both files, counts against the old apps); ask the user if questions arise

## Notes

- Tasks marked with `*` are optional and can be skipped for a faster MVP, but the Property tests carry the safety guarantees.
- Table and column names from a file are matched against the Database schema and quoted; values are always bound parameters. Never build SQL from file values.
- Fixtures come from the frozen tags `v1.5.0` (QuestLog) and `v1.2.0` (TimeLog). The old repositories are read only.
- Real export files are personal data: never commit them, never print their content into reports, only counts.
- Conventional Commits, English, no tool attribution, never push.
- The importer is a one-off migration tool; a later spec may remove it together with the Settings row.
