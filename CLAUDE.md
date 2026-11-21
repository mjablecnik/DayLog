# DayLog

Personal app for one user (Martin), the merger of two earlier Flutter apps: **TimeLog** (a countdown timer that
logs time, with History, Statistics and reminders) and **QuestLog** (Quests and Missions with XP, a Calendar,
Notes). It is a pure move of their features plus an importer for their data; do not add features that neither app
had. Flutter, iOS primary (Linux desktop is used for development and tests), one local SQLite database via Drift +
Riverpod 3 — no server, no account, no network at runtime. Code and docs are English; the UI is Czech and English.

## Status

Specs `001-app-foundation`, `002-time-tracking-port` and `003-legacy-import` in `.kiro/specs/` are implemented;
`scripts/check.sh` is green. The first release is `1.0.0-dev.0`. Specs `004-design-system`, `005-module-navigation` and `006-screen-redesign` (the redesign agreed on
2026-11-21) are written but not implemented; implement them in that order. Their visual reference is
`.design/redesign-preview/` (start with its `README.md`). Not checked here (Martin does it on the iPhone):
the iOS build, the Live Activity, the alarm sound, notifications and taps on them, the share sheet and file picker.
The old apps stay installed beside it until the import is compared (QuestLog tag `v1.5.0`, TimeLog tag `v1.2.0`, in
`/workspace/QuestLog` and `/workspace/TimeLog`; they are read-only archives).

The name DayLog (before 2026-11-21 the trial name Zafling) lives in `pubspec.yaml` (`name`), `ios/` (bundle id `com.jablecnik.daylog`,
App Group, extension target, Info.plist), `linux/`, the URL scheme (`lib/core/app_identity.dart`), the channel names
in `lib/time_tracking/services/native/platform_channel.dart` and Swift, and the ARB key `app_name`.

## Commands

Run from the project root. Once per sandbox: `git config --global --add safe.directory /opt/flutter` (skill
`sandbox-flutter`).

```bash
flutter pub get
timeout 500 dart run build_runner build   # Drift + freezed codegen, 1-3 min: run it in the background and poll the log
flutter gen-l10n                          # after editing an .arb file (app_cs.arb is the template)
scripts/check.sh                          # analyze + all tests (~10 min) + structure check: the gate
flutter test test/core/xp_rules_test.dart                  # one test file
flutter test --update-goldens test/goldens                 # regenerate goldens, deliberately
scripts/release.sh 1.0.0                  # bump pubspec, write CHANGELOG.md, commit, tag (clean tree only)
```

The Linux build needs GStreamer dev packages and a D-Bus session at run time. The sandbox has no root: download
the `.deb` files with `apt-get download`, unpack them with `dpkg -x` into a scratch prefix, point the `.pc` files at
it and build with `PKG_CONFIG_PATH`, `LIBRARY_PATH`, `CPATH`, `LDFLAGS=-Wl,-rpath-link,...` and `LD_LIBRARY_PATH`
set to it (see DOCS.md Troubleshooting). Run it with `dbus-run-session -- xvfb-run -a`, then `scrot` and `xdotool` (skill `sandbox-flutter-linux-run`). To look at the screens without a device, pump the app in a widget test and write the
`RepaintBoundary` image to a file.

## Layout

```
lib/
  main.dart, app.dart   entry point; root widget (theme registry, locale, reward overlay, shell)
  core/ database/ theme/ ui_kit/ l10n/   shared building blocks (database/export, database/import)
  shell/                bottom bar (5 tabs), drawer (all pages), deep links, reconciliation
  settings/             settings screen, shortcut guide, export and import rows; takes module groups from the shell
  quests/ calendar/ notes/   the QuestLog modules (data/, domain/, services/, ui/)
  time_tracking/        the TimeLog feature; public surface is time_tracking.dart
test/                   mirrors lib/ + goldens/, helpers/, architecture/, scripts/
.kiro/specs/            001 foundation, 002 time tracking port, 003 legacy import, 004-006 redesign (not implemented)
.design/                visual design inherited from QuestLog; redesign-preview/ is the reference of specs 004-006
.agents/REFACTOR.md     the cleanup list; read it before refactoring
```

Humans read `README.md`, `FEATURES.md`, `DOCS.md` and `CHANGELOG.md`; do not duplicate them here.

## Rules for any agent working here

- Follow the Kiro spec workflow (`kiro-spec` skill) and the global standards in `~/.claude/standards/`.
- The folder boundaries are tested (`test/architecture/feature_imports_test.dart`): `time_tracking/` imports only
  itself, `core/`, `theme/`, `ui_kit/`, `l10n/` and `database/`; the QuestLog modules never import `time_tracking/`
  or `shell/`. Put a shared piece in `core/`, `database/`, `theme/` or `ui_kit/`.
- Screens read colours from `context.palette`; a new theme is a `ThemeDefinition` in `lib/theme/theme_registry.dart`.
- In `lib/` outside `time_tracking/`: no `DateTime.now` outside `lib/core/clock.dart`, no literal colours, durations
  or spacing in UI code, no icon-font icons; guard tests under `test/` fail on them. `time_tracking/` is exempt until
  the cleanup in `.agents/REFACTOR.md` is done; do not add new violations there either.
- Every user-facing string goes through the ARB files in both languages, with a prefix of its feature
  (`time_`, `settings_`, `shell_`, ...) and a description in `app_cs.arb`.
- A schema change needs a migration step and a new dump in `drift_schemas/`; the importer's `retiredColumns` and
  `retiredTables` list the columns and tables old exports hold that no longer exist.
- Startup lives in `lib/startup.dart` (`buildApp`), `main.dart` stays thin; `test/startup_test.dart` runs it with fakes
  and a time limit. Riverpod 3 pauses a provider nobody listens to: before the first frame wait through
  `loadSettings` (`lib/settings/settings_loader.dart`), never `container.read(provider.future)` alone.
- After a change that touches startup, run the real Linux app and look at the first screen (skill
  `sandbox-flutter-linux-run`); the tests cannot see a hung start.
- Riverpod 3: never change a provider while a widget builds; the TimeLog code uses `flutter_riverpod/legacy.dart`
  (`StateNotifier`, `StateProvider`) and is not converted yet.
- Where `.design/` artboards and spec requirements differ, the requirements win.

## Sandbox gotchas

- Only Linux desktop/web run here; the iOS build and device checks are Martin's.
- Do NOT add `sqlite3_flutter_libs`. `glados` clashes with `flutter_test` names: hide the clashing symbols.
- Widget tests that mount the shell need `test/flutter_test_config.dart` (empty SharedPreferences, Figtree); a query
  started while a widget mounts cannot finish in the fake-async zone.
- Never `pkill -f` / `pgrep -f` by pattern, and never run `dart format` on a whole file that is not already formatted.
- The real export files of the old apps are personal data: keep them in `.import/` (gitignored), never commit them or
  print their content.

## Git

Local repository, no remote: never push. Author exactly `Martin Jablečník <martin.jablecnik@email.cz>`; one
Conventional Commit per task or logical change, per `~/.claude/standards/code-git.md`; dependency changes in their own
`build:` commit. Never add tool-attribution trailers (no Co-Authored-By/Generated-with/session links). Releases are
made with `scripts/release.sh`.
