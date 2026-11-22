import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/tokens.dart';
import '../../../ui_kit/common/app_icon.dart';
import '../../../ui_kit/layout/grouped_list.dart';
import '../../../ui_kit/sheet/app_sheet.dart';

/// What the Add_Sheet creates.
enum NewNodeKind { note, folder }

/// Opens the Add_Sheet: Nová poznámka or Nová složka, with a line naming
/// [placeName], the place where the new Node will be created.
Future<NewNodeKind?> showAddSheet(BuildContext context, {required String placeName}) {
  return showAppSheet<NewNodeKind>(
    context,
    builder: (BuildContext context) => _AddSheet(placeName: placeName),
  );
}

class _AddSheet extends StatelessWidget {
  const _AddSheet({required this.placeName});

  final String placeName;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l = AppLocalizations.of(context);
    final AppPalette p = context.palette;
    return AppSheet(
      title: l.notes_addTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          GroupedList(
            children: <Widget>[
              ListRow(
                key: const ValueKey<String>('add-note'),
                leading: const IconTile(IconAsset.notePlus),
                title: l.notes_addNote,
                subtitle: l.notes_addNoteHint,
                onTap: () => AppSheet.close<NewNodeKind>(context, NewNodeKind.note),
              ),
              ListRow(
                key: const ValueKey<String>('add-folder'),
                leading: const IconTile(IconAsset.folderPlus),
                title: l.notes_addFolder,
                subtitle: l.notes_addFolderHint,
                onTap: () => AppSheet.close<NewNodeKind>(context, NewNodeKind.folder),
              ),
            ],
          ),
          const SizedBox(height: Space.s16),
          Text(
            l.notes_addWhere(placeName),
            textAlign: TextAlign.center,
            style: context.bodyText.bodySmall!.copyWith(color: p.textFaint),
          ),
        ],
      ),
    );
  }
}
