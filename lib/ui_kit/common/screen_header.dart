import 'package:flutter/widgets.dart';

import '../../theme/tokens.dart';
import 'menu_button.dart';

/// The header row every top-level screen starts with: the [MenuButton] at the
/// same place on every screen, and the screen's own heading content beside it.
///
/// The heading content goes in [child] and takes the rest of the row, so a
/// screen changes only what sits beside the button, never where the button is.
class ScreenHeader extends StatelessWidget {
  const ScreenHeader({super.key, required this.child});

  final Widget child;

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
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}
