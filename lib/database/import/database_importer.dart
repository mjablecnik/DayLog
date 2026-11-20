import 'dart:convert';

import 'package:drift/drift.dart';

import '../app_database.dart';
import 'export_file.dart';
import 'import_plan.dart';
import 'import_report.dart';

/// What the importer needs from the rest of the app. The app root supplies the
/// real ones; the importer itself knows no feature.
class ImportHooks {
  const ImportHooks({required this.writePreferences, required this.afterImport});

  /// Writes the preferences of an export file; returns how many were written.
  final Future<int> Function(Map<String, Object?> preferences) writePreferences;

  /// Runs after the data is committed: reschedule reminders, refresh state.
  final Future<void> Function() afterImport;

  /// Hooks that do nothing.
  static final ImportHooks none = ImportHooks(
    writePreferences: (Map<String, Object?> preferences) async => 0,
    afterImport: () async {},
  );
}

/// Replaces the tables named in an [ExportFile] with its rows, in one
/// transaction, and checks the result against the file's own counts before it
/// commits. Anything that does not add up rolls the whole import back.
class DatabaseImporter {
  DatabaseImporter(this._db, this._hooks);

  final AppDatabase _db;
  final ImportHooks _hooks;

  /// The rows that are in each table of [file] now, i.e. what an import would
  /// delete. Throws the same [ImportFailure]s as [import] for a file that does
  /// not match the Database.
  Future<Map<String, int>> currentCounts(ExportFile file) async {
    final ImportPlan plan = ImportPlan.build(file, _db);
    return <String, int>{
      for (final PlannedTable t in plan.tables) t.name: await _count(t.name),
    };
  }

  /// Imports [file]. A failure inside the transaction leaves the Database as it
  /// was and is rethrown as an [ImportFailure].
  Future<ImportReport> import(ExportFile file) async {
    final ImportPlan plan = ImportPlan.build(file, _db);
    final List<TableResult> results = <TableResult>[];
    await _db.transaction(() async {
      // Rows reference each other in any order: the references are checked
      // once, at the end.
      await _db.customStatement('PRAGMA defer_foreign_keys = ON');
      for (final PlannedTable table in plan.tables) {
        await _db.customStatement('DELETE FROM "${table.name}"');
      }
      for (final PlannedTable table in plan.tables) {
        for (final Map<String, Object?> row in table.rows) {
          await _insert(table.name, row);
        }
      }
      final List<QueryRow> violations = await _db.customSelect('PRAGMA foreign_key_check').get();
      if (violations.isNotEmpty) {
        throw ImportFailure(ImportFailureKind.foreignKey, violations.first.read<String>('table'));
      }
      for (final PlannedTable table in plan.tables) {
        final int written = await _count(table.name);
        if (written != table.expected || table.rows.length != table.expected) {
          throw ImportFailure(
            ImportFailureKind.countMismatch,
            '${table.name}: expected ${table.expected}, got $written',
          );
        }
        results.add(
          TableResult(table: table.name, read: table.rows.length, written: written, expected: table.expected),
        );
      }
    });

    bool preferencesWritten = true;
    int preferenceCount = 0;
    final List<String> warnings = <String>[];
    if (file.preferences.isNotEmpty) {
      try {
        preferenceCount = await _hooks.writePreferences(file.preferences);
      } catch (error) {
        preferencesWritten = false;
        warnings.add('preferences: $error');
      }
    }
    try {
      await _hooks.afterImport();
    } catch (error) {
      warnings.add('after import: $error');
    }
    return ImportReport(
      format: file.header.format,
      tables: results,
      preferencesWritten: preferencesWritten,
      preferenceCount: preferenceCount,
      warnings: warnings,
    );
  }

  /// Table and column names come from the validated plan; values are always
  /// bound parameters.
  Future<void> _insert(String table, Map<String, Object?> row) {
    final List<String> columns = row.keys.toList();
    final String names = columns.map((String c) => '"$c"').join(', ');
    final String marks = List<String>.filled(columns.length, '?').join(', ');
    return _db.customStatement(
      'INSERT INTO "$table" ($names) VALUES ($marks)',
      <Object?>[for (final String c in columns) decodeValue(row[c])],
    );
  }

  Future<int> _count(String table) async {
    final QueryRow row = await _db.customSelect('SELECT COUNT(*) AS c FROM "$table"').getSingle();
    return row.read<int>('c');
  }

  /// `{"$blob": "<base64>"}` becomes bytes; everything else is written as it is.
  static Object? decodeValue(Object? value) {
    if (value is Map<String, Object?> && value.length == 1 && value[r'$blob'] is String) {
      return base64Decode(value[r'$blob']! as String);
    }
    return value;
  }
}
