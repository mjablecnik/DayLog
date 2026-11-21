import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:zafling/database/app_database.dart';
import 'package:zafling/database/export/database_export.dart';
import 'package:zafling/database/import/database_importer.dart';
import 'package:zafling/database/import/export_file.dart';
import 'package:zafling/database/import/import_plan.dart';
import 'package:zafling/database/import/import_report.dart';

import '../../helpers/test_database.dart';

String _fixture(String name) => File('test/database/import/fixtures/$name').readAsStringSync();

/// Every table of [db] as decoded JSON, the way an export holds it.
Future<Map<String, Object?>> _tables(AppDatabase db) async {
  final Map<String, Object?> data = await exportDatabase(
    db,
    appName: 'test',
    appVersion: '0',
    exportedAt: DateTime(2026),
  );
  return jsonDecode(jsonEncode(data['tables'])) as Map<String, Object?>;
}

/// The rows of [file] as they must be after an import: without the columns the
/// Database no longer has.
Map<String, Object?> _expected(ExportFile file) => <String, Object?>{
  for (final MapEntry<String, List<Map<String, Object?>>> t in file.tables.entries)
    if (!ImportPlan.retiredTables.contains(t.key))
      t.key: <Map<String, Object?>>[
      for (final Map<String, Object?> row in t.value)
        <String, Object?>{
          for (final MapEntry<String, Object?> c in row.entries)
            if (!(ImportPlan.retiredColumns[t.key] ?? const <String>{}).contains(c.key)) c.key: c.value,
        },
    ],
};

ExportFile _fromMap(Map<String, Object?> data) => ExportFile.parse(jsonEncode(data));

