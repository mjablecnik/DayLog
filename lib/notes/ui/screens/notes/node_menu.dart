import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../ui_kit/common/app_icon.dart';
import '../../../../ui_kit/layout/header_action.dart';
import '../../../../ui_kit/sheet/menu_sheet.dart';

/// What the "···" menu of a Folder or Note offers.
enum NodeMenuAction { rename, move, trash }

/// The "···" button with Přejmenovat, Přesunout and, last and in the
/// destructive colour, Přesunout do koše. While [enabled] is false the button
/// opens nothing.
class NodeMenuButton extends StatelessWidget {
  const NodeMenuButton({
    super.key,
    required this.enabled,
    required this.onSelected,
  });

  final bool enabled;
  final ValueChanged<NodeMenuAction> onSelected;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return HeaderAction(
      key: const ValueKey<String>('node-menu'),
      icon: IconAsset.more,
      semanticLabel: strings.a11y_nodeMenu,
      onPressed: !enabled
          ? null
          : () async {
              final action = await showMenuSheet<NodeMenuAction>(
                context,
                title: strings.a11y_nodeMenu,
                items: [
                  (
                    value: NodeMenuAction.rename,
                    label: strings.notes_actionRename,
                    icon: IconAsset.edit,
                    destructive: false,
                  ),
                  (
                    value: NodeMenuAction.move,
                    label: strings.notes_actionMove,
                    icon: IconAsset.move,
                    destructive: false,
                  ),
                  (
                    value: NodeMenuAction.trash,
                    label: strings.notes_actionTrash,
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
