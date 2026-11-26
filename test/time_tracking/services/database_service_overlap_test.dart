import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';

import 'package:daylog/database/app_database.dart';
import 'package:daylog/time_tracking/services/database_service.dart';

import '../../helpers/test_database.dart';

TimeEntriesCompanion _entry(DateTime start, DateTime end, [String text = 'x']) =>
    TimeEntriesCompanion(
      startTime: Value(start.toIso8601String()),
      endTime: Value(end.toIso8601String()),
      description: Value(text),
      activityType: const Value('Práce'),
    );

const _session = TimeEntriesCompanion(
  description: Value('timer'),
  activityType: Value('Práce'),
);

DateTime _at(int hour, [int minute = 0]) => DateTime(2026, 11, 25, hour, minute);

Future<List<(DateTime, DateTime, String)>> _stored(DatabaseService service) async {
  final entries = await service.getEntriesForDay(_at(12));
  return [
    for (final e in entries.reversed)
      (DateTime.parse(e.startTime), DateTime.parse(e.endTime), e.description),
  ];
}

void main() {
  late AppDatabase db;
  late DatabaseService service;

  setUp(() {
    db = createTestDatabase();
    service = DatabaseService(db);
  });
  tearDown(() => db.close());

  group('a manual entry', () {
    test('that overlaps a stored entry is rejected and not stored', () async {
      final meetingId = await service.insertTimeEntry(_entry(_at(12, 58), _at(15)));
      await expectLater(
        service.insertTimeEntry(_entry(_at(12, 58), _at(17, 2))),
        throwsA(isA<OverlappingEntryException>()
            .having((e) => e.conflict.id, 'conflict id', meetingId)),
      );
      expect(await _stored(service), hasLength(1));
    });

    test('that lies inside a stored entry is rejected', () async {
      await service.insertTimeEntry(_entry(_at(12), _at(15)));
      await expectLater(
        service.insertTimeEntry(_entry(_at(13), _at(13))),
        throwsA(isA<OverlappingEntryException>()),
      );
    });

    test('that starts the day before and runs into the range is caught', () async {
      await service.insertTimeEntry(
        _entry(DateTime(2026, 11, 24, 23), DateTime(2026, 11, 25, 7)),
      );
      await expectLater(
        service.insertTimeEntry(_entry(DateTime(2026, 11, 25, 6, 30), _at(8))),
        throwsA(isA<OverlappingEntryException>()),
      );
    });

    test('that only touches its neighbours is stored', () async {
      await service.insertTimeEntry(_entry(_at(12), _at(13)));
      await service.insertTimeEntry(_entry(_at(14), _at(15)));
      await service.insertTimeEntry(_entry(_at(13), _at(14)));
      expect(await _stored(service), hasLength(3));
    });
  });

  group('an edit', () {
    test('that moves an entry over another one is rejected and not stored', () async {
      await service.insertTimeEntry(_entry(_at(12), _at(13)));
      final id = await service.insertTimeEntry(_entry(_at(14), _at(15)));
      await expectLater(
        service.updateDescription(id, 'x', startTime: _at(12, 30), endTime: _at(15)),
        throwsA(isA<OverlappingEntryException>()),
      );
      final moved = (await _stored(service)).last;
      expect(moved.$1, _at(14));
    });

    test('that keeps the entry within its own time is stored', () async {
      final id = await service.insertTimeEntry(_entry(_at(14), _at(15)));
      await service.updateDescription(id, 'y', startTime: _at(14, 10), endTime: _at(15));
      expect((await _stored(service)).single, (_at(14, 10), _at(15), 'y'));
    });
  });

  group('a timer session', () {
    test('with nothing in its way is stored whole', () async {
      expect(await service.insertTimerSession(_session, _at(12), _at(13)), 1);
      expect(await _stored(service), [(_at(12), _at(13), 'timer')]);
    });

    test('loses the time an entry at its start already covers', () async {
      await service.insertTimeEntry(_entry(_at(11), _at(12, 30)));
      expect(await service.insertTimerSession(_session, _at(12), _at(13)), 1);
      expect((await _stored(service)).last, (_at(12, 30), _at(13), 'timer'));
    });

    test('loses the time an entry at its end already covers', () async {
      await service.insertTimeEntry(_entry(_at(12, 40), _at(14)));
      await service.insertTimerSession(_session, _at(12), _at(13));
      expect((await _stored(service)).first, (_at(12), _at(12, 40), 'timer'));
    });

    test('is split around entries inside it', () async {
      await service.insertTimeEntry(_entry(_at(12, 58), _at(15), 'meeting'));
      await service.insertTimeEntry(_entry(_at(15), _at(16), 'travel'));
      await service.insertTimeEntry(_entry(_at(16, 30), _at(16, 42), 'video'));
      expect(await service.insertTimerSession(_session, _at(12), _at(17)), 3);
      expect(await _stored(service), [
        (_at(12), _at(12, 58), 'timer'),
        (_at(12, 58), _at(15), 'meeting'),
        (_at(15), _at(16), 'travel'),
        (_at(16), _at(16, 30), 'timer'),
        (_at(16, 30), _at(16, 42), 'video'),
        (_at(16, 42), _at(17), 'timer'),
      ]);
    });

    test('that is covered completely stores nothing', () async {
      await service.insertTimeEntry(_entry(_at(11), _at(14)));
      expect(await service.insertTimerSession(_session, _at(12), _at(13)), 0);
      expect(await _stored(service), hasLength(1));
    });
  });
}
