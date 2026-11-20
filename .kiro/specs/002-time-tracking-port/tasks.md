# Implementation Plan: Time Tracking Port

## Overview

Move the TimeLog 1.2.0 features into `lib/time_tracking/` of Zafling, add the Time_Module tables to the Database, port the native iOS code with new identifiers, and replace the Timer placeholder of the Shell. Behaviour stays identical; tests are ported alongside the code they cover, and a checkpoint report lists every non-trivial difference from the TimeLog original.

## Tasks

- [ ] 1. Data layer
  - [ ] 1.1 Move the table classes
    - Copy `time_entry.dart`, `recurring_reminder.dart`, `completion_record.dart`, `task.dart`, `task_project.dart`, `stats_data.dart` into `lib/time_tracking/data/`
    - Add the five tables to `AppDatabase`; keep schema version 1; regenerate Drift code and the schema dump
    - _Requirements: 7.1, 7.2_

  - [ ] 1.2 Move `database_service.dart`, `task_service.dart`, `project_service.dart`
    - Point them at `AppDatabase`; keep method names and SQL behaviour
    - _Requirements: 2.4, 2.5, 7.2_

  - [ ]* 1.3 Port the data and service tests
    - Port `task_service_*_property_test.dart`, `task_providers_*_property_test.dart`, `test/data/`, `test/services/` with imports fixed
    - _Requirements: 10.1_

- [ ] 2. Domain, timer and native channels
  - [ ] 2.1 Move domain files
    - `activity_types.dart`, `config.dart`, `date_format_utils.dart`, `active_days_utils.dart`, `extensions.dart` into `lib/time_tracking/domain/`
    - _Requirements: 1.5, 2.1, 2.2, 3.1_

  - [ ] 2.2 Move `timer_service.dart`, `alarm_service.dart`, `notification_service.dart`, `live_activity_channel.dart`, `platform_channel.dart`
    - Keep the freezed file; add `audioplayers`, `flutter_local_notifications`, `timezone`, `flutter_timezone`, `freezed_annotation`, `json_annotation`, `sqlite3_flutter_libs` to `pubspec.yaml` in one separate `build:` commit before the move; run `build_runner`
    - Import `flutter_riverpod/legacy.dart` where `StateNotifier`/`StateProvider` is used
    - Guard channel calls so Linux and tests do not fail
    - _Requirements: 1.1, 1.2, 1.4, 6.4, 6.5, 6.7_

  - [ ]* 2.3 Port the timer tests
    - `timer_service_test.dart`, `test/core/`, `date_format_utils_property_test.dart`
    - **Property 1: Timer state survives a restart**
    - **Property 2: Logical day boundary**
    - **Validates: Requirements 1.4, 3.1**

- [ ] 3. Checkpoint — data and timer are green
  - Ensure `scripts/check.sh` passes; list differences from the TimeLog originals, ask the user if questions arise

- [ ] 4. Providers, palette and settings bridge
  - [ ] 4.1 Move the providers
    - `timer`, `history`, `statistics`, `reminder`, `reminder_action`, `recurring_reminders`, `task` providers into `lib/time_tracking/providers/`; drop `main_tab_provider`, `locale_provider`, `theme_provider`
    - _Requirements: 7.2, 9.2_

  - [ ] 4.2 Add the language and theme bridge
    - `providers/app_settings_bridge.dart` with `timeLocaleProvider` and `timeBrightnessProvider`, overridden by the Shell from the Settings values
    - `loadAppLocalizations()` reads the language through the bridge; remove the `app_language` and `selected_theme` keys
    - _Requirements: 8.1, 8.2, 8.3_

  - [ ] 4.3 Replace the TimeLog palettes by an adapter
    - `core/theme.dart` becomes `lib/time_tracking/theme/time_theme.dart`: `AppThemeData.fromPalette(AppPalette, Brightness)` and `timeThemeProvider`; delete the `ember`, `midnight` and `paper` definitions and the theme selection
    - Map every field the widgets read to a role of the App palette; list the mapping in the checkpoint report
    - _Requirements: 8.2_

  - [ ]* 4.4 Port provider tests and write the suggestion and statistics property tests
    - `test/providers/`; add a test for untracked time
    - **Property 3: Untracked time**
    - **Property 4: Suggestions include saved names**
    - **Validates: Requirements 2.4, 2.5, 4.2**

