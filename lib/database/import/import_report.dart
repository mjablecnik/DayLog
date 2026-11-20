/// Why an import was refused or undone. The message of an [ImportFailure] is
/// for the log; the UI shows a localized text chosen by [kind].
enum ImportFailureKind {
  notJson,
  wrongFormat,
  newerFormat,
  missingSection,
  unknownTable,
  unknownColumn,
  foreignKey,
  countMismatch,
}

class ImportFailure implements Exception {
  const ImportFailure(this.kind, this.detail);

  final ImportFailureKind kind;

  /// The table, column or format the failure is about; empty when none.
  final String detail;

  @override
  String toString() => 'ImportFailure(${kind.name}${detail.isEmpty ? '' : ': $detail'})';
}

/// The rows of one table: read from the file, written, and expected by the
/// file's own counts.
class TableResult {
  const TableResult({required this.table, required this.read, required this.written, required this.expected});

  final String table;
  final int read;
  final int written;
  final int expected;
}

class ImportReport {
  const ImportReport({
    required this.format,
    required this.tables,
    required this.preferencesWritten,
    required this.preferenceCount,
    this.warnings = const <String>[],
  });

  /// The `format` of the imported file.
  final String format;
  final List<TableResult> tables;

  /// False when the file had preferences and writing them failed.
  final bool preferencesWritten;
  final int preferenceCount;

  /// Steps after the commit that failed (rescheduling, refreshing); the data is
  /// imported nevertheless.
  final List<String> warnings;

  int get rowsWritten => tables.fold(0, (int sum, TableResult t) => sum + t.written);
}
