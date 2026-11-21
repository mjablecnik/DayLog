import 'dart:io';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glados/glados.dart' hide expect, group, test, setUp, tearDown;
import 'package:zafling/core/event_type.dart';
import 'package:zafling/calendar/data/calendar_mappers.dart';
import 'package:zafling/calendar/data/calendar_models.dart';
import 'package:zafling/database/app_database.dart';

import '../../helpers/generators.dart';
import '../../helpers/test_database.dart';

Future<void> main() async {
  late Directory dir;
  late File file;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('calendar_storage_');
    file = File('${dir.path}/zafling.sqlite');
  });
  tearDown(() => dir.deleteSync(recursive: true));

  test('a new database holds the 35 built-in events, once, however often it is opened', () async {
    AppDatabase db = AppDatabase.forTesting(NativeDatabase(file));
    expect(await db.select(db.calendarEvents).get(), hasLength(35));
    await db.close();
    db = AppDatabase.forTesting(NativeDatabase(file));
    expect(await db.select(db.calendarEvents).get(), hasLength(35));
    await db.close();
  });

  test('a deleted holiday stays deleted on later starts', () async {
    AppDatabase db = AppDatabase.forTesting(NativeDatabase(file));
    final CalendarEventRow row = (await db.select(db.calendarEvents).get()).first;
    await (db.delete(db.calendarEvents)..where((t) => t.id.equals(row.id))).go();
    await db.close();
    db = AppDatabase.forTesting(NativeDatabase(file));
    expect(await db.select(db.calendarEvents).get(), hasLength(34));
    await db.close();
  });

  group('wall-clock storage', () {
    late AppDatabase db;
    setUp(() => db = createTestDatabase());
    tearDown(() => db.close());

    Future<CalendarEventRow> insertEvent(DateTime date, int startMinute, int endMinute) async {
      final int id = await db.into(db.calendarEvents).insert(
        eventCompanion(
          EventDraft(
            name: 'Probe',
            type: EventType.meeting,
            startDate: date,
            endDate: date,
            startMinute: startMinute,
            endMinute: endMinute,
            onBoard: false,
          ),
          createdAt: DateTime(2026, 1, 1),
          updatedAt: DateTime(2026, 1, 1),
        ),
      );
      return (db.select(db.calendarEvents)..where((t) => t.id.equals(id))).getSingle();
    }

    test('a time inside a daylight-saving gap is stored and read back unchanged', () async {
      // 29 March 2026, 02:30: does not exist in Europe/Prague, still a valid wall-clock time here.
      final CalendarEventRow row = await insertEvent(DateTime(2026, 3, 29), 150, 210);
      final List<QueryRow> raw = await db
          .customSelect('SELECT start_date, end_date, start_minute, end_minute FROM calendar_events WHERE id = ?', variables: [Variable.withInt(row.id)])
          .get();
      expect(raw.single.read<String>('start_date'), '2026-03-29');
      expect(raw.single.read<int>('start_minute'), 150);
      expect(raw.single.read<int>('end_minute'), 210);
      final CalendarEvent event = row.toModel();
      expect((event.startDate.year, event.startDate.month, event.startDate.day), (2026, 3, 29));
      expect((event.startMinute, event.endMinute), (150, 210));
    });

    // Feature: questlog-calendar, Property 14: Wall-clock times are zone-independent
    Glados2(anyCalendarDate, any.intInRange(0, 1380), ExploreConfig(numRuns: 40)).test(
      'Property 14: the stored text and minutes read back as the same wall-clock time',
      (DateTime date, int minute) async {
        final CalendarEventRow row = await insertEvent(date, minute, minute + 30);
        final List<QueryRow> raw = await db
            .customSelect('SELECT start_date FROM calendar_events WHERE id = ?', variables: [Variable.withInt(row.id)])
            .get();
        String two(int n) => n.toString().padLeft(2, '0');
        expect(raw.single.read<String>('start_date'), '${date.year}-${two(date.month)}-${two(date.day)}');
        final CalendarEvent event = row.toModel();
        expect(event.startDate, DateTime(date.year, date.month, date.day));
        expect((event.startMinute, event.endMinute), (minute, minute + 30));
      },
    );
  });
}
