# DayLog — Documentation

Reference material for working on DayLog. For what the app is and how to start it, see
[README.md](./README.md); for the full feature list, [FEATURES.md](./FEATURES.md); for the history of the
releases, [CHANGELOG.md](./CHANGELOG.md).

## Environment Variables

None. DayLog is a local-only app with no server, no account and no network access at runtime, so it reads no
environment variables. `.env.example` exists only to state that, as the project standard requires it.

## Project Structure

```
daylog/
├── lib/
│   ├── main.dart            entry point: the real database, folder and links, then runApp
│   ├── startup.dart         buildApp: container, overrides, time tracking startup, the root widget (tested with fakes)
│   ├── app.dart             root widget: theme, locale, the reward overlay, the shell
│   ├── core/                pure Dart: clock, errors, validation, board day (04:00), event types, app link scheme, font licences
│   ├── database/            the one Drift database (app_database.dart, preferences enums, providers)
│   │   ├── export/          the JSON export of every table and the preferences
│   │   └── import/          the importer for the export files (parse, plan, transaction, preferences writer)
│   ├── theme/               tokens (the palettes), typography, ThemeData, the theme registry
│   ├── ui_kit/              widgets every feature uses: common/ (icons, snackbar, segmented, menu button, empty state), sheet/, forms/
│   ├── l10n/                app_cs.arb (template), app_en.arb, generated localizations
│   ├── shell/               the root screen: bottom bar, drawer, destinations, deep links, splash, reconciliation
│   ├── settings/            the settings service and screen, the shortcut guide, export and import rows
│   ├── quests/              Quests, Missions, XP, recurring rules (data/, domain/, services/, ui/)
│   ├── calendar/            the Calendar (data/, domain/, services/, ui/)
│   ├── notes/               Notes and the Trash (data/, domain/, services/, ui/)
│   └── time_tracking/       Timer, History, Statistics, reminders (data/, domain/, services/, providers/, theme/, ui/)
├── assets/
│   ├── fonts/               static TTFs of Figtree, the one typeface of the app
│   │   └── licenses/        one SIL OFL text per family, `<Family>-OFL.txt`
│   ├── icons/               24px SVG icons drawn with currentColor strokes
│   └── audio/               the alarm sound
├── drift_schemas/           drift_schema_v1.json, the schema dump
├── test/                    mirrors lib/; goldens/, helpers/, architecture/, scripts/, fixtures of the import
├── scripts/                 check.sh, check-structure.sh, release.sh
├── screenshots/             the README screenshots (English, dark theme, 390x844)
├── ios/, linux/             platform projects; the iOS project holds the Live Activity extension
├── .kiro/specs/             001-app-foundation, 002-time-tracking-port, 003-legacy-import (requirements, design, tasks)
├── .design/                 the visual design inherited from QuestLog: DESIGN.md, artboards/, screens/, icon/
├── .agents/                 working notes (REFACTOR.md)
├── CHANGELOG.md             released versions, written by scripts/release.sh
├── l10n.yaml                Flutter localization generator configuration
└── pubspec.yaml             dependencies, fonts, assets, the version
```

### Folder rules

`test/architecture/feature_imports_test.dart` fails the build when an import breaks the layering:

- `core/`, `theme/`, `ui_kit/` and `l10n/` import no feature folder.
- `time_tracking/` imports only itself, `core/`, `theme/`, `ui_kit/`, `l10n/` and `database/`.
- `quests/`, `calendar/`, `notes/` and `settings/` (the QuestLog modules, which grew together: the Board shows
  calendar events, an event awards XP, a note in the Trash reuses the quest actions) may import each other, but
  not `time_tracking/` or `shell/`.
- `shell/` and the app root compose everything. `time_tracking/` exposes one file, `time_tracking.dart`, and the
  shell imports only that.

A new feature is a new folder beside these, a new value in `Destination` (`lib/shell/destination.dart`), a
page in the shell and, if it has settings, a group passed to `SettingsScreen.moduleGroups`.

### Navigation

