# Refactor notes

What is still to clean up after `1.0.0-dev.0`. Delete a line when it is done. Done in the first pass: the move into
feature folders, the dead code of the TimeLog port (Tasks screen, project selector, reminder sheet), 55 unused
translation keys, QuestLog's migration code and unused column, the old test layout, the stale golden failures.

## Time tracking (the TimeLog code, moved as it was)

- Literal paddings, font sizes and durations: move them to `Space`/`Metrics`/`Motion` tokens. The token guard test
  (`test/theme/token_usage_test.dart`) skips `lib/time_tracking/` until then.
- `DateTime.now()` calls: route them through the `Clock`. `test/core/clock_usage_test.dart` skips the folder.
- `AppThemeData` (`theme/time_theme.dart`) is an adapter over the palette: read `context.palette` in the widgets and
  delete it.
- Riverpod: `StateNotifier`, `StateProvider` and `StateNotifierProvider` come from `flutter_riverpod/legacy.dart`;
  convert them to `Notifier`/`AsyncNotifier`.
- `data/time_tracking_queries.dart` is one long extension: split reminders, completions and entries.

## QuestLog modules

- `settings/ui_providers.dart` (effective language, theme mode, app version) and `AppSettings` in
  `quests/data/models.dart` are used by every feature: move them where all may import them (`core/` or `database/`),
  so `settings/` stops being a dependency of the QuestLog modules.
- `quests`, `calendar` and `notes` import each other (the Board shows events, an event awards XP, a Note in the Trash
  reuses quest actions). Untangle in a spec of its own; the architecture test records the allowed direction.
- Names from the old look (`guildBoard`, `brass`, `slip*`, `Board`) stay until the theme gets a second palette.

## App

- The app icon and the launch screen are TimeLog's. Replace them (the name is settled: DayLog); the Quest launch colour
  of spec 001 (Requirement 9.6) is not carried over.
- Importing a file does not select its theme or language: both live in `app_state` and come only from a QuestLog or
  DayLog file; the preferences ignore `app_language` and `selected_theme`.
- Task 6.3 of spec 003: import Martin's real export files from `.import/` and compare the counts with the old apps.
