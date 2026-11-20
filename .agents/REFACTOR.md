# Refactor notes

Things to clean up before the first release (delete lines as they are done).

- QuestLog `app_state` columns that are unused (`display_font`, palette choice leftovers): check `lib/quests/data/tables.dart` and drop them from the new schema.
- `lib/quests/services/providers.dart` mixes the global providers (database, clock) with quest providers: split the global ones into `lib/database/providers.dart`.
- `settings/ui_providers.dart` is imported by features: decide whether it belongs in `core`.
- `AppSettings` and models sit in `quests/data/models.dart` but belong to settings.
- Test files not moved by the path rule: `test/services/*`, `test/data/*`, `test/ui/*` still use the old layout; mirror them under the feature folders.
- `drift_schemas/` still holds the QuestLog dumps v1..v6: replace by `drift_schema_v1.json`.
- QuestLog DB migration code (`onUpgrade` steps 1..6) is dead in a v1 database: remove, with its tests.
- `PlaceholderScreen` and the `shell_placeholderBody` strings are temporary; delete them when the TimeLog port lands.
- `test/ui/*` (widgets, sheets, screens) still sit in the old layout; mirror them under `test/<feature>/ui` and update `catalogue_test.dart`.
