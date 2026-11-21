# Requirements Document

## Introduction

This spec moves the features of TimeLog (`/workspace/TimeLog/timelog_app`, tag `v1.2.0`, Drift schema 8) into the Zafling project created by spec `001-app-foundation`. TimeLog is a countdown timer with time tracking: a Timer screen with an alarm, a Live Activity and a completion notification, entries with activity types, subtypes and project names, a History screen, a Statistics screen, a daily reminder and recurring reminders with a reminder action screen.

This is a pure move: behaviour, texts and look stay as in TimeLog 1.2.0. TimeLog is on Riverpod 2 and the App on Riverpod 3, so providers keep their shape and import the legacy API where needed; they are not redesigned. The old Tasks screen is not reachable in TimeLog and is not ported, but its tables and services stay because project name suggestions depend on them. The native iOS code (Live Activity, widget extension, notification channel) moves with its behaviour unchanged.

## Glossary

- **Time_Module**: The folder `lib/time_tracking/` of the App.
- **Timer_Service**: The timer state machine (`timer_service.dart`) with states idle, running, paused, ringing.
- **Timer_Screen**: The Destination `timer`, the first screen of the App.
- **History_Screen**: The Destination `history`.
- **Statistics_Screen**: The Destination `statistics`.
- **Time_Entry**: A row of `time_entries`: start, end, duration, activity type, subtype, project or custom name, description.
- **Activity_Registry**: The single definition of activity types, subtypes, labels and colours (`activityRegistry`).
- **Reminder_Service**: The daily reminder notification service.
- **Recurring_Reminder_Service**: The service for recurring reminders and their notification slots.
- **Reminder_Action_Screen**: The screen opened by tapping a reminder notification.
- **Live_Activity**: The iOS lock-screen and Dynamic Island view of the running timer, with its widget extension.
- **Project_Suggestions**: The per-category list of project names offered when saving an entry.
- **Time_Preferences**: The SharedPreferences keys used by TimeLog (reminders, suggestions, timer state, pending reminder id).
- **Legacy_Timelog**: TimeLog 1.2.0.
- **Shell**: As defined in spec `001-app-foundation`.

## Requirements

### Requirement 1: Timer

**User Story:** As the user, I want the countdown timer exactly as it is in TimeLog, so that tracking my time feels the same.

#### Acceptance Criteria

1. THE Timer_Screen SHALL provide start, pause, resume and stop of a countdown, with the adjustable duration of 5 to 60 minutes in 5-minute steps and the default of 20 minutes.
2. WHEN the countdown reaches zero, THE Timer_Service SHALL enter the state ringing, play the alarm sound and show the ringing overlay.
3. WHEN the user stops or finishes a countdown, THE Timer_Screen SHALL offer the description sheet and save a Time_Entry on confirmation.
4. WHILE the Timer_Service is running or paused, THE Timer_Service SHALL keep its state across app restarts, as Legacy_Timelog does.
5. THE Timer_Service SHALL keep the allowed range of 1 to 1440 minutes in `TimerConfig`.
6. THE Time_Module SHALL NOT award XP and SHALL NOT read or write a Quest_Module table.

### Requirement 2: Entries and activities

**User Story:** As the user, I want activity types, subtypes and project names, so that entries are categorised as before.

#### Acceptance Criteria

1. THE Time_Module SHALL define activity types, subtypes, labels and colours once, in the Activity_Registry, and every widget SHALL read it.
2. THE Time_Module SHALL persist the type and subtype keys as the Czech/ASCII identifiers of Legacy_Timelog and SHALL NOT translate them.
3. THE Time_Module SHALL provide the description sheet, the edit sheet and the manual entry sheet, all using the shared activity picker.
4. WHEN a Time_Entry is saved with a project name, THE Project_Suggestions SHALL offer the name in its category on the next save.
5. THE Time_Module SHALL NOT contain the Tasks of Legacy_Timelog: no screen, service, table or data.
6. THE Time_Module SHALL validate manual and edited times as Legacy_Timelog does.

### Requirement 3: History

**User Story:** As the user, I want my entries by day, so that I can review and correct them.

#### Acceptance Criteria

1. THE History_Screen SHALL list Time_Entries of the selected logical day, where the day starts at 03:00.
2. THE History_Screen SHALL provide the day selector, the day navigator, the day summary and the timeline.
3. WHEN the user edits or deletes an entry, THE History_Screen SHALL update the list and the day summary.
4. WHEN the user adds a manual entry, THE History_Screen SHALL show it on its day.

### Requirement 4: Statistics

**User Story:** As the user, I want statistics of tracked time, so that I see where time goes.

#### Acceptance Criteria

1. THE Statistics_Screen SHALL show tracked time per activity type, subtype and project for the selected period, with the ring and bar charts of Legacy_Timelog.
2. THE Statistics_Screen SHALL compute untracked time as 16 hours per day of the period minus tracked time.
3. WHEN the Statistics_Screen is opened, THE Time_Module SHALL recompute the statistics.

