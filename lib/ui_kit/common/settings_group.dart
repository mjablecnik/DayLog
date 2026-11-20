import 'package:flutter/material.dart';

import '../../theme/quest_theme.dart';
import '../../theme/tokens.dart';

/// A caps label above its content: one group of the Settings page.
class SettingsGroup extends StatelessWidget {
  const SettingsGroup({super.key, required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Semantics(
          header: true,
          child: Text(
            label.toUpperCase(),
            style: context.bodyText.labelSmall!.copyWith(
              color: context.palette.textFaint,
            ),
          ),
        ),
        const SizedBox(height: Space.s8),
        child,
      ],
    );
  }
}
