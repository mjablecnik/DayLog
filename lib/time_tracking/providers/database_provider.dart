import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../database/providers.dart';
import '../services/database_service.dart';
import '../services/project_service.dart';

final databaseServiceProvider = FutureProvider<DatabaseService>((ref) async {
  final db = ref.watch(databaseProvider);
  final service = DatabaseService(db);
  await service.initialize();
  return service;
});

final projectServiceProvider = Provider<ProjectService>((ref) {
  return ProjectService();
});
