# Requirements Document

## Introduction

This spec brings the data of the two old apps into Zafling. Each Legacy_App has a Settings action "Export data" (QuestLog 1.5.0, TimeLog 1.2.0) that writes one JSON file with every table as stored plus a header with row counts; TimeLog also exports its SharedPreferences. The App reads those files and loads them into its Database.

The import is a one-off migration tool. It is part of Settings → Data so that it can run on the iPhone, where the exports are, and it can be removed in a later spec once both Legacy_Apps are retired. It adds no other function. It depends on specs `001-app-foundation` and `002-time-tracking-port`, because the target tables must exist.

## Glossary

- **Retired_Column**: A column that a Legacy_App wrote and the Database no longer has, listed in `retiredColumns` of the Importer.
- **Importer**: The code in `lib/database/import/` that reads an Export_File and writes the Database.
- **Export_File**: A JSON file with `format` equal to `questlog-export`, `timelog-export` or `zafling-export`, produced by a Legacy_App or by the App itself.
- **Export_Header**: The keys `format`, `formatVersion`, `app`, `appVersion`, `schemaVersion`, `exportedAt`, `rowCounts` of an Export_File.
- **Row_Counts**: The map from table name to the number of rows in the Export_File.
- **Import_Report**: The result of an import: per table the rows read, rows written and rows expected.
- **Replace_Import**: An import that deletes all rows of every table present in the Export_File and inserts the rows of the file, in one transaction.
- **Time_Preferences**: The `preferences` map of a `timelog-export` file.
- **Settings_Data_Group**: The Data group of the Settings Destination.
- **Database**: As defined in spec `001-app-foundation`.
- **Legacy_App**, **Quest_Module**: As defined in spec `001-app-foundation`.
- **Time_Module**: As defined in spec `002-time-tracking-port`.

## Requirements

### Requirement 1: Accepting a file

**User Story:** As the user, I want to choose an export file in the App, so that I can load my old data on the iPhone.

#### Acceptance Criteria

1. THE Settings_Data_Group SHALL provide an action "Import data" that opens the system file picker for a `.json` file.
2. WHEN the user picks a file, THE Importer SHALL read it and validate the Export_Header before changing anything.
3. IF `format` is not `questlog-export`, `timelog-export` or `zafling-export`, THEN THE Importer SHALL refuse the file and leave the Database unchanged.
4. IF `formatVersion` is greater than the highest version the Importer knows, THEN THE Importer SHALL refuse the file and leave the Database unchanged.
5. IF the file is not valid JSON or lacks `tables` or `rowCounts`, THEN THE Importer SHALL refuse the file and leave the Database unchanged.
6. IF the file names a table the Database does not have, or a column a table does not have, THEN THE Importer SHALL refuse the file, name the table or column, and leave the Database unchanged, except for a retired column.
7. THE Importer SHALL skip the values of a retired column and SHALL NOT report them as an error; the retired columns are `app_state.display_font`.

### Requirement 2: Confirmation

**User Story:** As the user, I want to see what an import replaces before it happens, so that I do not overwrite data by mistake.

#### Acceptance Criteria

1. WHEN a valid file is read, THE Settings_Data_Group SHALL show the source app, its version, the export time and the Row_Counts, and ask for confirmation.
2. WHEN the user cancels, THE Importer SHALL NOT change the Database or the Time_Preferences.
3. WHEN a table to be replaced already holds rows added by the user, THE confirmation SHALL state the number of rows that will be deleted.

### Requirement 3: Writing the data

**User Story:** As the user, I want every row of my old app in the new one, so that I lose nothing.

#### Acceptance Criteria

1. WHEN the user confirms, THE Importer SHALL perform a Replace_Import in one transaction.
2. THE Importer SHALL insert every row with its original values, including primary keys, so that references between rows stay valid.
3. THE Importer SHALL decode a value `{"$blob": "<base64>"}` into bytes and write every other JSON value with its SQLite type unchanged.
4. THE Importer SHALL defer foreign key checks inside the transaction and run a foreign key check before it commits.
5. IF the foreign key check reports a violation, THEN THE Importer SHALL roll back the transaction and report the violating table.
6. WHEN the transaction commits, THE Database SHALL hold the imported rows and the sequences of autoincrement tables SHALL continue above the highest imported key.
7. WHEN an Export_File is imported twice, THE Database SHALL be identical to the state after the first import.

