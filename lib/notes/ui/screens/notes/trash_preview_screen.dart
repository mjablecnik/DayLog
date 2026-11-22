import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:super_editor/super_editor.dart';

import '../../../domain/note_node.dart';
import '../../../domain/note_tree.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../services/notes_providers.dart';
import '../../../../quests/ui/state/quest_actions.dart' show showDomainError;
import '../../../../theme/app_theme.dart';
import '../../../../theme/tokens.dart';
import '../../../../ui_kit/controls/app_buttons.dart';
import '../../../../ui_kit/layout/app_header.dart';
import '../../../../ui_kit/sheet/confirm_destructive.dart';
import '../note_editor/editor_style.dart';
import '../note_editor/note_markdown.dart';
import '../note_editor/note_task_component.dart';

/// Opens the read-only preview of the trashed Note [noteId]. Completes with
/// true when the Note was restored from the preview.
Future<bool?> openTrashPreview(BuildContext context, int noteId) {
  return Navigator.of(context).push<bool>(
    CupertinoPageRoute<bool>(
      builder: (_) => TrashPreviewScreen(noteId: noteId),
    ),
  );
}

/// A trashed Note to read before it is restored or lost: its name, its text
/// formatted as in the Note_Editor but not editable (no caret, no keyboard, no
/// toolbar, a check cannot be toggled) and the Obnovit pill. Opening it changes
/// nothing about the Note. The preview closes when the Note stops being a
/// Trashed_Node, for example because it was purged.
class TrashPreviewScreen extends ConsumerStatefulWidget {
  const TrashPreviewScreen({super.key, required this.noteId});

  final int noteId;

  @override
  ConsumerState<TrashPreviewScreen> createState() => _TrashPreviewScreenState();
}

class _TrashPreviewScreenState extends ConsumerState<TrashPreviewScreen> {
  MutableDocumentComposer? _composer;
  Editor? _editor;
  bool _empty = true;
  bool _closing = false;

  /// Builds the document from the stored text once; the preview never edits it.
  void _ensureDocument(String body) {
    if (_editor != null) return;
    final MutableDocument document = documentFromMarkdown(body);
    _empty = body.trim().isEmpty;
    _composer = MutableDocumentComposer();
    _editor = createDefaultDocumentEditor(
      document: document,
      composer: _composer!,
    );
  }

  @override
  void dispose() {
    _composer?.dispose();
    _editor?.dispose();
    super.dispose();
  }

  Future<void> _restore(NoteNode node) async {
    _closing = true;
    try {
      await ref.read(notesServiceProvider).restore(node.id);
      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      _closing = false;
      if (mounted) showDomainError(context, error);
    }
  }

  Future<void> _delete(NoteNode node) async {
    final strings = AppLocalizations.of(context);
    final confirmed = await confirmDestructive(
      context,
      title: strings.trash_foreverTitle,
      body: strings.trash_foreverBody(node.name),
      confirmLabel: strings.trash_foreverConfirm,
    );
    if (!confirmed || !mounted) return;
    _closing = true;
    try {
      await ref.read(notesServiceProvider).deleteForever(node.id);
      if (mounted) Navigator.of(context).pop(false);
    } catch (error) {
      _closing = false;
      if (mounted) showDomainError(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppPalette p = context.palette;
    final AppLocalizations l = AppLocalizations.of(context);
    final NoteTree? tree = ref.watch(noteTreeProvider).value;
    final NoteNode? node = tree?.byId(widget.noteId);
    if (tree != null && (node == null || node.deletedAt == null) && !_closing) {
      // Purged, or restored elsewhere: nothing is left to preview.
      _closing = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.of(context).maybePop();
      });
    }
    if (node != null) _ensureDocument(node.body);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AppHeader(
              leading: HeaderLeading.back,
              leadingKey: const ValueKey<String>('preview-back'),
              title: node?.name ?? l.trash_title,
            ),
            if (node != null) ...[
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Space.s20),
                  child: _empty
                      ? Align(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(top: Space.s12),
                            child: Text(
                              l.trash_previewEmpty,
                              style: context.bodyText.bodyLarge!.copyWith(
                                color: p.textFaint,
                              ),
                            ),
                          ),
                        )
                      : SuperReader(
                          key: const ValueKey<String>('trash-preview-text'),
                          editor: _editor!,
                          stylesheet: buildEditorStylesheet(context),
                          selectionStyle: buildSelectionStyles(p),
                          componentBuilders: <ComponentBuilder>[
                            NoteTaskComponentBuilder.readOnly(
                              toggleLabel: l.a11y_taskToggle,
                            ),
                            ...readOnlyDefaultComponentBuilders,
                          ],
                        ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(Space.s16),
                child: Column(
                  children: [
                    AppButton.primary(
                      key: const ValueKey<String>('preview-restore'),
                      label: l.trash_restore,
                      onPressed: () => _restore(node),
                    ),
                    const SizedBox(height: Space.s8),
                    AppButton.destructive(
                      label: l.trash_forever,
                      onPressed: () => _delete(node),
                    ),
                  ],
                ),
              ),
            ] else
              const Spacer(),
          ],
        ),
      ),
    );
  }
}
