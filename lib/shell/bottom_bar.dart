import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../theme/quest_theme.dart';
import '../theme/tokens.dart';
import '../ui_kit/common/app_icon.dart';
import 'destination.dart';

/// Bottom bar with the tabs Timer, Questy, Kalendář, Poznámky and Nastavení; the
/// active one is brass, the others faint (see `.tabbar` in the design).
class BottomBar extends StatelessWidget {
  const BottomBar({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  /// The tab to mark: the shown Destination's [Destination.tab].
  final Destination selected;
  final ValueChanged<Destination> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final p = context.palette;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: p.boardRaised,
        border: Border(
          top: BorderSide(color: p.boardLine, width: Metrics.hairline),
        ),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.only(top: Space.s8, bottom: Space.s4),
            child: Row(
              children: <Widget>[
                for (final Destination tab in Destination.tabs)
                  Expanded(
                    child: _TabItem(
                      key: ValueKey<Destination>(tab),
                      icon: tab.icon,
                      label: tab.label(l10n),
                      selected: tab == selected,
                      onTap: () => onSelected(tab),
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

class _TabItem extends StatelessWidget {
  const _TabItem({
    super.key,
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final Color color = selected ? p.brassText : p.textFaint;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      onTap: onTap,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Radii.control),
        // The design marks the active tab by colour alone: a touch, a pointer
        // resting on a tab (desktop, iPad) or a leftover focus must not paint
        // a pill behind it.
        splashFactory: NoSplash.splashFactory,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        focusColor: Colors.transparent,
        overlayColor: const WidgetStatePropertyAll<Color>(Colors.transparent),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: Metrics.touchTarget),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              AppIcon(icon, color: color),
              const SizedBox(height: Space.s4),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.bodyText.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
