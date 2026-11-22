import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../theme/tokens.dart';
import '../ui_kit/common/app_icon.dart';
import '../ui_kit/controls/choice_chip.dart';
import '../ui_kit/layout/grouped_list.dart';
import '../ui_kit/sheet/app_sheet.dart';
import 'module.dart';

Key launcherTileKey(Module module) =>
    ValueKey<String>('launcher-tile-${module.name}');

Future<Module?> showModuleLauncher(
  BuildContext context, {
  required Module current,
}) => showAppSheet<Module>(
  context,
  builder: (_) => ModuleLauncher(current: current),
);

class ModuleLauncher extends StatelessWidget {
  const ModuleLauncher({super.key, required this.current});

  final Module current;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return AppSheet(
      title: strings.shell_modulesTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var index = 0; index < Module.launchable.length; index += 2) ...[
            if (index > 0) const SizedBox(height: Space.s12),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: _tile(Module.launchable[index])),
                  const SizedBox(width: Space.s12),
                  Expanded(child: _tile(Module.launchable[index + 1])),
                ],
              ),
            ),
          ],
          const SizedBox(height: Space.s12),
          GroupedList(
            children: [
              ListRow(
                key: launcherTileKey(Module.settings),
                title: strings.app_tabSettings,
                leading: const IconTile(IconAsset.gear),
                showChevron: true,
                onTap: () => AppSheet.close(context, Module.settings),
              ),
            ],
          ),
          const SizedBox(height: Space.s12),
          Text(
            strings.shell_launcherHint,
            textAlign: TextAlign.center,
            style: context.bodyText.bodySmall?.copyWith(
              color: context.palette.textFaint,
            ),
          ),
        ],
      ),
    );
  }

  Widget _tile(Module module) => _ModuleTile(
    key: launcherTileKey(module),
    module: module,
    selected: module == current,
  );
}

class _ModuleTile extends StatelessWidget {
  const _ModuleTile({super.key, required this.module, required this.selected});

  final Module module;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final strings = AppLocalizations.of(context);
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: selected
            ? tintFill(palette.brass, palette.card, 0.08)
            : palette.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.tile),
          side: BorderSide(
            color: selected ? palette.brass : palette.boardLine,
            width: selected ? Metrics.focusBorder : Metrics.hairline,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => AppSheet.close(context, module),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: Metrics.tileMin),
            child: Padding(
              padding: const EdgeInsets.all(Space.s12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: Metrics.launcherIcon,
                    height: Metrics.launcherIcon,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selected ? palette.brass : palette.brassSoft,
                      borderRadius: BorderRadius.circular(Radii.launcherIcon),
                    ),
                    child: AppIcon(
                      module.icon,
                      color: selected ? palette.inkOnBrass : palette.brassText,
                    ),
                  ),
                  const SizedBox(height: Space.s6),
                  Text(
                    module.label(strings),
                    style: context.bodyText.titleLarge,
                  ),
                  Text(
                    module.pages.map((page) => page.label(strings)).join(' · '),
                    style: context.bodyText.bodySmall?.copyWith(
                      color: palette.textDim,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
