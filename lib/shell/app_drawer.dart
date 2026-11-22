import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../theme/tokens.dart';
import '../ui_kit/common/app_icon.dart';
import '../ui_kit/layout/section_headers.dart';
import 'destination.dart';
import 'module.dart';

Key drawerItemKey(Destination destination) =>
    ValueKey<String>('drawer-${destination.name}');

/// The drawer is one flat list of every page, grouped in two sections.
class AppDrawer extends StatelessWidget {
  const AppDrawer({
    super.key,
    required this.current,
    required this.onSelectPage,
  });

  /// The page that is open now.
  final Destination current;
  final ValueChanged<Destination> onSelectPage;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final palette = context.palette;

    Widget row(Destination page) => KeyedSubtree(
      key: drawerItemKey(page),
      child: _DrawerRow(
        page: page,
        selected: page == current,
        onTap: () => onSelectPage(page),
      ),
    );

    Widget section(String label, List<Module> modules) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            Space.s12,
            Space.s16,
            Space.s12,
            Space.s4,
          ),
          child: SectionLabel(label),
        ),
        for (final module in modules)
          for (final page in module.pages) row(page),
      ],
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
            padding: const EdgeInsets.fromLTRB(
              Space.s16,
              Space.s32,
              Space.s16,
              Space.s22,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: (constraints.maxHeight - Space.s32 - Space.s22).clamp(
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
                    section(strings.shell_drawerSectionTime, const [
                      Module.time,
                    ]),
                    section(strings.shell_drawerSectionPlanning, const [
                      Module.quests,
                      Module.calendar,
                      Module.notes,
                    ]),
                    const Spacer(),
                    const Divider(height: Metrics.hairline),
                    const SizedBox(height: Space.s8),
                    row(Destination.settings),
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

class _DrawerRow extends StatelessWidget {
  const _DrawerRow({
    required this.page,
    required this.selected,
    required this.onTap,
  });

  final Destination page;
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
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: Metrics.touchTarget),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Space.s12,
                vertical: Space.s6,
              ),
              child: Row(
                children: [
                  Container(
                    width: Metrics.drawerItemIcon,
                    height: Metrics.drawerItemIcon,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selected ? palette.brass : palette.tone,
                      borderRadius: BorderRadius.circular(Radii.drawerIcon),
                    ),
                    child: AppIcon(
                      page.icon,
                      color: selected ? palette.inkOnBrass : palette.text,
                    ),
                  ),
                  const SizedBox(width: Space.s14),
                  Expanded(
                    child: Text(
                      page.label(AppLocalizations.of(context)),
                      style: context.bodyText.titleMedium?.copyWith(
                        fontWeight: const FontWeight(650),
                        color: selected ? palette.brassText : null,
                      ),
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
