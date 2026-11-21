import 'dart:convert';

import 'import_report.dart';

/// The `format` values of the export files the importer reads: the two old apps
/// and the app itself.
const Set<String> knownExportFormats = <String>{'questlog-export', 'timelog-export', 'daylog-export'};

/// The highest `formatVersion` the importer understands.
const int highestExportFormatVersion = 1;

class ExportHeader {
  const ExportHeader({
    required this.format,
    required this.formatVersion,
    required this.app,
    required this.appVersion,
    required this.schemaVersion,
    required this.exportedAt,
    required this.rowCounts,
  });

  final String format;
  final int formatVersion;
  final String app;
  final String appVersion;
  final int schemaVersion;
  final DateTime exportedAt;
  final Map<String, int> rowCounts;
}

/// A parsed export file: the header, every table as rows keyed by column name,
/// and the preferences (empty for a file without any).
class ExportFile {
  const ExportFile({required this.header, required this.tables, required this.preferences});

  final ExportHeader header;
  final Map<String, List<Map<String, Object?>>> tables;
  final Map<String, Object?> preferences;

  /// Parses and validates [text]; throws an [ImportFailure] for anything that
  /// is not an export file the importer can read.
  static ExportFile parse(String text) {
    final Object? decoded;
    try {
      decoded = jsonDecode(text);
    } on FormatException {
      throw const ImportFailure(ImportFailureKind.notJson, '');
    }
    if (decoded is! Map<String, Object?>) {
      throw const ImportFailure(ImportFailureKind.notJson, 'not an object');
    }
    final Object? format = decoded['format'];
    if (format is! String || !knownExportFormats.contains(format)) {
      throw ImportFailure(ImportFailureKind.wrongFormat, '$format');
    }
    final Object? version = decoded['formatVersion'];
    if (version is! int) throw const ImportFailure(ImportFailureKind.missingSection, 'formatVersion');
    if (version > highestExportFormatVersion) {
      throw ImportFailure(ImportFailureKind.newerFormat, '$version');
    }
    final Object? exportedAt = decoded['exportedAt'];
    final DateTime? when = exportedAt is String ? DateTime.tryParse(exportedAt) : null;
    if (when == null) throw const ImportFailure(ImportFailureKind.missingSection, 'exportedAt');
    final Object? counts = decoded['rowCounts'];
    if (counts is! Map<String, Object?>) {
      throw const ImportFailure(ImportFailureKind.missingSection, 'rowCounts');
    }
    final Object? tablesJson = decoded['tables'];
    if (tablesJson is! Map<String, Object?>) {
      throw const ImportFailure(ImportFailureKind.missingSection, 'tables');
    }
    final Map<String, int> rowCounts = <String, int>{};
    for (final MapEntry<String, Object?> e in counts.entries) {
      final Object? n = e.value;
      if (n is! int) throw ImportFailure(ImportFailureKind.missingSection, 'rowCounts.${e.key}');
      rowCounts[e.key] = n;
    }
    final Map<String, List<Map<String, Object?>>> tables = <String, List<Map<String, Object?>>>{};
    for (final MapEntry<String, Object?> e in tablesJson.entries) {
      final Object? rows = e.value;
      if (rows is! List) throw ImportFailure(ImportFailureKind.missingSection, 'tables.${e.key}');
      tables[e.key] = <Map<String, Object?>>[
        for (final Object? row in rows)
          if (row is Map<String, Object?>)
            row
          else
            throw ImportFailure(ImportFailureKind.missingSection, 'tables.${e.key} row'),
      ];
    }
    final Object? prefs = decoded['preferences'];
    return ExportFile(
      header: ExportHeader(
        format: format,
        formatVersion: version,
        app: decoded['app'] is String ? decoded['app']! as String : '',
        appVersion: decoded['appVersion'] is String ? decoded['appVersion']! as String : '',
        schemaVersion: decoded['schemaVersion'] is int ? decoded['schemaVersion']! as int : 0,
        exportedAt: when,
        rowCounts: rowCounts,
      ),
      tables: tables,
      preferences: prefs is Map<String, Object?> ? prefs : const <String, Object?>{},
    );
  }
}
