import 'package:flutter/material.dart';

import '../../theme/tokens.dart';
import '../layout/section_headers.dart';

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
        SectionLabel(label),
        const SizedBox(height: Space.s8),
        child,
      ],
    );
  }
}
