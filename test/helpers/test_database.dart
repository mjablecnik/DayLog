import 'package:drift/native.dart';
import 'package:zafling/database/app_database.dart';

/// A fresh [AppDatabase] over an in-memory SQLite database.
///
/// Close it with `await db.close()` in `tearDown`.
AppDatabase createTestDatabase() {
  return AppDatabase.forTesting(NativeDatabase.memory());
}