`Destination` is the one list of pages. The bottom bar shows the tabs (`Destination.tabs`: timer, quests,
calendar, notes, settings), the drawer lists every page (`Destination.drawerItems`: Time = timer, history, statistics; Planning = quests,
missions, calendar, notes; then settings), and the deep-link parser reads the same names. A page that is not a tab marks the tab it belongs to
(`Destination.tab`). Every page keeps its state while another is shown (`IndexedStack`). The menu button
(`ui_kit/common/menu_button.dart`) opens the drawer; a pushed route is outside its scope and shows no button.

### Data

One SQLite file, `daylog.sqlite`, in the platform's application documents directory
(`getApplicationDocumentsDirectory()`), opened lazily in a background isolate. The schema is at version 1, created
by `onCreate` (which also inserts the singleton `app_state` row and the 35 built-in calendar events); a change to
the schema needs a migration step in `lib/database/app_database.dart` and a new dump in `drift_schemas/`
(`dart run drift_dev schema dump lib/database/app_database.dart drift_schemas/`). Thirteen tables:

| Table | Holds |
|---|---|
| `quests` | event (`event_id`, the calendar event of the Deadline, cleared when that event is deleted), name, note, effort tier (column `difficulty`), optional mission, Board section (`board`: `todo`, `today` or null = not on the Board; quests without a mission are never null), sort order, completion time and awarded XP |
| `missions` | name, bonus size, status (open, completed, closed), sort order, awarded bonus, optional rule |
| `recurring_rules` | name, cadence, anchor date, next index, bonus size, last posted date |
| `rule_quests` | the quests a rule posts with each mission |
| `app_state` | the singleton row: total XP, hero name, language, theme mode (light, dark or system) |
| `calendar_events` | name, note, location, event type, start and end (a date plus minutes since midnight, no time zone, no minutes for an all-day event), repeat rule and its end, the On_Board flag |
| `calendar_skipped_dates` | dates on which a repeating event is deleted for one occurrence |
| `calendar_completions` | the completed occurrences of events (event, date, time, awarded XP) |
| `calendar_addresses` | the addresses saved on events (lower-cased key, last spelling, last use), for suggestions; forgotten 30 days after the last use |
| `note_nodes` | Folders and Notes in one table: optional parent (deleting a folder row deletes what is inside it), folder flag, name, the Markdown body, whether the name follows the first line, created, edited and deleted times |
| `time_entries` | a logged time span: start and end (ISO 8601 text), description, activity type, subtype, project, custom name |
| `recurring_reminders` | a recurring reminder: name, description, time window (minutes from midnight), repeat interval, active days (7-bit mask), active flag |
| `completion_records` | the days on which a recurring reminder was marked done |

Besides the database the time tracking feature keeps small state in SharedPreferences: the running timer
(`timer_*` keys), the last choices in the entry sheets and the name
suggestion lists. The language and the theme mode are not among them: they live in `app_state` for the whole app.

Quests and the calendar share one link (`quests.event_id`), and the importer deletes and refills whole tables, so
the table classes live in their feature folders while the database lists them all.

### Calendar

The Kalendář tab is independent of quests and missions except for one link: an event with
`on_board` set appears on the Board, in Today, on the Board_Day whose date is the event's
start date, and completing it awards XP once (a completion row per event and date; reopening
removes it and the XP). Occurrences of a repeating event are never stored: the service expands
the rule for the range on screen (daily, weekly, monthly and yearly reuse `occurrenceDate` of
`lib/quests/domain/cadence.dart`; two built-in rules exist only for the seed: relative to Easter, and
the n-th weekday of a month). Event XP: a timed event 10 / 25 / 50 / 100 XP by length (up to
30 min, 2 h, 5 h, longer); an all-day event 10 XP for birthday, name day, public holiday,
notable day and date, 25 XP for the rest. The calendar uses the calendar day (midnight), the
Board uses the Board_Day (04:00). The type filter is remembered in `calendar_filter.txt` beside
the database. In the month view an event of several days is one bar per week row across the days it
covers (`layoutWeek` in `lib/calendar/ui/screens/week_lanes.dart` gives each bar a lane, the same on
all its days; up to three lanes show, more show two and a "+N" in the days that have events in the
lanes left out). The Address field of the event form lists the remembered addresses that match what is typed (up to 5, newest first); an address is forgotten 30 days after its last use, at start and on every lookup, and the event keeps its own (QuestLog spec 008). Notifications, an event URL, week and day views and user-defined types are not
part of it (QuestLog specs 003 and 006, kept with the QuestLog repository).