### Requirement 5: Reminders

**User Story:** As the user, I want my daily and recurring reminders, so that I am nudged as before.

#### Acceptance Criteria

1. THE Reminder_Service SHALL schedule the daily reminder from its settings and reschedule it at start.
2. THE Recurring_Reminder_Service SHALL schedule recurring reminder slots, reschedule them at start and on every return from the background, and respect the 6-hour lookahead of Legacy_Timelog.
3. WHEN the user taps a reminder notification, THE Time_Module SHALL open the Reminder_Action_Screen for that reminder, also after a cold start and also when the tap was stored while the app was suspended.
4. WHEN the user taps the start-timer notification, THE Time_Module SHALL start the timer if it is idle.
5. THE Time_Module SHALL process a launch notification only once.
6. WHEN the user opens the notification settings, THE Settings Destination SHALL show the permission state and the reminder screens.
7. THE Settings Destination SHALL keep the Testing section of Legacy_Timelog (test notification, modal debug button) in the Time group, as Legacy_Timelog has it.

### Requirement 6: iOS native features

**User Story:** As the user, I want the Live Activity and the notification at the end of the countdown, so that the timer works with the screen locked.

#### Acceptance Criteria

1. WHILE the timer runs, THE Live_Activity SHALL show the remaining time with stop, pause and resume controls, on iOS 16.2 and later.
2. WHEN a Live_Activity control is tapped, THE App SHALL receive `zafling://action/<pause|resume|stop>` in the native URL handler, forward it to the Timer_Service through the platform channel, and SHALL pass every other `zafling://` link to the deep-link handler of the Shell.
3. WHEN a Live_Activity intent writes a pending action to the App Group, THE App SHALL apply it on the next Darwin notification and on every return to the foreground.
4. IF Live Activities are disabled or unsupported, THEN THE Time_Module SHALL continue without error and without a message.
5. THE Time_Module SHALL schedule a native notification for the end of the countdown and cancel it when the countdown ends early.
6. THE Live_Activity extension, the platform channel names and the Darwin notification name SHALL use identifiers derived from `zafling` and none of Legacy_Timelog, so a Legacy_App installed beside the App does not react to them.
7. THE Time_Module SHALL guard every platform channel call so that a platform without the channel (Linux, tests) does not fail.

### Requirement 7: Data in the Database

**User Story:** As the user, I want my tracked data in the one Database, so that nothing else stores it.

#### Acceptance Criteria

1. THE Database SHALL contain `time_entries`, `recurring_reminders`, and `completion_records` with the columns of Legacy_Timelog schema 8.
2. THE Time_Module SHALL read and write them through the Database of the App and SHALL NOT open another database.
3. THE Time_Module SHALL keep Time_Preferences in SharedPreferences under the keys of Legacy_Timelog, except language and theme.

### Requirement 8: Language and theme

**User Story:** As the user, I want one language and one theme for the whole App, so that I set them once.

#### Acceptance Criteria

1. THE Time_Module SHALL read the language from the App setting and SHALL NOT read `app_language` from SharedPreferences.
2. THE Time_Module SHALL read the active palette from the App theme (`context.palette`) and SHALL NOT define a palette of its own, so every screen of the Time_Module follows the blue theme in its light and dark variant.
3. WHEN a notification is built without a BuildContext, THE Time_Module SHALL read the language from the App setting.
4. THE Time_Module SHALL provide every string in Czech and English with keys prefixed `time_`.

### Requirement 9: Shell integration

**User Story:** As the user, I want the Timer first and the other pages in the Drawer, so that the App opens as I want.

#### Acceptance Criteria

1. THE Timer_Screen SHALL replace the placeholder Timer Destination of the Shell.
2. THE History_Screen and the Statistics_Screen SHALL be the Destinations `history` and `statistics`, without the bottom navigation bar of Legacy_Timelog.
3. WHEN the Statistics Destination is selected, THE Shell SHALL call the Time_Module refresh hook.
4. THE Time_Module SHALL NOT import another feature folder and SHALL expose only a `TimeTrackingBootstrap`, the three Destination widgets and its Settings group widgets.
5. THE Timer_Screen, the History_Screen and the Statistics_Screen SHALL place the `MenuButton` in their existing header.
6. THE Time_Module SHALL draw its text in the font of the App (Figtree) and SHALL NOT bundle a font of its own, because the font files of Legacy_Timelog are empty.

### Requirement 10: Equivalence with Legacy_Timelog

**User Story:** As the developer, I want proof that nothing changed in behaviour, so that I can trust the move.

#### Acceptance Criteria

1. WHEN the TimeLog test suite is ported, THE Time_Module SHALL pass every ported test without weakening an assertion.
2. THE Time_Module SHALL NOT add a feature that is not in Legacy_Timelog.
3. WHEN a ported file differs from its TimeLog original beyond imports, the Riverpod API import and the removed bottom navigation, THE change SHALL be listed in the checkpoint report.
