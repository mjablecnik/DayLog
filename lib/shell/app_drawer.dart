import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../theme/tokens.dart';
import '../ui_kit/common/app_icon.dart';
import 'destination.dart';

/// The side panel with the Destinations that are not tabs of the Bottom_Bar,
/// grouped as Time and Planning.
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key, required this.selected, required this.onSelect});

  /// The shown Destination, marked in the list when it is listed here.
  final Destination selected;
  final ValueChanged<Destination> onSelect;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l = AppLocalizations.of(context);
    final AppPalette p = context.palette;
    final List<Destination> items = Destination.drawerItems;
    return Drawer(
      backgroundColor: p.boardRaised,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            Space.s12,
            Space.s20,
            Space.s12,
            Space.s16,
          ),
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Space.s12),
              child: Semantics(
                header: true,
                child: Text(
                  l.app_name,
                  style: context.displayText.headlineMedium,
                ),
              ),
            ),
            for (final DestinationGroup group
                in DestinationGroup.values) ...<Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  Space.s12,
                  Space.s24,
                  Space.s12,
                  Space.s8,
                ),
                child: Text(
                  _groupLabel(l, group).toUpperCase(),
                  style: context.bodyText.labelSmall!.copyWith(
                    color: p.textFaint,
                  ),
                ),
              ),
              for (final Destination d in items.where(
                (Destination d) => d.group == group,
              ))
                _DrawerItem(
                  key: ValueKey<Destination>(d),
                  destination: d,
                  selected: d == selected,
                  onTap: () => onSelect(d),
                ),
            ],
          ],
        ),
      ),
    );
  }

  static String _groupLabel(AppLocalizations l, DestinationGroup group) =>
      switch (group) {
        DestinationGroup.time => l.shell_groupTime,
        DestinationGroup.planning => l.shell_groupPlanning,
      };
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    super.key,
    required this.destination,
    required this.selected,
    required this.onTap,
  });

  final Destination destination;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppPalette p = context.palette;
    final String label = destination.label(AppLocalizations.of(context));
    final Color color = selected ? p.brassText : p.text;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      onTap: onTap,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(Radii.control),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: Metrics.touchTarget),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: Space.s12),
              child: Row(
                children: <Widget>[
                  AppIcon(
                    destination.icon,
                    size: Metrics.iconSize,
                    color: color,
                  ),
                  const SizedBox(width: Space.s16),
                  Expanded(
                    child: Text(
                      label,
                      style: context.bodyText.bodyLarge!.copyWith(color: color),
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