### Notes

The Notes tab is independent of the rest of the app and awards no XP. Folders and Notes are rows of
`note_nodes`; `NoteTree` (`lib/notes/domain/`) holds every rule about the tree in pure Dart, and
`NotesService` streams all rows, so the tree is built in memory. Deleting sets `deleted_at` on one row, so
a Folder goes to the Trash with everything inside it; a node is visible only while neither it nor any
ancestor is trashed. Restore clears the time, or first moves the node to the top level when its parent
is gone or trashed. A Trashed_Node is purged 30 days after its deletion time (at start, on return from
the background and when the Trash opens); the foreign key's cascade removes what is inside it. A Note's
text is Markdown, edited with `super_editor` in `lib/notes/ui/screens/note_editor/`; `note_markdown.dart` converts
between the two and escapes plain text, because the package's own codec changes text typed in a WYSIWYG
editor (for example ABAP field symbols such as `<fs_line>`). The language after a code fence is not kept.
A Note has a title field above its text. A typed title is the Note's name; with an empty title the name
follows the first line of the text (and the title field stays empty), and renaming from the menu also sets
a chosen name. A Note in the Trash opens in a read-only preview (`trash_preview_screen.dart`, a
`SuperReader` with the editor's stylesheet) with an Restore button; opening it changes nothing.
Search, tags, images, tables, opening links and a Trash undo are not part of it (QuestLog specs 004, 005 and 007). The editor keeps the package's own overlays (accent colour
set) so that iOS shows the caret, the selection handles and the Cut, Copy and Paste toolbar; copy and paste
carry plain text only.

### Quest Deadline

A Quest may have a Deadline. Saving one creates an all-day event of the type Quest (not on the Board) named like the Quest and links it in `quests.event_id`; the Deadline is that event's end date, so changing the event in the Calendar changes the Deadline, and deleting the event (or undoing it) only clears (or restores) the link. Clearing the Deadline in the Quest sheet deletes the event, deleting the Quest deletes its event, and renaming the Quest renames the event. An open Quest whose Deadline is before the Board_Day shows "Overdue" in the destructive colour on its card (Board and Mission detail); a done Quest does not. Completing is only possible on the Quest (QuestLog spec 010).

### Time tracking

The Timer, History and Statistics pages, the entry sheets and the reminders come from TimeLog 1.2.0 and behave as
they did. The timer is a state machine in `lib/time_tracking/services/timer_service.dart` (idle, running, paused,
ringing, logging, a freezed state) that persists itself in SharedPreferences and recomputes the remaining time
from the stored end time on start; a timer that ran out while the app was closed comes back ringing.

- **Logical day.** History and Statistics split days at 03:00 (`dayStartHour`), so an entry logged at 01:00
  belongs to the day before; the Board day of the quests starts at 04:00. The two are kept as they were.
- **Untracked time** in Statistics is 16 hours per day of the period minus the tracked time; the 16 is fixed.
- **Activity types.** Twelve types, most with subtypes, are defined once in `activityRegistry`
  (`lib/time_tracking/domain/activity_types.dart`). The stored keys (`time_entries.activity_type`, `subtype`) are
  Czech or ASCII identifiers and are never translated; labels come from the localization files. Colours are
  computed (`activityEntryColor(type, subtype, isDark:)`), never stored. To add a type or subtype, add it to the
  registry and its labels to both ARB files.
- **Name suggestions** are kept per category (paid work, unpaid work, housework, other) and read through
  `suggestionsProvider`, which fills the lists from the existing entries on first use. Any
  code that saves a name must call `ref.invalidate(suggestionsProvider)`.
- **Theme.** The widgets read `AppThemeData` (`lib/time_tracking/theme/time_theme.dart`), an adapter that maps
  each colour the widgets use to a role of the app palette, so the pages follow the active theme.
- **Language.** Texts without a BuildContext (notifications) come from `localizationsLoaderProvider`, which reads
  the app language through `timeLocaleProvider`; the app root overrides that provider with the app setting.
- **Startup.** `TimeTrackingBootstrap` (called from `main`) asks for the notification permission, initialises the
  reminder plugin, handles a notification tap that launched the app (once), reschedules the recurring reminders and removes what
  the old daily reminder left (its notification and `reminder_*` keys).
  `ReminderActionHost` opens the reminder screen when a tap arrives, also after a return from the background.
  A failure in this startup is reported and does not stop the rest of the app.
