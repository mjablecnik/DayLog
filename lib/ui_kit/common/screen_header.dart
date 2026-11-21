import 'package:flutter/material.dart';

import '../../theme/tokens.dart';
import '../../theme/app_theme.dart';
import 'app_icon.dart';
import 'menu_button.dart';

/// The header row every top-level screen starts with: the [MenuButton] at the
/// same place on every screen, and the screen's own heading content beside it.
///
/// The heading content goes in [child] and takes the rest of the row, so a
/// screen changes only what sits beside the button, never where the button is.
class ScreenHeader extends StatelessWidget {
  const ScreenHeader({super.key, required this.child, this.onBack});

  final Widget child;

  /// Adds a back button right after the menu button, for a page that belongs
  /// to another one (History and Statistics belong to the Timer).
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Space.s20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: Metrics.touchTarget),
        // The button is 44 wide, so the heading starts right after it.
        child: Row(
          children: <Widget>[
            const MenuButton(),
            if (onBack != null) _BackButton(onTap: onBack!),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final String label = MaterialLocalizations.of(context).backButtonTooltip;
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      onTap: onTap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          width: Metrics.touchTarget,
          height: Metrics.touchTarget,
          child: Center(
            child: AppIcon(
              IconAsset.chevronLeft,
              size: Metrics.iconSize,
              color: context.palette.textDim,
            ),
          ),
        ),
      ),
    );
  }
}
