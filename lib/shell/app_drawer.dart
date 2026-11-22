import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../theme/tokens.dart';
import '../ui_kit/common/app_icon.dart';
import 'destination.dart';
import 'module.dart';

Key drawerItemKey(Destination destination) =>
    ValueKey<String>('drawer-${destination.name}');

Key drawerModuleKey(Module module) =>
    ValueKey<String>('drawer-module-${module.name}');

class AppDrawer extends StatelessWidget {
  const AppDrawer({
    super.key,
    required this.current,
    required this.onSelectModule,
    required this.onSelectPage,
  });

  final Module current;
  final ValueChanged<Module> onSelectModule;
  final ValueChanged<Destination> onSelectPage;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final palette = context.palette;

    Widget row(Module module) => _DrawerModuleRow(
      key: drawerModuleKey(module),
      module: module,
      selected: module == current,
      onTap: () => onSelectModule(module),
    );

    return Drawer(
      width: Metrics.drawerWidth,
      backgroundColor: palette.sheet,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(
          right: Radius.circular(Radii.dialog),
        ),
      ),
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: Space.s16,
              vertical: Space.s22,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: (constraints.maxHeight - Space.s22 * 2).clamp(
                  0.0,
                  double.infinity,
                ),
              ),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Semantics(
                      header: true,
                      child: Text(
                        strings.app_name,
                        style: context.displayText.displaySmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(height: Space.s16),
                    for (final module in Module.launchable) ...[
                      KeyedSubtree(
                        key: drawerItemKey(module.pages.first),
                        child: row(module),
                      ),
                      if (module.pages.length > 1)
                        Padding(
                          padding: const EdgeInsets.only(
                            left: Metrics.drawerChipInset,
                          ),
                          child: Wrap(
                            spacing: Space.s6,
                            children: [
                              for (final page in module.pages.skip(1))
                                TextButton(
                                  key: drawerItemKey(page),
                                  onPressed: () => onSelectPage(page),
                                  style: TextButton.styleFrom(
                                    backgroundColor: palette.card,
                                    foregroundColor: palette.text,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: Space.s8,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        Radii.control,
                                      ),
                                      side: BorderSide(
                                        color: palette.boardLine,
                                      ),
                                    ),
                                    textStyle: context.bodyText.labelLarge
                                        ?.copyWith(fontSize: 13),
                                  ),
                                  child: Text(page.label(strings)),
                                ),
                            ],
                          ),
                        ),
                    ],
                    const Spacer(),
                    const Divider(height: Metrics.hairline),
                    const SizedBox(height: Space.s8),
                    KeyedSubtree(
                      key: drawerItemKey(Destination.settings),
                      child: row(Module.settings),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DrawerModuleRow extends StatelessWidget {
  const _DrawerModuleRow({
    super.key,
    required this.module,
    required this.selected,
    required this.onTap,
  });

  final Module module;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: selected ? palette.brassSoft : Colors.transparent,
        borderRadius: BorderRadius.circular(Radii.button),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Space.s12,
              vertical: Space.s6,
            ),
            child: Row(
              children: [
                Container(
                  width: Metrics.drawerIcon,
                  height: Metrics.drawerIcon,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selected ? palette.brass : palette.tone,
                    borderRadius: BorderRadius.circular(Radii.drawerIcon),
                  ),
                  child: AppIcon(
                    module.icon,
                    color: selected ? palette.inkOnBrass : palette.text,
                  ),
                ),
                const SizedBox(width: Space.s14),
                Expanded(
                  child: Text(
                    module.label(AppLocalizations.of(context)),
                    style: context.bodyText.titleLarge?.copyWith(
                      fontWeight: const FontWeight(650),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
