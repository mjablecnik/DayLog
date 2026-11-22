import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import '../../../theme/tokens.dart';
import '../../../ui_kit/forms/app_text_field.dart';

/// A rounded raised card that groups the rows of a calendar form or detail.
class CalendarCard extends StatelessWidget {
  const CalendarCard({super.key, required this.children, this.gap = Space.s12});

  final List<Widget> children;
  final double gap;

  @override
  Widget build(BuildContext context) {
    final AppPalette p = context.palette;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: p.boardRaised,
        borderRadius: BorderRadius.circular(Radii.card),
        border: Border.all(color: p.boardLine, width: Metrics.hairline),
      ),
      child: Padding(
        padding: const EdgeInsets.all(Space.s16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            for (int i = 0; i < children.length; i++) ...<Widget>[
              if (i > 0) SizedBox(height: gap),
              children[i],
            ],
          ],
        ),
      ),
    );
  }
}

/// The calendar and notes forms use the shared Form_Field.
typedef CalendarTextField = AppTextField;

/// A row with a label and a switch, at least 44 logical pixels high.
class CalendarSwitchRow extends StatelessWidget {
  const CalendarSwitchRow({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final AppPalette p = context.palette;
    return MergeSemantics(
      child: InkWell(
        onTap: () => onChanged(!value),
        borderRadius: BorderRadius.circular(Radii.control),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: Metrics.touchTarget),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(label, style: context.bodyText.titleMedium),
              ),
              Switch(
                value: value,
                onChanged: onChanged,
                activeThumbColor: p.inkOnBrass,
                activeTrackColor: p.brass,
                inactiveThumbColor: p.textFaint,
                inactiveTrackColor: p.field,
                trackOutlineColor: WidgetStatePropertyAll<Color>(p.boardLine),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A tappable row with a label at the left and a value at the right.
class CalendarValueRow extends StatelessWidget {
  const CalendarValueRow({
    super.key,
    required this.label,
    required this.value,
    required this.onTap,
    this.trailing,
  });

  final String label;
  final String value;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final AppPalette p = context.palette;
    return Semantics(
      button: true,
      label: '$label, $value',
      excludeSemantics: true,
      onTap: onTap,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Radii.control),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: Metrics.touchTarget),
          child: Row(
            children: <Widget>[
              Expanded(child: Text(label, style: context.bodyText.titleMedium)),
              Text(value, style: context.bodyText.bodyLarge!.copyWith(color: p.textDim)),
              ?trailing,
            ],
          ),
        ),
      ),
    );
  }
}
