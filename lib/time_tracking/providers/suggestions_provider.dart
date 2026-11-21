import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../database/providers.dart';
import '../data/time_tracking_queries.dart';
import '../domain/activity_types.dart';
import 'database_provider.dart';

/// The names suggested for one category: the names the user saved there, most
/// recently used first. The first read fills the lists from the existing entries.
final suggestionsProvider = FutureProvider.autoDispose
    .family<List<String>, SuggestionScope>((ref, scope) async {
      final projectService = ref.watch(projectServiceProvider);
      final db = ref.watch(databaseProvider);

      await projectService.seedFromEntries(await db.getEntriesWithNames());
      return projectService.getKnownNames(scope);
    });