- **Alarm.** `AlarmService` creates its audio player on the first alarm, so the plugin is not touched before.

### iOS native code

The Live Activity and the end-of-countdown notification are native (`ios/Runner/AppDelegate.swift`,
`LiveActivityManager.swift`, the `DayLogWidgetExtension` target). The Dart side talks to them over two method
channels (`lib/time_tracking/services/native/platform_channel.dart`).

The native code holds no user-facing text: the strings of the Live Activity (`completedText`, `doneText`,
`pausedText`) and of the notification (`title`, `body`) come from the ARB files in the language of the app and are
passed in the arguments below. A new native string is a new ARB key (prefix `time_`) and a new argument.

| Channel | Method | Arguments | Purpose |
|---|---|---|---|
| `com.jablecnik.daylog/notifications` | `requestPermission` | none | ask for the notification permission (returns bool) |
| | `scheduleNotification` | `{ endAtMs, title, body }` | schedule the end-of-countdown notification |
| | `cancelNotification` | none | cancel it (pause, stop) |
| `com.jablecnik.daylog/live_activity` | `startLiveActivity` | `{ endAt, totalSeconds, completedText, doneText, pausedText }` | start the countdown activity (returns bool) |
| | `updateLiveActivity` | `{ action: pause\|resume\|complete, endAt? }` | update it |
| | `endLiveActivity` | none | end it |
| | `areActivitiesEnabled` | none | whether the user allows Live Activities |

The native side calls `onLockScreenAction` (`{ action, endAtMs? }`) on the Dart side when a lock-screen button is
used. The extension and the app share the App Group `group.com.jablecnik.daylog`; the buttons also write a pending
action there and post the Darwin notification `com.jablecnik.daylog.action`. A Live Activity link
`daylog://action/<pause|resume|stop>` is taken by `AppDelegate.application(_:open:options:)`; every other
`daylog://` link goes on to the deep-link handler. Live Activities need iOS 16.2 or newer and return `false`
silently when disabled or unsupported (the iOS target is 18.0).

### Theme

The app has one theme, the blue one, in a dark and a light variant. A palette is an `AppPalette`
(`lib/theme/tokens.dart`): `guildBoard` (dark) and `daylight` (light); `brass` is the accent colour in the code.
A `ThemeDefinition` (`lib/theme/theme_registry.dart`) pairs a light and a dark palette under an id, and
`themeRegistry` lists them. `activeThemeProvider` returns the active one and `DayLogApp` builds the light and dark
`ThemeData` from it. To add a theme: add a palette pair, add a `ThemeDefinition` to the registry, and make
`activeThemeIdProvider` read a stored choice. No screen changes, because screens read `context.palette`.

| Palette | Board / accent | Notes |
|---|---|---|
| Dark (`guildBoard`) | `#0F1319` / `#78B4C4` | Quest cards are dark raised cards (`slip*` roles), not parchment slips. |
| Light (`daylight`) | `#EDF1F6` / `#2B7287` | Quest cards are paper slips. |

The reward card and the empty-state slip stay parchment. Every body-text pair reaches 4.5:1, the accent as text
4.5:1 and the accent as a fill 3:1 (`test/ui/theme/contrast_test.dart`).

### Deep links

The URL scheme `daylog` (registered in `ios/Runner/Info.plist`) opens a page: `daylog://timer`, `history`,
`statistics`, `quests`, `missions`, `calendar`, `notes` or `settings`; anything else is ignored. To get a Home
Screen icon that opens the Calendar: in the iOS Shortcuts app make a shortcut with the action "Open URLs" and the
URL `daylog://calendar`, then Share → Add to Home Screen and pick a name and an icon. The same steps are in the
app under Settings → Home Screen shortcut (`lib/settings/ui/shortcut_guide.dart`). The old schemes `questlog` and
`timelogapp` are not registered, so the old apps keep working beside this one. See `lib/shell/deep_link.dart`.

### Data export

