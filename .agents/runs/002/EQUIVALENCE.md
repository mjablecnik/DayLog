# Time tracking port: equivalence with TimeLog 1.2.0

Every file of `TimeLog/timelog_app/lib` was moved into `lib/time_tracking/` (or dropped, see below). The table counts the changed lines of each moved file after ignoring import lines, the `time_` prefix of localization keys, `AppLocalizations.of(context)!` and the provider renames; 0 means the file is the original apart from those.

20 files are unchanged in that sense, 35 differ, 22 were not moved.

## Files that differ

| File | Changed lines |
|---|---|
| `ui/screens/settings_screen.dart` | 424 |
| `core/theme.dart` | 127 |
| `ui/screens/statistics_screen.dart` | 39 |
| `ui/widgets/reminder_edit_dialog.dart` | 28 |
| `ui/widgets/timer_controls.dart` | 26 |
| `ui/screens/reminder_action_screen.dart` | 25 |
| `ui/widgets/duration_adjuster.dart` | 22 |
| `ui/widgets/history_entry_card.dart` | 20 |
| `ui/screens/reminder_settings_screen.dart` | 17 |
| `ui/screens/timer_screen.dart` | 17 |
| `ui/widgets/edit_sheet.dart` | 12 |
| `ui/widgets/manual_entry_sheet.dart` | 12 |
| `ui/widgets/description_sheet.dart` | 11 |
| `services/reminder_service.dart` | 10 |
| `services/alarm_service.dart` | 9 |
| `ui/widgets/reminder_card.dart` | 9 |
| `providers/database_provider.dart` | 8 |
| `ui/widgets/activity_picker/suggestion_field.dart` | 7 |
| `ui/screens/history_screen.dart` | 6 |
| `data/time_entry.dart` | 5 |
| `services/recurring_reminder_service.dart` | 5 |
| `ui/widgets/activity_picker/subtype_block.dart` | 5 |
| `core/platform_channel.dart` | 4 |
| `ui/widgets/activity_picker/activity_picker.dart` | 4 |
| `core/config.dart` | 3 |
| `providers/recurring_reminders_provider.dart` | 2 |
| `providers/reminder_action_provider.dart` | 2 |
| `providers/reminder_provider.dart` | 2 |
| `services/timer_service.dart` | 2 |
| `ui/painters/timeline_painter.dart` | 2 |
| `ui/widgets/day_summary.dart` | 2 |
| `ui/widgets/empty_state.dart` | 2 |
| `ui/widgets/ringing_overlay.dart` | 2 |
| `ui/widgets/day_navigator.dart` | 1 |
| `ui/widgets/day_selector.dart` | 1 |

## Not moved

- `app.dart`
- `core/app_locale.dart`
- `core/extensions.dart`
- `data/database.dart`
- `data/database.g.dart`
- `data/database_export.dart`
- `l10n/generated/app_localizations.dart`
- `l10n/generated/app_localizations_cs.dart`
- `l10n/generated/app_localizations_en.dart`
- `main.dart`
- `providers/locale_provider.dart`
- `providers/main_tab_provider.dart`
- `providers/theme_provider.dart`
- `services/export_service.dart`
- `services/timer_service.freezed.dart`
- `ui/screens/tasks_screen.dart`
- `ui/widgets/bottom_nav.dart`
- `ui/widgets/project_selector.dart`
- `ui/widgets/reminder_action_sheet.dart`
- `ui/widgets/task_card.dart`
- `ui/widgets/task_edit_dialog.dart`
- `ui/widgets/theme_dots.dart`

## Why the files differ

Every difference beyond imports falls into one of these groups.

- **Theme.** `core/theme.dart` is now an adapter over the app palette (`theme/time_theme.dart`): TimeLog's three
  palettes and the theme choice are gone, the widgets read the same field names. `ref.watch(themeProvider)` became
  `AppThemeData.of(context)` and `theme.themeKey != AppTheme.paper` became `theme.isDark`. This is the one visible
  change, asked for by Martin: the timer pages use the blue theme of QuestLog in both variants.
- **Fonts.** `fontFamily: 'Sora'` and `'JetBrainsMono'` were removed (the font files in TimeLog are zero bytes, so
  the text fell back to the system font); the timer digits use tabular figures of the app font.
- **Navigation.** The Timer, History and Statistics pages carry a menu button in their header that opens the drawer.
  `app.dart` (the bottom navigation, the reminder host) became `ReminderActionHost` and the shell; `main.dart`
  became `TimeTrackingBootstrap`; `bottom_nav.dart`, `main_tab_provider.dart` and the language and theme providers
  were dropped because the app has one of each. `reminder_action_screen.dart` closes with `pop` (the old fallback
  pushed `TimeLogApp`, which no longer exists).
- **Settings.** `ui/screens/settings_screen.dart` became `time_settings_groups.dart`: the daily reminder with the
  link to the recurring reminders, and the Testing section, as groups of the shared Settings page. The language and
  data groups moved to the app Settings (one language, one export).
- **Riverpod 3.** `StateNotifier`, `StateProvider` and `StateNotifierProvider` come from
  `flutter_riverpod/legacy.dart`; `valueOrNull` is `value`; `ReminderActionScreen` loads after the first frame
  because Riverpod 3 rejects a provider change while the tree builds (the screen never loaded under Riverpod 3
  before this fix). freezed 4 needs `abstract class TimerState`.
- **Database.** The five tables are part of the app database at schema 1; the legacy column
  `entertainment_type` and the migration steps are gone; the queries are the extension in
  `data/time_tracking_queries.dart`. `appDatabaseProvider` is the shared `databaseProvider`.
- **Language outside widgets.** `loadAppLocalizations()` read `app_language` from SharedPreferences; the reminder
  services take a `LocalizationsLoader` that reads the app language. The notification title is the app name.
- **Strings.** Localization keys carry the prefix `time_`; the keys for the removed Tasks UI and 38 other unused
  ones were deleted; two accessibility labels were added for the duration buttons and five for the timer buttons.
- **Accessibility.** The duration buttons have a 44 px tap area (the circle is still 36 px) and labels; the timer
  buttons have labels (required by the touch-target test of the shell).
- **Alarm.** `AlarmService` creates the audio player on the first alarm.
- **Dead code removed.** The Tasks screen, `ProjectSelector`, `ReminderActionSheet`, `extensions.dart`,
  `statsTabIndex`, `ThemeDots` and their tests, and the TimeLog export (replaced by the app export). The Tasks
  service, providers, tables and their data are removed as well (Martin does not use Tasks); an import skips
  `tasks` and `task_projects`.

## Native iOS

The `ios` folder is TimeLog's, renamed: the target `DayLogWidgetExtension`, the Swift types `DayLog*`, the bundle
id, App Group, URL scheme, channel names, Darwin notification and notification identifier. `Info.plist` has
`FlutterDeepLinkingEnabled` false as in QuestLog. Nothing here is built or run in the sandbox.
