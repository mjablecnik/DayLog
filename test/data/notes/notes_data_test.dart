
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:zafling/notes/domain/note_node.dart';
import 'package:zafling/database/app_database.dart';
import 'package:zafling/notes/data/notes_mappers.dart';

import '../../helpers/test_database.dart';


final DateTime _now = DateTime(2026, 11, 19, 12);

Future<int> insertNode(
  AppDatabase db, {
  int? parent,
  bool folder = false,
  String name = 'n',
  String body = '',
}) => db.into(db.noteNodes).insert(
  NoteNodesCompanion.insert(
    parentId: Value<int?>(parent),
    isFolder: folder,
    name: name,
    body: Value<String>(body),
    createdAt: _now,
    updatedAt: _now,
  ),
);

Future<void> main() async {
  group('notes table', () {
    late AppDatabase db;
    setUp(() => db = createTestDatabase());
    tearDown(() => db.close());

    test('a fresh database has an empty notes table', () async {
      expect(await db.select(db.noteNodes).get(), isEmpty);
    });

    test('a node round-trips through the mapper, a folder body is always empty', () async {
      final int folder = await insertNode(db, folder: true, name: 'ABAP', body: 'ignored');
      final int note = await insertNode(db, parent: folder, name: 'Syntaxe', body: '# Hello');
      final List<NoteNodeRow> rows = await db.select(db.noteNodes).get();
      final NoteNode f = rows.firstWhere((r) => r.id == folder).toNode();
      final NoteNode n = rows.firstWhere((r) => r.id == note).toNode();
      expect(f.isFolder, isTrue);
      expect(f.body, '');
      expect(n.parentId, folder);
      expect(n.body, '# Hello');
      expect(n.deletedAt, isNull);
      expect(n.autoName, isFalse);
      expect(noteNodeToInsert(n).name.value, 'Syntaxe');
    });

    test('deleting a folder row deletes everything inside it, several levels deep', () async {
      final int a = await insertNode(db, folder: true);
      final int b = await insertNode(db, parent: a, folder: true);
      final int c = await insertNode(db, parent: b);
      final int other = await insertNode(db);
      await (db.delete(db.noteNodes)..where((t) => t.id.equals(a))).go();
      final List<int> left = (await db.select(db.noteNodes).get()).map((r) => r.id).toList();
      expect(left, <int>[other]);
      expect(left, isNot(contains(c)));
    });

    test('a name of 0 or 81 characters and a body over 100 000 characters are rejected', () async {
      expect(insertNode(db, name: '   '), throwsA(anything));
      expect(insertNode(db, name: 'x' * 81), throwsA(anything));
      expect(insertNode(db, body: 'x' * 100001), throwsA(anything));
      expect(await insertNode(db, name: 'x' * 80, body: 'x' * 100000), isPositive);
    });

    test('a parent that does not exist is rejected', () async {
      expect(insertNode(db, parent: 999), throwsA(anything));
    });
  });
}