Settings → Data → Export data writes every table of the database and every SharedPreferences entry into one JSON
file (`daylog-export-<date>.json`, in the temporary directory) and opens the system share sheet. The export walks
`db.allTables` and copies rows as stored, so a table or column added later is exported without changes
(`lib/database/export/`). The file has `format` (`daylog-export`), `formatVersion`, `app`, `appVersion`,
`schemaVersion`, `exportedAt`, `rowCounts` (rows per table, for checking an import), `tables` (table name to a list
of rows keyed by column name) and `preferences`. Integers stay integers, so dates and booleans keep the database
representation; a BLOB would be `{"$blob": "<base64>"}`.

### Data import

Settings → Data → Import data (`lib/settings/ui/import_row.dart`, `lib/database/import/`) reads an export file of
QuestLog (`questlog-export`), TimeLog (`timelog-export`) or DayLog (`daylog-export`), format version 1.

1. `ExportFile.parse` validates the header and the sections and refuses anything else.
2. `ImportPlan.build` matches every table and column of the file against the schema; an unknown one refuses the file
   and names it. Columns that the old apps wrote and the database no longer has (`app_state.display_font`,
   `time_entries.entertainment_type`) are skipped.
3. The user sees what each table will lose and confirms.
4. `DatabaseImporter.import` runs one transaction: it defers the foreign keys, deletes the rows of every table in the
   file, inserts the file's rows with their ids (values are bound parameters, names come from the schema), runs
   `PRAGMA foreign_key_check` and compares each table's row count with the file's `rowCounts`. Any failure rolls
   everything back and the database is as it was.
5. After the commit the preferences are written (`lib/database/import/preferences_writer.dart`; the language, the
   theme, the persisted timer and a pending reminder tap are never imported) and the app root's hooks reschedule
   the reminders; the shell checks the recurring rules again.

The import replaces, it does not merge: importing a file twice gives the state of importing it once. A QuestLog
file replaces the ten QuestLog tables (including the 35 events the first start seeded, so holidays are not
doubled); a TimeLog file replaces the five time tables. Fixtures written by the old apps' own export code are in
`test/database/import/fixtures/`.

#### Moving from TimeLog and QuestLog

1. In QuestLog 1.5.0 and in TimeLog 1.2.0, Settings → Data → Export data; save each file to Files.
2. Open each file and check that it is not empty; the `rowCounts` in it are the numbers to expect.
3. In DayLog, Settings → Data → Import data, pick the QuestLog file and confirm; then the TimeLog file.
4. Compare the counts in the report and the pages (quests, history) with the old apps. Keep the old apps
   installed until you have compared.

### Rules of the game

| Rule | Value |
|---|---|
| Quest XP (effort tier) | 1 Moment 10, 2 Hour 25, 3 Part of a day 50, 4 Full day 100 |
| Mission bonus | small 50, medium 100, large 200 |
| XP to advance from level L | 100 + 50 × (L − 1) |
| Board day | starts at 04:00 local time |
| Recurring cadences | daily, weekly, biweekly, monthly, quarterly, yearly |

Out of scope: streaks, XP for tracked time and any due date except the optional Quest Deadline.

### Font licences

The bundled font family (Figtree) is under the SIL Open Font License 1.1, which requires the licence text to
travel with the fonts. The unmodified text is bundled as `assets/fonts/licenses/<Family>-OFL.txt` and registered
with Flutter's `LicenseRegistry` at app start (`registerFontLicenses` in `lib/core/font_licenses.dart`). Settings
→ About → "Licenses" opens Flutter's licence page, which lists it as "<Family> (font)". A test fails when a font
file has no licence file. TimeLog's own fonts (Sora, JetBrains Mono) are zero-byte files in its repository, which Flutter cannot load, so
TimeLog's text fell back to the system font; DayLog draws everything in Figtree, with tabular figures where
TimeLog named a monospace face.

## Releases

`scripts/release.sh <version>` (for example `1.0.0` or `1.0.0-dev.0`) needs a clean working tree. It prepends a
section to `CHANGELOG.md` made of the commit subjects since the previous tag (grouped Features, Fixes, Other),
sets `version:` in `pubspec.yaml` (the one source of the version; the build number is kept), commits both as
`chore: bump version to <version>` and creates the annotated tag `v<version>`. It never pushes.

## Testing