### Requirement 4: Verification

**User Story:** As the user, I want proof that the counts match, so that I can trust the import.

#### Acceptance Criteria

1. WHEN the rows are written, THE Importer SHALL compare the number of rows in each imported table with its entry in the Row_Counts.
2. IF any count differs, THEN THE Importer SHALL roll back the transaction and report the table, the expected and the actual count.
3. WHEN the import succeeds, THE Importer SHALL return an Import_Report and THE Settings_Data_Group SHALL show it.
4. THE Importer SHALL NOT delete or alter the Export_File.

### Requirement 5: QuestLog export

**User Story:** As the user, I want my Quests, Missions, Calendar, Notes and settings back, so that QuestLog continues in the App.

#### Acceptance Criteria

1. WHEN a `questlog-export` file is imported, THE Importer SHALL replace `missions`, `quests`, `recurring_rules`, `rule_quests`, `app_state`, `note_nodes`, `calendar_events`, `calendar_skipped_dates`, `calendar_completions` and `calendar_addresses`.
2. WHEN `calendar_events` is replaced, THE Importer SHALL remove the rows that the first start seeded, so holidays, notable days and name days are not doubled.
3. WHEN `app_state` is replaced, THE App SHALL use the imported language, theme and profile.
4. WHEN the import has finished, THE Quest_Module SHALL run its Reconciliation and show the imported XP and level.

### Requirement 6: TimeLog export

**User Story:** As the user, I want my entries, reminders and settings back, so that TimeLog continues in the App.

#### Acceptance Criteria

1. WHEN a `timelog-export` file is imported, THE Importer SHALL replace `time_entries`, `recurring_reminders`, `completion_records`, `task_projects` and `tasks`.
2. WHEN a `timelog-export` file is imported, THE Importer SHALL write the Time_Preferences into SharedPreferences with their types (string, int, double, bool, string list) after the transaction has committed.
3. THE Importer SHALL NOT write the Time_Preferences keys `app_language` and `selected_theme`.
4. WHEN the Time_Preferences hold reminder settings, THE Time_Module SHALL reschedule the notifications after the import.
5. THE Importer SHALL NOT write the Time_Preferences keys of a pending reminder tap (`pending_reminder_action_id`, `handled_launch_reminder_id`) or of the persisted timer (every key that starts with `timer_`), because a running timer of another install means nothing here.
6. IF writing the SharedPreferences fails, THEN THE Importer SHALL report it and leave the Database rows imported.

### Requirement 7: Zafling export

**User Story:** As the user, I want to restore a backup made by the App itself, so that a new phone does not lose data.

#### Acceptance Criteria

1. WHEN a `zafling-export` file is imported, THE Importer SHALL replace every table named in the file and write the Time_Preferences with the same rules as for a `timelog-export` file.
2. WHEN a `zafling-export` file contains `app_language` or `selected_theme`, THE Importer SHALL ignore them, because the language and theme live in `app_state`.

### Requirement 8: Isolation

**User Story:** As the developer, I want the importer outside the features, so that it can be deleted when it is no longer needed.

#### Acceptance Criteria

1. THE Importer SHALL live in `lib/database/import/` and SHALL NOT import a feature folder.
2. THE Importer SHALL receive the SharedPreferences writer and the post-import hooks (reschedule, reconcile) as parameters supplied by the Shell.
3. THE Importer SHALL NOT be called at start-up and SHALL run only on a user action.

### Requirement 9: Proof on real data

**User Story:** As the user, I want to know the import works on my real data before I stop using the old apps.

#### Acceptance Criteria

1. THE App SHALL contain tests that import fixture Export_Files built by the Legacy_Apps' own export code and compare every table, row by row, with the source.
2. THE App SHALL contain a test per refusal rule of Requirement 1 and per rollback rule of Requirements 3 and 4.
3. WHEN Martin provides real Export_Files, THE Importer SHALL import them in a test run on the development machine with matching Row_Counts, without the files being committed.
4. THE import documentation SHALL list the steps: export in both Legacy_Apps, transfer the files, import in the App, compare the counts with the Legacy_Apps' screens, and keep the Legacy_Apps installed until the comparison is done.
