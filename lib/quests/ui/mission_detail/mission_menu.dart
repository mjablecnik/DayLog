import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../ui_kit/common/app_icon.dart';
import '../../../ui_kit/layout/header_action.dart';
import '../../../ui_kit/sheet/menu_sheet.dart';

/// What the "···" menu offers.
enum MissionMenuAction { edit, addQuest, delete }

/// The "···" button with its menu: edit, add quest (only while the Mission is
/// open) and, last and in the destructive colour, delete.
class MissionMenuButton extends StatelessWidget {
  const MissionMenuButton({
    super.key,
    required this.canAddQuest,
    required this.onSelected,
  });

  final bool canAddQuest;
  final ValueChanged<MissionMenuAction> onSelected;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return HeaderAction(
      icon: IconAsset.more,
      semanticLabel: strings.a11y_missionMenu,
      onPressed: () async {
        final action = await showMenuSheet<MissionMenuAction>(
          context,
          title: strings.a11y_missionMenu,
          items: [
            (
              value: MissionMenuAction.edit,
              label: strings.mission_menuEdit,
              icon: IconAsset.edit,
              destructive: false,
            ),
            if (canAddQuest)
              (
                value: MissionMenuAction.addQuest,
                label: strings.mission_menuAddQuest,
                icon: IconAsset.plus,
                destructive: false,
              ),
            (
              value: MissionMenuAction.delete,
              label: strings.mission_menuDelete,
              icon: IconAsset.trash,
              destructive: true,
            ),
          ],
        );
        if (context.mounted && action != null) onSelected(action);
      },
    );
  }
}
