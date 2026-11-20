import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers.dart';
import 'database_importer.dart';

/// The hooks of the importer. The app root overrides this with the real ones
/// (write the preferences, reschedule reminders, refresh state).
final importHooksProvider = Provider<ImportHooks>((ref) => ImportHooks.none);

/// The importer of the app database.
final databaseImporterProvider = Provider<DatabaseImporter>(
  (ref) => DatabaseImporter(ref.watch(databaseProvider), ref.watch(importHooksProvider)),
);

/// Counts the imports done in this run; the shell reacts to a change (it
/// checks the recurring rules again, for example).
final importCounterProvider = NotifierProvider<ImportCounter, int>(ImportCounter.new);

class ImportCounter extends Notifier<int> {
  @override
  int build() => 0;

  void increment() => state++;
}
