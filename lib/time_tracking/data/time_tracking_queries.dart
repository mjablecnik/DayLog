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

  Future<List<CompletionRecord>> getCompletionsByReminder(int reminderId) {
    return (select(completionRecords)
          ..where((t) => t.reminderId.equals(reminderId))
          ..orderBy([(t) => OrderingTerm.asc(t.completionDate)]))
        .get();
  }

  Future<List<CompletionRecord>> getCompletionsByDateRange(
    int reminderId,
    String startDate,
    String endDate,
  ) {
    return (select(completionRecords)
          ..where((t) =>
              t.reminderId.equals(reminderId) &
              t.completionDate.isBiggerOrEqualValue(startDate) &
              t.completionDate.isSmallerOrEqualValue(endDate))
          ..orderBy([(t) => OrderingTerm.asc(t.completionDate)]))
        .get();
  }

  // --- TaskProjects CRUD ---

  Future<List<TaskProject>> getAllTaskProjects() {
    return (select(taskProjects)
          ..orderBy([
            (t) => OrderingTerm(expression: t.name.collate(Collate.noCase)),
          ]))
        .get();
  }

  Stream<List<TaskProject>> watchAllTaskProjects() {
    return (select(taskProjects)
          ..orderBy([
            (t) => OrderingTerm(expression: t.name.collate(Collate.noCase)),
          ]))
        .watch();
  }

  Future<int> insertTaskProject(TaskProjectsCompanion entry) {
    return into(taskProjects).insert(entry);
  }

  Future<int> deleteTaskProject(int id) {
    return (delete(taskProjects)..where((t) => t.id.equals(id))).go();
  }

  Future<List<TaskProject>> getTaskProjectsAlphabetical() {
    return (select(taskProjects)
          ..orderBy([
            (t) => OrderingTerm(expression: t.name.collate(Collate.noCase)),
          ]))
        .get();
  }

  /// Changes the category of a task project; nothing else is touched.
  Future<void> updateTaskProjectScope(int id, String scope) {
    return (update(taskProjects)..where((t) => t.id.equals(id)))
        .write(TaskProjectsCompanion(scope: Value(scope)));
  }

  /// Time entries that carry a project or a custom name; used once to fill the
  /// scoped suggestion lists.
  Future<List<TimeEntry>> getEntriesWithNames() {
    return (select(timeEntries)
          ..where((t) => t.project.isNotNull() | t.customName.isNotNull()))
        .get();
  }

  // --- Tasks CRUD ---

  Future<List<TaskItem>> getTasksForProject(
    int? projectId, {
    bool includeArchived = false,
  }) {
    final query = select(tasks)
      ..where((t) => projectId == null
          ? t.projectId.isNull()
          : t.projectId.equals(projectId))
      ..orderBy([(t) => OrderingTerm.asc(t.sortPosition)]);
    if (!includeArchived) {
      query.where((t) => t.isArchived.equals(false));
    }
    return query.get();
  }

  Stream<List<TaskItem>> watchTasksForProject(
    int? projectId, {
    bool includeArchived = false,
  }) {
    final query = select(tasks)
      ..where((t) => projectId == null
          ? t.projectId.isNull()
          : t.projectId.equals(projectId))
      ..orderBy([(t) => OrderingTerm.asc(t.sortPosition)]);
    if (!includeArchived) {
      query.where((t) => t.isArchived.equals(false));
    }
    return query.watch();
  }

  Future<int> insertTask(TasksCompanion entry) {
    return into(tasks).insert(entry);
  }

  Future<bool> updateTaskFields(int id, TasksCompanion entry) async {
    final rows = await (update(tasks)..where((t) => t.id.equals(id)))
        .write(entry);
    return rows > 0;
  }

  Future<int> deleteTask(int id) {
    return (delete(tasks)..where((t) => t.id.equals(id))).go();
  }

  Future<void> updateTaskSortPositions(List<TaskItem> orderedTasks) async {
    await batch((b) {
      for (var i = 0; i < orderedTasks.length; i++) {
        b.update(
          tasks,
          TasksCompanion(sortPosition: Value(i)),
          where: (t) => t.id.equals(orderedTasks[i].id),
        );
      }
    });
  }

  Future<bool> markTaskCompleted(int id, DateTime completedAt) async {
    final rows = await (update(tasks)..where((t) => t.id.equals(id))).write(
      TasksCompanion(
        isCompleted: const Value(true),
        completedAt: Value(completedAt),
      ),
    );
    return rows > 0;
  }

  Future<bool> unmarkTaskCompleted(int id) async {
    final rows = await (update(tasks)..where((t) => t.id.equals(id))).write(
      const TasksCompanion(
        isCompleted: Value(false),
        completedAt: Value(null),
      ),
    );
    return rows > 0;
  }

  Future<bool> archiveTask(int id) async {
    final rows = await (update(tasks)..where((t) => t.id.equals(id))).write(
      const TasksCompanion(isArchived: Value(true)),
    );
    return rows > 0;
  }

  Future<bool> unarchiveTask(int id, int newSortPosition) async {
    final rows = await (update(tasks)..where((t) => t.id.equals(id))).write(
      TasksCompanion(
        isCompleted: const Value(false),
        completedAt: const Value(null),
        isArchived: const Value(false),
        sortPosition: Value(newSortPosition),
      ),
    );
    return rows > 0;
  }

  Future<List<TaskItem>> getExpiredCompletedTasks() async {
    final cutoff = DateTime.now().subtract(const Duration(hours: 12));
    return (select(tasks)
          ..where((t) =>
              t.isCompleted.equals(true) &
              t.isArchived.equals(false) &
              t.completedAt.isSmallerOrEqualValue(cutoff)))
        .get();
  }
}
