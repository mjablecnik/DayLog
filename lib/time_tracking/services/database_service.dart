import 'package:drift/drift.dart';

import '../domain/config.dart';
import '../../database/app_database.dart';

/// Thrown when an entry would end before it starts. No such entry is ever
/// stored: it would show a negative duration.
class InvalidTimeRangeException implements Exception {
  const InvalidTimeRangeException();

  @override
  String toString() => 'InvalidTimeRangeException: an entry cannot end before it starts';
}

/// Thrown when an entry would share time with an entry already stored. Two
/// entries never cover the same moment: the statistics would count it twice
/// and the timeline would hide one of them.
class OverlappingEntryException implements Exception {
  /// The stored entry the new time range collides with (the earliest one).
  final TimeEntry conflict;

  const OverlappingEntryException(this.conflict);

  @override
  String toString() =>
      'OverlappingEntryException: the time range overlaps entry ${conflict.id}';
}

class DatabaseService {
  final AppDatabase _db;

  /// How far before a range the overlap query looks for entries that started
  /// earlier and still run into it. No single entry is longer than this.
  static const _overlapLookBack = Duration(days: 2);

  DatabaseService(this._db);

  /// Whether `[aStart, aEnd)` and `[bStart, bEnd)` share any moment. Ranges
  /// that only touch (one ends when the other starts) do not overlap; an
  /// empty range overlaps a range it lies strictly inside.
  static bool rangesOverlap(
    DateTime aStart,
    DateTime aEnd,
    DateTime bStart,
    DateTime bEnd,
  ) {
    if (aStart == aEnd) return bStart.isBefore(aStart) && aStart.isBefore(bEnd);
    if (bStart == bEnd) return aStart.isBefore(bStart) && bStart.isBefore(aEnd);
    return aStart.isBefore(bEnd) && bStart.isBefore(aEnd);
  }

  /// The stored entries that share time with `[start, end)`, earliest first,
  /// leaving out the entry [excludeId] (the one being edited).
  Future<List<TimeEntry>> overlappingEntries(
    DateTime start,
    DateTime end, {
    int? excludeId,
  }) async {
    final candidates = await (_db.select(_db.timeEntries)
          ..where((t) => t.startTime.isBetweenValues(
                start.subtract(_overlapLookBack).toIso8601String(),
                end.toIso8601String(),
              ))
          ..orderBy([(t) => OrderingTerm(expression: t.startTime)]))
        .get();
    return candidates.where((entry) {
      if (entry.id == excludeId) return false;
      final entryStart = DateTime.tryParse(entry.startTime);
      final entryEnd = DateTime.tryParse(entry.endTime);
      if (entryStart == null || entryEnd == null) return false;
      return rangesOverlap(start, end, entryStart, entryEnd);
    }).toList();
  }

  Future<void> _ensureNoOverlap(
    DateTime start,
    DateTime end, {
    int? excludeId,
  }) async {
    final overlaps = await overlappingEntries(start, end, excludeId: excludeId);
    if (overlaps.isNotEmpty) throw OverlappingEntryException(overlaps.first);
  }

  /// Stores a timer session, keeping only the part of `[start, end)` that no
  /// stored entry covers yet: an entry added by hand while the timer ran
  /// shortens the session, or splits it in two when it lies inside it. Each
  /// stored piece gets the fields of [entry]. Returns how many pieces were
  /// stored; none when the whole session is already covered.
  Future<int> insertTimerSession(
    TimeEntriesCompanion entry,
    DateTime start,
    DateTime end,
  ) async {
    if (end.isBefore(start)) throw const InvalidTimeRangeException();
    return _db.transaction(() async {
      final occupied = await overlappingEntries(start, end);
      // A session nothing collides with is stored as it is, even when empty.
      final pieces = <(DateTime, DateTime)>[if (occupied.isEmpty) (start, end)];
      if (occupied.isNotEmpty) {
        var cursor = start;
        for (final other in occupied) {
          final otherStart = DateTime.parse(other.startTime);
          final otherEnd = DateTime.parse(other.endTime);
          if (otherStart.isAfter(cursor)) pieces.add((cursor, otherStart));
          if (otherEnd.isAfter(cursor)) cursor = otherEnd;
        }
        if (cursor.isBefore(end)) pieces.add((cursor, end));
      }

      for (final (pieceStart, pieceEnd) in pieces) {
        await _db.into(_db.timeEntries).insert(
              entry.copyWith(
                startTime: Value(pieceStart.toIso8601String()),
                endTime: Value(pieceEnd.toIso8601String()),
              ),
            );
      }
      return pieces.length;
    });
  }

