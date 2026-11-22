import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../ui_kit/layout/grouped_list.dart';
import '../../../../ui_kit/common/app_icon.dart';

/// One Folder in the list: icon, name, what is inside, and a chevron.
class FolderRow extends StatelessWidget {
  const FolderRow({
    super.key,
    required this.name,
    required this.summary,
    required this.onTap,
  });

  final String name;

  /// Already localized, for example "2 složky · 9 poznámek".
  final String summary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Semantics(
      button: true,
      label: '${strings.a11y_openFolder(name)}. $summary',
      excludeSemantics: true,
      onTap: onTap,
      child: ListRow(
        leading: const IconTile(IconAsset.folder),
        title: name,
        subtitle: summary,
        showChevron: true,
        onTap: onTap,
      ),
    );
  }
}
