import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_database.dart';

/// The app database. Tests override it with an in-memory database.
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});
