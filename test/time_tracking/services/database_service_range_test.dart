import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';

import 'package:daylog/database/app_database.dart';
import 'package:daylog/time_tracking/services/database_service.dart';

import '../../helpers/test_database.dart';

TimeEntriesCompanion _entry(DateTime start, DateTime end) => TimeEntriesCompanion(
      startTime: Value(start.toIso8601String()),
      endTime: Value(end.toIso8601String()),
      description: const Value('x'),
      activityType: const Value('Práce'),
    );

void main() {
  late AppDatabase db;
  late DatabaseService service;
  final start = DateTime(2026, 11, 22, 15, 7);

  setUp(() {
    db = createTestDatabase();
    service = DatabaseService(db);
  });
  tearDown(() => db.close());

  test('an entry that ends before it starts is rejected and not stored', () async {
    await expectLater(
      service.insertTimeEntry(_entry(start, start.subtract(const Duration(minutes: 14)))),
      throwsA(isA<InvalidTimeRangeException>()),
    );
    expect(await service.getEntriesForDay(start), isEmpty);
  });

  test('an entry of zero or positive length is stored', () async {
    await service.insertTimeEntry(_entry(start, start));
    await service.insertTimeEntry(_entry(start, start.add(const Duration(minutes: 5))));
    expect(await service.getEntriesForDay(start), hasLength(2));
  });

  test('an edit that moves the end before the start is rejected', () async {
    final id = await service.insertTimeEntry(_entry(start, start.add(const Duration(minutes: 5))));
    await expectLater(
      service.updateDescription(
        id,
        'x',
        startTime: start,
        endTime: start.subtract(const Duration(minutes: 1)),
      ),
      throwsA(isA<InvalidTimeRangeException>()),
    );
    final stored = (await service.getEntriesForDay(start)).single;
    expect(DateTime.parse(stored.endTime).isAfter(DateTime.parse(stored.startTime)), isTrue);
  });
}