- [ ] 5. Screens and widgets
  - [ ] 5.1 Move the screens
    - `timer_screen`, `history_screen`, `statistics_screen`, `reminder_action_screen`, `reminder_settings_screen` into `ui/screens/`; skip `tasks_screen.dart`, `bottom_nav.dart`, `theme_dots.dart`
    - _Requirements: 1.1, 3.2, 4.1, 9.2_

  - [ ] 5.1a Add the menu button and the fonts
    - Place `MenuButton` in the headers of Timer, History and Statistics
    - Add Sora and JetBrainsMono and their licence texts to `assets/fonts/` and `pubspec.yaml`; register the licences with `registerFontLicenses`
    - _Requirements: 9.5, 9.6_

  - [ ] 5.2 Move the widgets
    - Group into `ui/widgets/{sheets,controls,reminders,cards}/`, `activity_picker/`, `painters/`; at most 15 files per directory
    - Replace `AppLocalizations` keys by prefixed ones
    - _Requirements: 2.3, 8.4_

  - [ ] 5.3 Merge the ARB files
    - Add TimeLog strings to `app_cs.arb` and `app_en.arb` with the prefix `time_`; regenerate l10n; the ARB parity test must pass
    - _Requirements: 8.4_

  - [ ]* 5.4 Port the UI tests
    - `test/ui/`, sheet tests, `settings_screen_*` tests adapted to the `TimeSettingsGroups` widget
    - _Requirements: 10.1_

- [ ] 6. Reminders and startup
  - [ ] 6.1 Move the reminder services
    - `reminder_service.dart`, `recurring_reminder_service.dart` into `services/`
    - _Requirements: 5.1, 5.2_

  - [ ] 6.2 Write `TimeTrackingBootstrap`
    - Move the body of TimeLog `main()` into `bootstrap.dart`; take the navigator key as a parameter; process the launch payload once
    - _Requirements: 5.3, 5.4, 5.5_

  - [ ] 6.3 Write `ReminderActionHost`
    - Move the lifecycle and pending-reminder logic of `_MainShellState`; call `rescheduleAll()` on resume
    - _Requirements: 5.2, 5.3_

  - [ ]* 6.4 Port the reminder tests
    - `recurring_reminder_service_test.dart`, `reminder_provider_test.dart`; add a bootstrap test that a launch payload is handled once
    - _Requirements: 5.3, 5.5, 10.1_

- [ ] 7. Shell integration
  - [ ] 7.1 Plug the Time_Module into the Shell
    - `time_tracking.dart` public API; replace the Timer placeholder; add History and Statistics Destinations; call `refreshStatistics` on selecting Statistics; call `TimeTrackingBootstrap.start` from `main`
    - Settings: add `TimeSettingsGroups` (daily reminder, recurring reminders, notification permission, Testing section)
    - _Requirements: 9.1, 9.2, 9.3, 5.6, 5.7_

  - [ ]* 7.2 Extend the import isolation test
    - **Property 5: Time_Module is isolated**
    - **Validates: Requirements 1.6, 9.4**

- [ ] 8. iOS native code
  - [ ] 8.1 Rename the native identifiers and split the URL handling
    - The `ios/` folder already comes from TimeLog (spec `001`); rename the method channels, the Darwin notification name, the App Group and the `Link` URLs consistently in Swift and Dart
    - `application(_:open:)` handles only `zafling://action/...` and calls `super` for every other link; check `Info.plist` keeps `NSSupportsLiveActivities`, frequent updates, `FlutterDeepLinkingEnabled` and the URL scheme
    - Grep `ios/` and `lib/` for `timelog` and list every remaining hit in the report
    - _Requirements: 6.1, 6.2, 6.3, 6.6_

  - [ ] 8.2 Equivalence report
    - Diff every moved file against TimeLog `v1.2.0`; write `.agents/runs/002/EQUIVALENCE.md` listing differences beyond imports, the legacy Riverpod import and the removed bottom navigation
    - _Requirements: 10.2, 10.3_

- [ ] 9. Checkpoint — Time_Module is green
  - Ensure `scripts/check.sh` passes; list the items Martin must check on the iPhone (alarm, Live Activity, notification taps, reminders); ask the user if questions arise

## Notes

- Tasks marked with `*` are optional and can be skipped for a faster MVP.
- Do not change TimeLog behaviour or look. If a port forces a change, record it in the equivalence report.
- Dependency additions are their own `build:` commit; Conventional Commits, English, no tool attribution, never push.
- The Drift `build_runner` run takes about 50 s; run it in the background and poll the log.
- TimeLog's migration steps are not copied because the Database is new; old data arrives through spec `003-legacy-import`.
- iOS items cannot be verified in the sandbox; mark them as Martin's checks.
