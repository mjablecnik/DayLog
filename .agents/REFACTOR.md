# Refactor notes

Things to clean up before the first release (delete lines as they are done).

- `AppTheme` (light/dark/system) in `database/preferences.dart` and the `app_state.theme` column mean the brightness mode, not a theme: rename the enum (`ThemeModeSetting`) once the theme registry has a theme id.
- `settings/ui_providers.dart` is imported by features: decide whether it belongs in `core`.
- `AppSettings` and models sit in `quests/data/models.dart` but belong to settings.
- Test files not moved by the path rule: `test/services/*`, `test/data/*`, `test/ui/*` still use the old layout; mirror them under the feature folders.
- `test/ui/*` (widgets, sheets, screens) still sit in the old layout; mirror them under `test/<feature>/ui` and update `catalogue_test.dart`.
- `lib/time_tracking/` keeps TimeLog's literal paddings, font sizes, durations and `DateTime.now()` calls: the token and clock guard tests skip it. Move them to `Space`/`Metrics` tokens and the `Clock`, then drop the exemption.
- TimeLog screens read `AppThemeData` (an adapter over the palette); move them to `context.palette` and delete the adapter.
- Time tracking tests still sit flat under `test/time_tracking/` (a copy of TimeLog's layout): mirror `lib/time_tracking/`.
- `lib/time_tracking/data/time_tracking_queries.dart` is a long extension: split reminders, completions, tasks and entries.
- Tasks (service, providers, tables) have no screen: decide whether to keep them (project suggestions read them).
