import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';

Color tintFill(Color color, Color over, double amount) =>
    Color.lerp(over, color, amount)!;

Color tintInk(Color color, Color text, double amount) =>
    Color.lerp(text, color, amount)!;

class ChoiceChipX extends StatelessWidget {
  const ChoiceChipX({
    super.key,
    required this.label,
    required this.selected,
    required this.onSelected,
    this.color,
    this.showDot = false,
  });

  final String label;
  final bool selected;
  final ValueChanged<bool>? onSelected;
  final Color? color;
  final bool showDot;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final accent = color ?? palette.brass;
    return ChoiceChip(
      selected: selected,
      onSelected: onSelected,
      showCheckmark: false,
      backgroundColor: palette.card,
      selectedColor: tintFill(accent, palette.card, 0.20),
      side: BorderSide(
        color: selected ? accent.withValues(alpha: 0.5) : palette.boardLine,
        width: Metrics.hairline,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: Space.s12,
        vertical: Space.s8,
      ),
      labelPadding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Radii.control),
      ),
      avatar: showDot
          ? SizedBox.square(
              dimension: Metrics.chipDot,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: accent,
                  shape: BoxShape.circle,
                ),
              ),
            )
          : null,
      label: Text(label),
      labelStyle: context.bodyText.labelLarge?.copyWith(
        color: selected ? tintInk(accent, palette.text, 0.45) : palette.text,
      ),
    );
  }
}

class TypeTag extends StatelessWidget {
  const TypeTag({super.key, required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      decoration: BoxDecoration(
        color: tintFill(color, palette.card, 0.20),
        borderRadius: BorderRadius.circular(Radii.tag),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: Space.s8,
        vertical: Space.s4,
      ),
      child: Text(
        label,
        style: context.bodyText.bodySmall?.copyWith(
          color: tintInk(color, palette.text, 0.45),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
