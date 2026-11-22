import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../theme/app_theme.dart';
import '../../../../ui_kit/common/app_icon.dart';
import '../../../../ui_kit/layout/grouped_list.dart';
import '../../../../ui_kit/controls/app_buttons.dart';

/// One Trashed_Node: its kind icon, name, where it came from and when it is
/// purged, and the Obnovit pill. The second line is destructive-coloured when
/// the Purge is one day away or less.
class TrashRow extends StatelessWidget {
  const TrashRow({
    super.key,
    required this.name,
    required this.isFolder,
    required this.detail,
    required this.urgent,
    required this.onRestore,
    this.onTap,
  });

  final String name;
  final bool isFolder;

  /// Already localized, for example "z Poznámky · smaže se za 9 dní".
  final String detail;
  final bool urgent;
  final VoidCallback onRestore;

  /// Opens the preview of a Note; null for a Folder, which cannot be opened.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListRow(
      title: name,
      subtitle: detail,
      leading: IconTile(isFolder ? IconAsset.folder : IconAsset.note),
      subtitleColor: urgent ? context.palette.destructiveText : null,
      trailing: RestorePill(name: name, onPressed: onRestore),
      onTap: onTap,
    );
  }
}

/// The Obnovit pill of a Trashed_Node, in the list and in the preview.
class RestorePill extends StatelessWidget {
  const RestorePill({
    super.key,
    required this.name,
    required this.onPressed,
    this.buttonKey = const ValueKey<String>('trash-restore'),
  });

  final String name;
  final VoidCallback onPressed;
  final Key buttonKey;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Semantics(
      button: true,
      label: strings.a11y_restoreNode(name),
      excludeSemantics: true,
      onTap: onPressed,
      child: PillButton(
        key: buttonKey,
        label: strings.trash_restore,
        onPressed: onPressed,
      ),
    );
  }
}
