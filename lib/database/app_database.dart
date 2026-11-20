import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
// DriftRemoteException is the only way the background isolate reports a failure.
// ignore: experimental_member_use
import 'package:drift/remote.dart' show DriftRemoteException;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../quests/domain/cadence.dart';
import '../core/errors.dart';
import '../quests/domain/xp_rules.dart';
import '../calendar/data/calendar_seed.dart';
import '../calendar/data/calendar_tables.dart';
import '../quests/data/models.dart';
import '../notes/data/notes_tables.dart';
import 'preferences.dart';
import '../quests/data/tables.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Missions,
    Quests,
    RecurringRules,
    RuleQuests,
    AppState,
    CalendarEvents,
    CalendarSkippedDates,
    CalendarCompletions,
    CalendarAddresses,
    NoteNodes,
  ],
)
class AppDatabase extends _$AppDatabase {
  /// Opens the on-device database file, lazily on first use.
  AppDatabase() : super(_openFileDatabase());

  /// Uses the given [executor], for example `NativeDatabase.memory()` in tests.
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  /// Runs [action] in a transaction (joining the active one, if any).
  ///
  /// A [DomainError] thrown by [action] rolls the transaction back and is
  /// rethrown as is; a SQLite failure is rolled back and rethrown as a
  /// [StorageError] (also when it comes back from the database isolate), so
  /// callers only ever see domain errors.
  Future<T> runTransaction<T>(Future<T> Function() action) async {
    try {
      return await transaction(action);
    } on DomainError {
      rethrow;
    } on SqliteException catch (error) {
      throw StorageError(error);
    } on DriftWrappedException catch (error) {
      throw StorageError(error);
    } on DriftRemoteException catch (error) {
      // The file database runs in a background isolate, which reports every
      // SQLite failure this way instead of as the SqliteException itself.
      throw StorageError(error.remoteCause);
    }
  }

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          // The singleton row: Total_XP 0 and the default settings.
          await into(appState).insert(AppStateCompanion.insert());
          // The built-in holidays and notable days: inserted here and nowhere else,
          // so a deleted one stays deleted.
          await seedCalendarDefaults(this);
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );
}

QueryExecutor _openFileDatabase() {
  return LazyDatabase(() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File(p.join(directory.path, 'zafling.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
