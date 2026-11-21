import 'package:drift/drift.dart';

import 'export_file.dart';
import 'import_report.dart';

/// One table of an import: the Database table, the columns the file uses and
/// the rows to write.
class PlannedTable {
  const PlannedTable({required this.name, required this.columns, required this.rows, required this.expected});

  final String name;

  /// Every column the rows use, validated against the Database table.
  final List<String> columns;
  final List<Map<String, Object?>> rows;

  /// The row count the file states for the table.
  final int expected;
}

/// What an [ExportFile] will do to a Database: which tables are replaced, with
/// which rows. Built before anything is written, so an unreadable file changes
/// nothing.
class ImportPlan {
  const ImportPlan(this.tables);

  final List<PlannedTable> tables;

  /// Columns an old export holds and the Database no longer has. They are
  /// skipped, not refused.
  static const Map<String, Set<String>> retiredColumns = <String, Set<String>>{
    'app_state': <String>{'display_font'},
    'time_entries': <String>{'entertainment_type'},
  };

  /// Tables an old export holds and the Database no longer has (the Tasks of
  /// TimeLog). Their rows are skipped, not refused.
  static const Set<String> retiredTables = <String>{'tasks', 'task_projects'};

  /// Matches the names in [file] against the schema of [db]; throws an
  /// [ImportFailure] for a table or column the Database does not have. The
  /// names come from the file, so only names found in the schema are ever
  /// written into SQL.
  factory ImportPlan.build(ExportFile file, GeneratedDatabase db) {
    final Map<String, TableInfo<Table, dynamic>> known = <String, TableInfo<Table, dynamic>>{
      for (final TableInfo<Table, dynamic> t in db.allTables) t.actualTableName: t,
    };
    final List<PlannedTable> planned = <PlannedTable>[];
    for (final MapEntry<String, List<Map<String, Object?>>> entry in file.tables.entries) {
      if (retiredTables.contains(entry.key)) continue;
      final TableInfo<Table, dynamic>? table = known[entry.key];
      if (table == null) throw ImportFailure(ImportFailureKind.unknownTable, entry.key);
      final Set<String> columns = <String>{for (final GeneratedColumn<Object> c in table.$columns) c.$name};
      final Set<String> retired = retiredColumns[entry.key] ?? const <String>{};
      final Set<String> used = <String>{};
      final List<Map<String, Object?>> rows = <Map<String, Object?>>[];
      for (final Map<String, Object?> row in entry.value) {
        final Map<String, Object?> kept = <String, Object?>{};
        for (final MapEntry<String, Object?> cell in row.entries) {
          if (retired.contains(cell.key)) continue;
          if (!columns.contains(cell.key)) {
            throw ImportFailure(ImportFailureKind.unknownColumn, '${entry.key}.${cell.key}');
          }
          kept[cell.key] = cell.value;
          used.add(cell.key);
        }
        rows.add(kept);
      }
      planned.add(
        PlannedTable(
          name: entry.key,
          columns: used.toList(),
          rows: rows,
          expected: file.header.rowCounts[entry.key] ?? rows.length,
        ),
      );
    }
    return ImportPlan(planned);
  }
}
