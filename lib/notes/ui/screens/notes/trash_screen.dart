import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../../domain/note_node.dart';
import '../../../domain/note_tree.dart';
import '../../../domain/trash_policy.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../services/notes_providers.dart';
import '../../../../quests/ui/state/quest_actions.dart' show showDomainError;
import '../../../../theme/app_theme.dart';
import '../../../../theme/tokens.dart';
import '../../../../ui_kit/common/app_icon.dart';
import '../../../../ui_kit/controls/app_buttons.dart';
import '../../../../ui_kit/layout/app_header.dart';
import '../../../../ui_kit/layout/grouped_list.dart';
import '../../../../ui_kit/common/empty_state.dart';
import '../../../../ui_kit/common/skeleton_list.dart';
import '../../../../ui_kit/common/snackbar_host.dart';
import '../../widgets/swipe_row.dart';
import '../../../../ui_kit/sheet/confirm_destructive.dart';
import 'trash_preview_screen.dart';
import 'trash_row.dart';
import '../../../../core/clock_provider.dart';

/// The Koš screen: every Trashed_Node with the days left until its Purge, with
/// Obnovit, Navždy and Vysypat koš.
class TrashScreen extends ConsumerStatefulWidget {
  const TrashScreen({super.key});

  @override
  ConsumerState<TrashScreen> createState() => _TrashScreenState();
}

class _TrashScreenState extends ConsumerState<TrashScreen> {
  @override
  void initState() {
    super.initState();
    // Opening the Trash asks for a Purge, so nothing expired is listed.
    ref.read(notesServiceProvider).purgeExpired().ignore();
  }

  Future<void> _restore(NoteNode node) async {
    final AppLocalizations l = AppLocalizations.of(context);
    try {
      await ref.read(notesServiceProvider).restore(node.id);
      if (mounted) showAppSnack(context, l.trash_restored);
    } catch (error) {
      if (mounted) showDomainError(context, error);
    }
  }

  Future<void> _open(NoteNode node) async {
    final AppLocalizations l = AppLocalizations.of(context);
    final bool? restored = await openTrashPreview(context, node.id);
    if (restored == true && mounted) showAppSnack(context, l.trash_restored);
  }

  Future<void> _deleteForever(NoteNode node) async {
    final AppLocalizations l = AppLocalizations.of(context);
    final bool confirmed = await confirmDestructive(
      context,
      title: l.trash_foreverTitle,
      body: l.trash_foreverBody(node.name),
      confirmLabel: l.trash_foreverConfirm,
    );
    if (!confirmed || !mounted) return;
    try {
      await ref.read(notesServiceProvider).deleteForever(node.id);
      if (mounted) showAppSnack(context, l.trash_deleted);
    } catch (error) {
      if (mounted) showDomainError(context, error);
    }
  }

  Future<void> _empty(int count) async {
    final AppLocalizations l = AppLocalizations.of(context);
    final bool confirmed = await confirmDestructive(
      context,
      title: l.trash_emptyTitle,
      body: l.trash_emptyBody(count),
      confirmLabel: l.trash_emptyAction,
    );
    if (!confirmed || !mounted) return;
    try {
      await ref.read(notesServiceProvider).emptyTrash();
      if (mounted) showAppSnack(context, l.trash_emptied);
    } catch (error) {
      if (mounted) showDomainError(context, error);
    }
  }

  String _detail(AppLocalizations l, NoteTree tree, NoteNode node, DateTime now) {
    final NoteNode? parent = node.parentId == null ? null : tree.byId(node.parentId!);
    final String from = parent?.name ?? l.notes_title;
    final String when = l.trash_daysLeft(daysUntilPurge(node.deletedAt!, now));
    return node.isFolder
        ? l.trash_folderLine(l.notes_noteCount(tree.containedNotesCount(node.id)), from, when)
        : l.trash_noteLine(from, when);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l = AppLocalizations.of(context);
    final AppPalette p = context.palette;
    final NoteTree? tree = ref.watch(noteTreeProvider).value;
    final DateTime now = ref.watch(clockProvider).now();
    final List<NoteNode> entries = tree?.trashEntries() ?? const <NoteNode>[];

    final Widget body;
    if (tree == null) {
      body = const SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        child: SkeletonList(count: 3, padding: EdgeInsets.symmetric(horizontal: Space.s20)),
      );
    } else if (entries.isEmpty) {
      body = EmptyState(title: l.trash_emptyStateTitle, body: l.trash_emptyStateBody);
    } else {
      body = SlidableAutoCloseBehavior(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(Space.s20, 0, Space.s20, Space.s16),
          children: <Widget>[
            _Info(text: l.trash_info),
            const SizedBox(height: Space.s16),
            Text(
              l.trash_section.toUpperCase(),
              style: context.bodyText.labelSmall!.copyWith(color: p.textFaint),
            ),
            const SizedBox(height: Space.s10),
            GroupedList(children: [
            for (final NoteNode node in entries)
              KeyedSubtree(
                key: ValueKey<int>(node.id),
                child: SwipeRow(
                  groupTag: 'trash',
                  actions: <SwipeActionSpec>[
                    SwipeActionSpec(
                      label: l.trash_restore,
                      semanticLabel: l.a11y_restoreNode(node.name),
                      icon: IconAsset.undo,
                      background: p.brassSoft,
                      foreground: p.brassText,
                      onPressed: () => _restore(node),
                      actionKey: const ValueKey<String>('trash-swipe-restore'),
                    ),
                    SwipeActionSpec(
                      label: l.trash_forever,
                      semanticLabel: l.a11y_foreverNode(node.name),
                      icon: IconAsset.trash,
                      background: p.destructive,
                      foreground: p.inkOnDestructive,
                      onPressed: () => _deleteForever(node),
                      actionKey: const ValueKey<String>('trash-swipe-forever'),
                    ),
                  ],
                  child: TrashRow(
                    name: node.name,
                    isFolder: node.isFolder,
                    detail: _detail(l, tree, node, now),
                    urgent: daysUntilPurge(node.deletedAt!, now) <= 1,
                    onRestore: () => _restore(node),
                    onTap: node.isFolder ? null : () => _open(node),
                  ),
                ),
              ),
            ]),
          ],
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AppHeader(
              leading: HeaderLeading.back,
      leadingKey: const ValueKey<String>('trash-back'),
              title: l.trash_title,
              subtitle: tree == null ? null : l.trash_count(entries.length),
            ),
            const SizedBox(height: Space.s12),
            Expanded(child: body),
            if (entries.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(Space.s20, Space.s4, Space.s20, Space.s16),
                child: AppButton.destructive(
                  key: const ValueKey<String>('trash-empty'),
                  onPressed: () => _empty(entries.length),
                  label: l.trash_emptyAction,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Info extends StatelessWidget {
  const _Info({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final AppPalette p = context.palette;
    return DecoratedBox(
      decoration: BoxDecoration(color: p.tone, borderRadius: BorderRadius.circular(Radii.button)),
      child: Padding(
        padding: const EdgeInsets.all(Space.s12),
        child: Text(text, style: context.bodyText.bodySmall!.copyWith(color: p.textDim)),
      ),
    );
  }
}
