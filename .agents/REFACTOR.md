# Refactor notes

Things to clean up before the first release (delete lines as they are done).

- `AppTheme` (light/dark/system) in `database/preferences.dart` and the `app_state.theme` column mean the brightness mode, not a theme: rename the enum (`ThemeModeSetting`) once the theme registry has a theme id.
- `settings/ui_providers.dart` is imported by features: decide whether it belongs in `core`.
- `AppSettings` and models sit in `quests/data/models.dart` but belong to settings.
- Test files not moved by the path rule: `test/services/*`, `test/data/*`, `test/ui/*` still use the old layout; mirror them under the feature folders.
- `PlaceholderScreen` and the `shell_placeholderBody` strings are temporary; delete them when the TimeLog port lands.
- `test/ui/*` (widgets, sheets, screens) still sit in the old layout; mirror them under `test/<feature>/ui` and update `catalogue_test.dart`.