void main() {
  late AppDatabase db;
  late List<Map<String, Object?>> written;
  int afterImportCalls = 0;
  late DatabaseImporter importer;

  setUp(() {
    db = createTestDatabase();
    written = <Map<String, Object?>>[];
    afterImportCalls = 0;
    importer = DatabaseImporter(
      db,
      ImportHooks(
        writePreferences: (Map<String, Object?> p) async {
          written.add(p);
          return p.length;
        },
        afterImport: () async => afterImportCalls++,
      ),
    );
  });
  tearDown(() => db.close());

  group('a QuestLog 1.5.0 export', () {
    late ExportFile file;
    setUp(() => file = ExportFile.parse(_fixture('questlog-export.json')));

    // Feature: legacy-import, Property 1: Round trip
    test('every imported table equals the source, row by row', () async {
      await importer.import(file);
      final Map<String, Object?> after = await _tables(db);
      final Map<String, Object?> expected = _expected(file);
      for (final String table in expected.keys) {
        expect(after[table], expected[table], reason: table);
      }
    });

    // Feature: legacy-import, Property 5: Counts match
    test('the report lists the rows read, written and expected, equal for every table', () async {
      final ImportReport report = await importer.import(file);
      expect(report.format, 'questlog-export');
      expect(report.tables.map((TableResult t) => t.table).toSet(), file.tables.keys.toSet());
      for (final TableResult t in report.tables) {
        expect(t.read, t.written, reason: t.table);
        expect(t.written, file.header.rowCounts[t.table], reason: t.table);
        expect(t.expected, t.written, reason: t.table);
      }
      expect(report.preferencesWritten, isTrue);
      expect(afterImportCalls, 1);
    });

    test('the seeded built-in events are replaced, not doubled', () async {
      expect(await db.select(db.calendarEvents).get(), hasLength(35));
      await importer.import(file);
      expect(await db.select(db.calendarEvents).get(), hasLength(file.header.rowCounts['calendar_events']));
    });

    test('the settings of the old app come with it', () async {
      await importer.import(file);
      final AppStateRow state = await db.select(db.appState).getSingle();
      expect(state.heroName, 'Martin');
      expect(state.totalXp, 185);
    });

    // Feature: legacy-import, Property 2: Idempotence
    test('importing the same file twice leaves the same state as once', () async {
      await importer.import(file);
      final Map<String, Object?> once = await _tables(db);
      await importer.import(file);
      expect(await _tables(db), once);
    });

    test('currentCounts tells what an import would delete', () async {
      final Map<String, int> counts = await importer.currentCounts(file);
      expect(counts['calendar_events'], 35);
      expect(counts['quests'], 0);
      expect(counts.keys.toSet(), file.tables.keys.toSet());
    });

    test('new rows continue above the highest imported id', () async {
      await importer.import(file);
      final int maxId = (file.tables['quests']!.map((Map<String, Object?> r) => r['id']! as int)).reduce(max);
      final int next = await db.customInsert(
        "INSERT INTO quests (name, difficulty, sort_order, created_at) VALUES ('new', 'easy', 99, 1)",
      );
      expect(next, greaterThan(maxId));
    });
  });

  group('a TimeLog 1.2.0 export', () {
    late ExportFile file;
    setUp(() => file = ExportFile.parse(_fixture('timelog-export.json')));

    test('every imported table equals the source; the retired column is dropped', () async {
      await importer.import(file);
      final Map<String, Object?> after = await _tables(db);
      final Map<String, Object?> expected = _expected(file);
      for (final String table in expected.keys) {
        expect(after[table], expected[table], reason: table);
      }
      expect(file.tables.keys, containsAll(ImportPlan.retiredTables), reason: 'the fixture holds Tasks');
      expect(after.keys, isNot(contains('tasks')));
      expect(after.keys, isNot(contains('task_projects')));
      final Map<String, Object?> firstEntry = (after['time_entries']! as List).first as Map<String, Object?>;
      expect(firstEntry.containsKey('entertainment_type'), isFalse);
    });

    test('the Quest tables are left alone', () async {
      await importer.import(file);
      expect(await db.select(db.calendarEvents).get(), hasLength(35));
      expect(await db.select(db.appState).get(), hasLength(1));
    });

    test('the preferences go to the writer, with the ignored keys still in the map for it to skip', () async {
      final ImportReport report = await importer.import(file);
      expect(written, hasLength(1));
      expect(written.single['reminder_hour'], 8);
      expect(report.preferenceCount, written.single.length);
    });

    test('a failing preference write leaves the data imported and says so', () async {
      final DatabaseImporter failing = DatabaseImporter(
        db,
        ImportHooks(
          writePreferences: (Map<String, Object?> p) async => throw StateError('disk'),
          afterImport: () async {},
        ),
      );
      final ImportReport report = await failing.import(file);
      expect(report.preferencesWritten, isFalse);
      expect(report.warnings.single, contains('disk'));
      expect(await db.select(db.timeEntries).get(), hasLength(4));
    });

    test('a failing step after the import is reported, not thrown', () async {
      final DatabaseImporter failing = DatabaseImporter(
        db,
        ImportHooks(writePreferences: (Map<String, Object?> p) async => 0, afterImport: () async => throw StateError('later')),
      );
      final ImportReport report = await failing.import(file);
      expect(report.warnings.single, contains('later'));
    });
  });

  group('a file that does not fit', () {
    Map<String, Object?> base() => jsonDecode(_fixture('timelog-export.json')) as Map<String, Object?>;

    // Feature: legacy-import, Property 3: Atomicity
    test('a table the Database does not have is refused before anything changes', () async {
      final Map<String, Object?> data = base();
      (data['tables']! as Map<String, Object?>)['mystery'] = <Object?>[];
      await db.customStatement("INSERT INTO time_entries (start_time, end_time, description) VALUES ('a', 'b', 'mine')");
      final Map<String, Object?> before = await _tables(db);
      await expectLater(
        importer.import(_fromMap(data)),
        throwsA(isA<ImportFailure>().having((ImportFailure f) => f.kind, 'kind', ImportFailureKind.unknownTable)),
      );
      expect(await _tables(db), before);
    });

    test('a column the Database does not have is refused and named', () async {
      final Map<String, Object?> data = base();
      (((data['tables']! as Map<String, Object?>)['time_entries']! as List).first as Map<String, Object?>)['mystery'] = 1;
      await expectLater(
        importer.import(_fromMap(data)),
        throwsA(isA<ImportFailure>().having((ImportFailure f) => f.detail, 'detail', 'time_entries.mystery')),
      );
    });

    test('a reference to a missing row rolls everything back', () async {
      final Map<String, Object?> data = base();
      ((data['tables']! as Map<String, Object?>)['completion_records']! as List).add(<String, Object?>{
        'id': 99,
        'reminder_id': 12345,
        'completion_date': '2026-11-19',
        'completion_timestamp': '2026-11-19T12:00:00',
      });
      (data['rowCounts']! as Map<String, Object?>)['completion_records'] = 2;
      await db.customStatement("INSERT INTO time_entries (start_time, end_time, description) VALUES ('a', 'b', 'mine')");
      final Map<String, Object?> before = await _tables(db);
      await expectLater(
        importer.import(_fromMap(data)),
        throwsA(isA<ImportFailure>().having((ImportFailure f) => f.kind, 'kind', ImportFailureKind.foreignKey)),
      );
      expect(await _tables(db), before);
    });

    test('a count that disagrees with the rows rolls everything back', () async {
      final Map<String, Object?> data = base();
      (data['rowCounts']! as Map<String, Object?>)['time_entries'] = 5;
      await db.customStatement("INSERT INTO time_entries (start_time, end_time, description) VALUES ('a', 'b', 'mine')");
      final Map<String, Object?> before = await _tables(db);
      await expectLater(
        importer.import(_fromMap(data)),
        throwsA(isA<ImportFailure>().having((ImportFailure f) => f.kind, 'kind', ImportFailureKind.countMismatch)),
      );
      expect(await _tables(db), before);
      expect(afterImportCalls, 0);
      expect(written, isEmpty);
    });
  });

  // Feature: legacy-import, Property 4: Blob fidelity
  test('a blob value is decoded into the same bytes, any other value is kept', () {
    final Random random = Random(4);
    for (int round = 0; round < 50; round++) {
      final Uint8List bytes = Uint8List.fromList(<int>[for (int i = 0; i < random.nextInt(64); i++) random.nextInt(256)]);
      final Object? decoded = DatabaseImporter.decodeValue(<String, Object?>{r'$blob': base64Encode(bytes)});
      expect(decoded, isA<Uint8List>());
      expect(decoded, bytes);
    }
    expect(DatabaseImporter.decodeValue(5), 5);
    expect(DatabaseImporter.decodeValue('x'), 'x');
    expect(DatabaseImporter.decodeValue(null), isNull);
    expect(DatabaseImporter.decodeValue(<String, Object?>{'a': 1, r'$blob': 'AA=='}), isA<Map<String, Object?>>());
  });

  // Feature: legacy-import, Property 1: Round trip (generated rows)
  test('random content exported by the app itself imports into an empty database unchanged', () async {
    final Random random = Random(1);
    for (int round = 0; round < 10; round++) {
      final AppDatabase source = createTestDatabase();
      for (int i = 0; i < random.nextInt(8) + 1; i++) {
        final int mission = await source.customInsert(
          "INSERT INTO missions (name, bonus, created_at) VALUES ('m${random.nextInt(99)}', 'small', ${random.nextInt(1 << 30)})",
        );
        await source.customStatement(
          "INSERT INTO quests (name, difficulty, mission_id, sort_order, created_at) VALUES ('q${random.nextInt(99)}', 'easy', ?, $i, 1)",
          <Object?>[random.nextBool() ? mission : null],
        );
        await source.customStatement(
          "INSERT INTO time_entries (start_time, end_time, description, project) VALUES ('s$i', 'e$i', 'd${random.nextInt(99)}', ?)",
          <Object?>[random.nextBool() ? 'p${random.nextInt(9)}' : null],
        );
      }
      final String text = await exportDatabaseAsJson(
        source,
        appName: 'zafling',
        appVersion: '1',
        exportedAt: DateTime(2026),
        preferences: <String, Object?>{'k': random.nextInt(9)},
      );
      final Map<String, Object?> sourceTables = await _tables(source);
      await source.close();

      final AppDatabase target = createTestDatabase();
      final ExportFile file = ExportFile.parse(text);
      await DatabaseImporter(target, ImportHooks.none).import(file);
      expect(await _tables(target), sourceTables, reason: 'round $round');
      await target.close();
    }
  });
}
