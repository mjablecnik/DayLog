import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../../domain/note_node.dart';
import '../../../domain/note_title.dart';
import '../../../domain/note_tree.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../services/notes_providers.dart';
import '../../sheets/add_sheet.dart';
import '../../sheets/name_sheet.dart';
import '../../state/notes_state.dart';
import '../../../../quests/ui/state/quest_actions.dart' show showDomainError;
import '../../../../theme/app_theme.dart';
import '../../../../theme/tokens.dart';
import '../../../../ui_kit/common/add_fab.dart';
import '../../../../ui_kit/layout/app_header.dart';
import '../../../../ui_kit/layout/grouped_list.dart';
import '../../../../ui_kit/layout/section_headers.dart';
import 'folder_row.dart';
import 'note_row.dart';
import '../../../../ui_kit/common/empty_state.dart';
import '../../../../ui_kit/common/skeleton_list.dart';
import '../../widgets/trash_button.dart';
import '../note_editor/note_editor_screen.dart';
import 'breadcrumb.dart';
import 'node_menu.dart';
import 'node_swipe_row.dart';
import 'notes_actions.dart';
import 'notes_labels.dart';
import 'trash_screen.dart';
import '../../../../core/clock_provider.dart';

/// The Poznámky tab: the Folders and Notes of the Current_Folder, with the add
/// button, the Breadcrumb inside a Folder and the Trash button at the top level.
class NotesScreen extends ConsumerWidget {
  const NotesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l = AppLocalizations.of(context);
    final AsyncValue<NoteTree> treeAsync = ref.watch(noteTreeProvider);
    final NoteTree? tree = treeAsync.value;
    final int? folderId = ref.watch(visibleFolderProvider);
    final NoteNode? folder = folderId == null ? null : tree?.byId(folderId);
    final void Function(int?) open = ref.read(currentFolderProvider.notifier).open;

