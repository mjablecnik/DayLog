import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../ui_kit/common/app_icon.dart';
import '../../../ui_kit/layout/header_action.dart';

class TrashButton extends StatelessWidget {
  const TrashButton({super.key, required this.count, required this.onPressed});

  final int count;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Semantics(
      value: strings.trash_count(count),
      child: HeaderAction(
        key: const ValueKey<String>('notes-trash'),
        icon: IconAsset.trash,
        semanticLabel: strings.notes_trashButton,
        badgeCount: count,
        onPressed: onPressed,
      ),
    );
  }
}
