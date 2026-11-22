import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';
import '../common/app_icon.dart';

/// Tonal rounded-square previous/next button (day, week and month steps).
/// A disabled button keeps a faint tonal square.
class StepButton extends StatelessWidget {
  const StepButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.size = 40,
  });

  final String icon;
  final String label;
  final VoidCallback? onPressed;
  final double size;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final enabled = onPressed != null;
    final radius = BorderRadius.circular(Radii.headerAction);
    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      excludeSemantics: true,
      onTap: onPressed,
      child: Tooltip(
        message: label,
        child: InkResponse(
          onTap: onPressed,
          containedInkWell: true,
          borderRadius: radius,
          child: SizedBox.square(
            dimension: Metrics.touchTarget,
            child: Center(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: p.tone,
                  borderRadius: radius,
                ),
                child: SizedBox.square(
                  dimension: size,
                  child: Center(
                    child: AppIcon(
                      icon,
                      size: Metrics.iconSmall + Space.s2,
                      color: enabled ? p.textDim : p.textFaint,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
