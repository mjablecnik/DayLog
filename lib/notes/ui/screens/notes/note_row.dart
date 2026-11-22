import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../ui_kit/common/app_icon.dart';
import '../../../../ui_kit/layout/grouped_list.dart';

/// One Note in the list: name, the date of its last edit and a two-line preview.
class NoteRow extends StatelessWidget {
  const NoteRow({
    super.key,
    required this.name,
    required this.date,
    required this.preview,
    required this.onTap,
  });

  final String name;

  /// Already localized last-edited date ("dnes", "včera", "17. 11.").
  final String date;

  /// The Note_Preview; may be empty.
  final String preview;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Semantics(
      button: true,
      label: '${strings.a11y_openNote(name)}. $date. $preview',
      excludeSemantics: true,
      onTap: onTap,
      child: ListRow(
        leading: const IconTile(IconAsset.note),
        title: name,
        subtitle: preview.isEmpty ? null : preview,
        value: date,
        onTap: onTap,
      ),
    );
  }
}