    final Widget body;
    if (treeAsync.hasError) {
      body = _LoadError(onRetry: () => ref.invalidate(noteNodesProvider));
    } else if (tree == null) {
      body = const SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        child: SkeletonList(count: 4, padding: EdgeInsets.symmetric(horizontal: Space.s20)),
      );
    } else if (tree.children(folderId).isEmpty) {
      body = EmptyState(title: l.notes_emptyTitle, body: l.notes_emptyBody);
    } else {
      body = _NodeList(tree: tree, folderId: folderId);
    }

    // All tabs stay mounted: only the visible one (tickers on) takes the back action.
    return PopScope(
      canPop: folderId == null || !TickerMode.valuesOf(context).enabled,
      onPopInvokedWithResult: (bool didPop, Object? _) {
        if (!didPop) open(folder?.parentId);
      },
      child: Scaffold(
        body: SafeArea(
          bottom: false,
          child: Stack(
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  if (folder != null && tree != null)
                    _FolderBar(tree: tree, folder: folder)
                  else
                    _TitleRow(tree: tree),
                  const SizedBox(height: Space.s10),
                  Expanded(child: body),
                ],
              ),
              Positioned(
                right: Space.s20,
                bottom: Space.s20,
                child: AddFab(
                  label: l.notes_addTitle,
                  onPressed: () => _add(context, ref, tree, folderId),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _add(BuildContext context, WidgetRef ref, NoteTree? tree, int? folderId) async {
    final AppLocalizations l = AppLocalizations.of(context);
    final String place = folderId == null
        ? l.notes_title
        : tree?.byId(folderId)?.name ?? l.notes_title;
    final NewNodeKind? kind = await showAddSheet(context, placeName: place);
    if (kind == null || !context.mounted) return;
    switch (kind) {
      case NewNodeKind.note:
        openNoteEditor(context, parentId: folderId);
      case NewNodeKind.folder:
        final String? name = await showNameSheet(
          context,
          title: l.notes_addFolder,
          primaryLabel: l.notes_createFolder,
        );
        if (name == null || !context.mounted) return;
        try {
          await ref.read(notesServiceProvider).createFolder(parentId: folderId, name: name);
        } catch (error) {
          if (context.mounted) showDomainError(context, error);
        }
    }
  }
}

/// Back button (labelled with the parent) and the Node_Menu of the Current_Folder.
class _FolderBar extends ConsumerWidget {
  const _FolderBar({required this.tree, required this.folder});

  final NoteTree tree;
  final NoteNode folder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final open = ref.read(currentFolderProvider.notifier).open;
    return AppHeader(
      title: folder.name,
      leading: HeaderLeading.back,
      leadingKey: const ValueKey<String>('notes-back'),
      onLeading: () => open(folder.parentId),
      subtitleWidget: Breadcrumb(path: tree.breadcrumb(folder.id)),
      trailing: [
        NodeMenuButton(
          enabled: true,
          onSelected: (action) async {
            switch (action) {
              case NodeMenuAction.rename:
                await renameNode(context, ref, folder);
              case NodeMenuAction.move:
                await moveNode(context, ref, folder);
              case NodeMenuAction.trash:
                if (await trashNode(context, ref, folder)) open(folder.parentId);
            }
          },
        ),
      ],
    );
  }
}

class _TitleRow extends ConsumerWidget {
  const _TitleRow({required this.tree});

  final NoteTree? tree;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    return AppHeader(
      title: strings.notes_title,
      subtitle: tree == null
          ? null
          : countsLabel(strings, tree!.folderCount(null), tree!.noteCount(null)),
      trailing: [
        TrashButton(
            count: ref.watch(trashCountProvider),
            onPressed: () => Navigator.of(context).push(
              CupertinoPageRoute<void>(builder: (_) => const TrashScreen()),
            ),
          ),
      ],
    );
  }
}

class _NodeList extends ConsumerWidget {
  const _NodeList({required this.tree, required this.folderId});

  final NoteTree tree;
  final int? folderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l = AppLocalizations.of(context);
    final DateTime now = ref.watch(clockProvider).now();
    final List<NoteNode> children = tree.children(folderId);
    final List<NoteNode> folders = children.where((n) => n.isFolder).toList();
    final List<NoteNode> notes = children.where((n) => !n.isFolder).toList();
    final void Function(int?) open = ref.read(currentFolderProvider.notifier).open;

    Widget swipe(NoteNode node, Widget child) => NodeSwipeRow(
      name: node.name,
      onRename: () => renameNode(context, ref, node),
      onMove: () => moveNode(context, ref, node),
      onDelete: () => trashNode(context, ref, node),
      child: child,
    );

    return SlidableAutoCloseBehavior(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(Space.s16, 0, Space.s16, Metrics.fab + Space.s48),
        children: [
          if (folders.isNotEmpty) ...[
            SectionLabel(l.notes_sectionFolders),
            const SizedBox(height: Space.s8),
            GroupedList(
              children: [
                for (final folder in folders)
                  KeyedSubtree(
                    key: ValueKey(folder.id),
                    child: swipe(
                      folder,
                      FolderRow(
                        name: folder.name,
                        summary: folderSummary(l, tree, folder.id),
                        onTap: () => open(folder.id),
                      ),
                    ),
                  ),
              ],
            ),
          ],
          if (notes.isNotEmpty) ...[
            if (folders.isNotEmpty) const SizedBox(height: Space.s16),
            SectionLabel(folderId == null ? l.notes_sectionNotes : '${l.notes_sectionNotes} · ${notes.length}'),
            const SizedBox(height: Space.s8),
            GroupedList(
              children: [
                for (final note in notes)
                  KeyedSubtree(
                    key: ValueKey(note.id),
                    child: swipe(
                      note,
                      NoteRow(
                        name: note.name,
                        preview: notePreview(note.body, skipFirstLine: note.autoName),
                        date: noteDateLabel(l, note.updatedAt, now),
                        onTap: () => openNoteEditor(context, noteId: note.id, parentId: note.parentId),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(l.notes_errorGeneric, style: context.bodyText.bodyLarge),
          const SizedBox(height: Space.s12),
          TextButton(onPressed: onRetry, child: Text(l.common_retry)),
        ],
      ),
    );
  }
}
