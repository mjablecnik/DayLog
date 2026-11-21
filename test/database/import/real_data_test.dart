@Tags(<String>['real-data'])
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:daylog/database/app_database.dart';
import 'package:daylog/database/import/database_importer.dart';
import 'package:daylog/database/import/export_file.dart';
import 'package:daylog/database/import/import_report.dart';

import '../../helpers/test_database.dart';

/// Imports the real export files of the old apps. They are personal data: they
/// live in `.import/` (gitignored), and this test prints only counts.
void main() {
  final Directory folder = Directory('.import');
  final List<File> files = folder.existsSync()
      ? (folder.listSync().whereType<File>().where((File f) => f.path.endsWith('.json')).toList()..sort(
          (File a, File b) => a.path.compareTo(b.path),
        ))
      : <File>[];

  test('the real export files import with matching row counts', () async {
    if (files.isEmpty) {
      markTestSkipped('no export files in .import/');
      return;
    }
    final AppDatabase db = createTestDatabase();
    addTearDown(db.close);
    final DatabaseImporter importer = DatabaseImporter(db, ImportHooks.none);
    for (final File file in files) {
      final ExportFile export = ExportFile.parse(file.readAsStringSync());
      final ImportReport report = await importer.import(export);
      for (final TableResult t in report.tables) {
        expect(t.written, t.expected, reason: '${export.header.format} ${t.table}');
      }
      // Counts only, never content.
      printOnFailure(jsonEncode(<String, int>{for (final TableResult t in report.tables) t.table: t.written}));
    }
  });
}