The tests are headless and need no display (also true for the golden tests); only running the app does. A
`test/flutter_test_config.dart` gives every test file an empty SharedPreferences store and registers Figtree.

```bash
scripts/check.sh                                # analyze + all tests (about 10 min) + structure check
flutter test                                    # every test
flutter test test/core/xp_rules_test.dart       # one test file
flutter test --update-goldens test/goldens      # regenerate goldens (deliberately)
flutter analyze                                 # static analysis only
scripts/check-structure.sh --list               # file count per directory
```

`check-structure.sh` fails when a directory holds more than 15 source files.

What the tests cover: the pure rules, the database, the services (including property tests with `glados`), the
screens, accessibility, localization and design-token guards, the folder boundaries
(`test/architecture/`), the export, the importer (against the old apps' own export files), the release script, and
the TimeLog tests moved with the time tracking feature (`test/time_tracking/`). `test/ui/e2e_scenario_test.dart`
plays a whole day in the app, and the goldens in `test/goldens/` cover Board, Missions and Settings in both themes.
The time tracking feature is exempt from the token, clock and icon-font guards for now
(see `.agents/REFACTOR.md`). The real share sheet, file picker, alarm, Live Activity and notifications are not
covered; they are checked on the device.

## Troubleshooting

| Symptom | Cause and fix |
|---|---|
| `fatal: detected dubious ownership in repository at '/opt/flutter'` | Git distrusts the SDK directory. Run `git config --global --add safe.directory /opt/flutter` once. |
| The Linux build fails on `gstreamer-1.0` | `audioplayers` needs the GStreamer development packages (`libgstreamer1.0-dev`, `libgstreamer-plugins-base1.0-dev`) and, to play the alarm, the runtime plugins (`gstreamer1.0-plugins-base`, `-good`). Without root, unpack the `.deb` files (`apt-get download`, `dpkg -x`; also `libdw-dev` and `libdw1t64`) into a prefix, rewrite `prefix=` in its `.pc` files and set `PKG_CONFIG_PATH`, `LIBRARY_PATH`, `CPATH`, `LDFLAGS="-L<lib> -Wl,-rpath-link,<lib>"` and, at run time, `LD_LIBRARY_PATH` and `GST_PLUGIN_SYSTEM_PATH`. To see the window: `dbus-run-session -- xvfb-run -a --server-args="-screen 0 1280x800x24" tour.sh`, where the script starts the bundle, waits ~10 s and calls `scrot`/`xdotool`. |
| The Linux app shows a black window and never starts | The notification plugin needs a D-Bus session bus; start one (`dbus-daemon --session --fork --print-address`) and export `DBUS_SESSION_BUS_ADDRESS`, or run the app inside `dbus-run-session`. |
| `flutter run -d linux` fails with no display | Prefix it with `xvfb-run -a`; only running the app needs a display, the tests do not. |
| Analyzer errors about a missing `app_database.g.dart` or `timer_service.freezed.dart` | Run `dart run build_runner build`; it takes a few minutes, so give it a longer timeout than a shell's default. |
| Widget tests overflow although the app does not | Tests draw text in the Ahem fallback unless the bundled fonts are loaded; `test/flutter_test_config.dart` loads Figtree for every test. |
| A widget test hangs on a database query | A query started while a widget mounts runs in the fake-async zone and cannot finish; seed first, and start loads after the first frame. |
| A test hangs while it reads a Riverpod stream | Riverpod 3 pauses stream providers without a listener; call `container.listen(provider, (_, _) {})` first. |
| A screen throws "tried to modify a provider while the widget tree was building" | Riverpod 3 forbids it: start the load after the first frame (`addPostFrameCallback`), as `ReminderActionScreen` does. |
| Importing `glados` and `flutter_test` is ambiguous | Hide the clashing symbols on the `glados` import. |
| Goldens differ after a design change | Regenerate them with `--update-goldens` and review the images in the diff. |
| The Live Activity never appears on iOS | It needs iOS 16.2 or newer and Live Activities enabled for the app; `startLiveActivity` then returns `false` and the app goes on without it. That is expected. |
| A timer does not resume after a force quit | The state is restored from SharedPreferences by recomputing the remaining time from the stored end time; if it already elapsed the timer comes back ringing. |

Working notes and the cleanup list are in `.agents/REFACTOR.md`.
