import 'package:flutter/widgets.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';
import 'app_icon.dart';

/// Provided by the Shell above the Destinations; [open] opens the Drawer.
///
/// A pushed route sits beside the Shell in the Navigator, not below this
/// scope, so it never shows a [MenuButton] and keeps its back button.
class ShellMenuScope extends InheritedWidget {
  const ShellMenuScope({
    super.key,
    required this.open,
    required super.child,
    this.openPage,
  });

  final VoidCallback open;

  /// Shows the page with this link name (`history`, `statistics`, ...) without
  /// the Drawer; null where a screen cannot switch pages.
  final ValueChanged<String>? openPage;

  static ShellMenuScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ShellMenuScope>();

  @override
  bool updateShouldNotify(ShellMenuScope oldWidget) => open != oldWidget.open || openPage != oldWidget.openPage;
}

/// The button in a screen header that opens the Drawer. Draws nothing when no
/// [ShellMenuScope] is above it (tests, pushed routes).
class MenuButton extends StatelessWidget {
  const MenuButton({super.key});

  @override
  Widget build(BuildContext context) {
    final ShellMenuScope? scope = ShellMenuScope.maybeOf(context);
    if (scope == null) return const SizedBox.shrink();
    final String label = AppLocalizations.of(context).shell_openMenu;
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      onTap: scope.open,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: scope.open,
        child: SizedBox(
          width: Metrics.touchTarget,
          height: Metrics.touchTarget,
          // Left-aligned, so the icon sits on the same edge as the content below.
          child: Align(
            alignment: Alignment.centerLeft,
            child: AppIcon(
              IconAsset.menu,
              size: Metrics.iconSize,
              color: context.palette.textDim,
            ),
          ),
        ),
      ),
    );
  }
}