  Future<void> initialize() async {
    await _db.customSelect('SELECT 1').get().timeout(
          const Duration(seconds: 3),
          onTimeout: () => throw TimeoutException('Database initialization timed out'),
        );
  }

  /// Stores [entry]. Throws [InvalidTimeRangeException] when it ends before
  /// it starts and [OverlappingEntryException] when it shares time with a
  /// stored entry; nothing is stored then.
  Future<int> insertTimeEntry(TimeEntriesCompanion entry) async {
    return _db.transaction(() async {
      if (entry.startTime.present && entry.endTime.present) {
        final start = DateTime.tryParse(entry.startTime.value);
        final end = DateTime.tryParse(entry.endTime.value);
        if (start != null && end != null) {
          if (end.isBefore(start)) throw const InvalidTimeRangeException();
          await _ensureNoOverlap(start, end);
        }
      }
      return await _db.into(_db.timeEntries).insert(entry);
    });
  }

  Future<List<TimeEntry>> getEntriesForDay(DateTime day) async {
    return await getEntriesForRange(_dayStart(day), _dayEnd(day));
  }

  Future<List<TimeEntry>> getEntriesForRange(DateTime start, DateTime end) async {
    return await (_db.select(_db.timeEntries)
          ..where((t) => t.startTime.isBetweenValues(start.toIso8601String(), end.toIso8601String()))
          ..orderBy([(t) => OrderingTerm(expression: t.startTime, mode: OrderingMode.desc)]))
        .get();
  }

  Future<void> updateDescription(
    int id,
    String description, {
    String? activityType,
    Value<String?> project = const Value.absent(),
    Value<String?> subtype = const Value.absent(),
    Value<String?> customName = const Value.absent(),
    DateTime? startTime,
    DateTime? endTime,
  }) async {
    if (startTime != null && endTime != null && endTime.isBefore(startTime)) {
      throw const InvalidTimeRangeException();
    }
    await _db.transaction(() async {
      if (startTime != null || endTime != null) {
        final stored = await (_db.select(_db.timeEntries)
              ..where((t) => t.id.equals(id)))
            .getSingleOrNull();
        if (stored != null) {
          await _ensureNoOverlap(
            startTime ?? DateTime.parse(stored.startTime),
            endTime ?? DateTime.parse(stored.endTime),
            excludeId: id,
          );
        }
      }
      await _write(
        id,
        description,
        activityType: activityType,
        project: project,
        subtype: subtype,
        customName: customName,
        startTime: startTime,
        endTime: endTime,
      );
    });
  }

  Future<void> _write(
    int id,
    String description, {
    String? activityType,
    required Value<String?> project,
    required Value<String?> subtype,
    required Value<String?> customName,
    DateTime? startTime,
    DateTime? endTime,
  }) async {
    await (_db.update(_db.timeEntries)..where((t) => t.id.equals(id))).write(
      TimeEntriesCompanion(
        description: Value(description),
        activityType: activityType == null
            ? const Value.absent()
            : Value(activityType),
        project: project,
        subtype: subtype,
        customName: customName,
        startTime: startTime == null
            ? const Value.absent()
            : Value(startTime.toIso8601String()),
        endTime: endTime == null
            ? const Value.absent()
            : Value(endTime.toIso8601String()),
      ),
    );
  }

  Future<void> deleteEntry(int id) async {
    await (_db.delete(_db.timeEntries)..where((t) => t.id.equals(id))).go();
  }

  Stream<List<TimeEntry>> watchEntriesForDay(DateTime day) {
    final start = _dayStart(day);
    final end = _dayEnd(day);
    return (_db.select(_db.timeEntries)
          ..where((t) => t.startTime.isBetweenValues(start.toIso8601String(), end.toIso8601String()))
          ..orderBy([(t) => OrderingTerm(expression: t.startTime, mode: OrderingMode.desc)]))
        .watch();
  }

  DateTime _dayStart(DateTime day) =>
      DateTime(day.year, day.month, day.day, dayStartHour);

  DateTime _dayEnd(DateTime day) =>
      DateTime(day.year, day.month, day.day + 1, dayStartHour)
          .subtract(const Duration(milliseconds: 1));
}

class TimeoutException implements Exception {
  final String message;
  const TimeoutException(this.message);
  @override
  String toString() => 'TimeoutException: $message';
}
