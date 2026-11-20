import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/note_node.dart';
import '../domain/note_tree.dart';
import '../../quests/services/providers.dart';
import 'notes_service.dart';

final notesServiceProvider = Provider<NotesService>(
  (ref) => NotesService(ref.watch(databaseProvider), ref.watch(clockProvider)),
);

/// All stored nodes; re-emits after every write.
final noteNodesProvider = StreamProvider<List<NoteNode>>(
  (ref) => ref.watch(notesServiceProvider).watchAll(),
);

/// The tree over [noteNodesProvider], loading until the first read.
final noteTreeProvider = Provider<AsyncValue<NoteTree>>(
  (ref) => ref.watch(noteNodesProvider).whenData(NoteTree.new),
);

/// Number of Trashed_Nodes, for the badge of the Trash button.
final trashCountProvider = Provider<int>(
  (ref) => ref.watch(noteTreeProvider).value?.trashEntries().length ?? 0,
);
