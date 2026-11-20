import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:zafling/database/import/export_file.dart';
import 'package:zafling/database/import/import_report.dart';

String _fixture(String name) => File('test/database/import/fixtures/$name').readAsStringSync();

Map<String, Object?> _valid() => <String, Object?>{
  'format': 'questlog-export',
  'formatVersion': 1,
  'app': 'questlog',
  'appVersion': '1.5.0',
  'schemaVersion': 6,
  'exportedAt': '2026-11-20T12:00:00.000',
  'rowCounts': <String, Object?>{'quests': 1},
  'tables': <String, Object?>{
    'quests': <Object?>[
      <String, Object?>{'id': 1, 'name': 'A'},
    ],
  },
};

void expectFailure(String text, ImportFailureKind kind) {
  expect(
    () => ExportFile.parse(text),
    throwsA(isA<ImportFailure>().having((ImportFailure f) => f.kind, 'kind', kind)),
  );
}

void main() {
  test('reads the QuestLog and the TimeLog files written by the old apps', () {
    final ExportFile q = ExportFile.parse(_fixture('questlog-export.json'));
    expect(q.header.format, 'questlog-export');
    expect(q.header.appVersion, '1.5.0');
    expect(q.tables.keys, contains('quests'));
    expect(q.header.rowCounts['quests'], q.tables['quests']!.length);
    expect(q.preferences, isEmpty);

    final ExportFile t = ExportFile.parse(_fixture('timelog-export.json'));
    expect(t.header.format, 'timelog-export');
    expect(t.tables['time_entries'], hasLength(4));
    expect(t.preferences['reminder_hour'], 8);
  });

  test('reads a file of the app itself', () {
    final Map<String, Object?> data = _valid()..['format'] = 'zafling-export';
    expect(ExportFile.parse(jsonEncode(data)).header.format, 'zafling-export');
  });

  test('refuses text that is not JSON, not an object, or another format', () {
    expectFailure('not json', ImportFailureKind.notJson);
    expectFailure('[1, 2]', ImportFailureKind.notJson);
    expectFailure(jsonEncode(_valid()..['format'] = 'other'), ImportFailureKind.wrongFormat);
    expectFailure(jsonEncode(_valid()..remove('format')), ImportFailureKind.wrongFormat);
  });

  test('refuses a format version newer than the importer knows', () {
    expectFailure(jsonEncode(_valid()..['formatVersion'] = highestExportFormatVersion + 1), ImportFailureKind.newerFormat);
  });

  test('refuses a file without its sections', () {
    for (final String key in <String>['formatVersion', 'exportedAt', 'rowCounts', 'tables']) {
      expectFailure(jsonEncode(_valid()..remove(key)), ImportFailureKind.missingSection);
    }
    expectFailure(jsonEncode(_valid()..['tables'] = <String, Object?>{'quests': 5}), ImportFailureKind.missingSection);
    expectFailure(
      jsonEncode(_valid()..['rowCounts'] = <String, Object?>{'quests': 'one'}),
      ImportFailureKind.missingSection,
    );
  });
}
