import 'package:drift/drift.dart';

import '../../database/app_database.dart';

/// The queries of the time tracking tables. They are extension methods, so the
/// shared [AppDatabase] does not carry them and the feature keeps its own
/// queries in its own folder.
extension TimeTrackingQueries on AppDatabase {
  // --- RecurringReminders CRUD ---

  Future<List<RecurringReminder>> getAllReminders() {
    return (select(recurringReminders)
          ..orderBy([(t) => OrderingTerm.asc(t.startTime)]))
        .get();
  }

  Stream<List<RecurringReminder>> watchAllReminders() {
    return (select(recurringReminders)
          ..orderBy([(t) => OrderingTerm.asc(t.startTime)]))
        .watch();
  }

  Future<int> insertReminder(RecurringRemindersCompanion entry) {
    return into(recurringReminders).insert(entry);
  }

  Future<bool> updateReminder(RecurringRemindersCompanion entry) {
    return update(recurringReminders).replace(entry);
  }

  Future<int> deleteReminder(int id) {
    return (delete(recurringReminders)..where((t) => t.id.equals(id))).go();
  }

  Future<RecurringReminder?> getReminderById(int id) {
    return (select(recurringReminders)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  // --- CompletionRecords ---

  Future<int> insertCompletionRecord(CompletionRecordsCompanion entry) {
    return into(completionRecords).insert(entry);
  }

  Future<bool> hasCompletionForToday(int reminderId, String todayDate) async {
    final record = await (select(completionRecords)
          ..where((t) =>
              t.reminderId.equals(reminderId) &
              t.completionDate.equals(todayDate)))
        .getSingleOrNull();
    return record != null;
  }

  Future<int> deleteCompletionForToday(int reminderId, String todayDate) {
    return (delete(completionRecords)
          ..where((t) =>
              t.reminderId.equals(reminderId) &
              t.completionDate.equals(todayDate)))
        .go();
  }

  /// Time entries that carry a project or a custom name; used once to fill the
  /// scoped suggestion lists.
  Future<List<TimeEntry>> getEntriesWithNames() {
    return (select(timeEntries)
          ..where((t) => t.project.isNotNull() | t.customName.isNotNull()))
        .get();
  }
}
