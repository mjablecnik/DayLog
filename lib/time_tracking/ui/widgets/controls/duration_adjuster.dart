import 'package:flutter/material.dart';

import '../../../theme/time_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../theme/app_theme.dart';
import '../../../../theme/tokens.dart';
import '../../../../ui_kit/common/app_icon.dart';

class DurationAdjuster extends StatelessWidget {
  const DurationAdjuster({
    super.key,
    required this.minutes,
    required this.onIncrement,
    required this.onDecrement,
    required this.min,
    required this.max,
    required this.theme,
  });

  final int minutes;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final int min;
  final int max;
  final AppThemeData theme;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final palette = context.palette;

    Widget step(String icon, String label, VoidCallback? onPressed) => Semantics(
      button: true,
      enabled: onPressed != null,
      label: label,
      excludeSemantics: true,
      onTap: onPressed,
      child: Tooltip(
        message: label,
        child: Material(
          color: palette.tone,
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onPressed,
            child: SizedBox.square(
              dimension: Metrics.touchTarget,
              child: Center(
                child: AppIcon(
                  icon,
                  size: Metrics.iconSize,
                  color: onPressed == null ? palette.textFaint : palette.text,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    return Material(
      color: palette.card,
      shape: StadiumBorder(side: BorderSide(color: palette.boardLine)),
      child: Padding(
        padding: const EdgeInsets.all(Space.s4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            step(
              IconAsset.minus,
              strings.time_durationDecreaseLabel,
              minutes > min ? onDecrement : null,
            ),
            const SizedBox(width: Space.s16),
            Text(
              strings.time_durationMinutesLabel(minutes),
              style: context.bodyText.titleLarge?.copyWith(
                fontWeight: const FontWeight(650),
              ),
            ),
            const SizedBox(width: Space.s16),
            step(
              IconAsset.plus,
              strings.time_durationIncreaseLabel,
              minutes < max ? onIncrement : null,
            ),
          ],
        ),
      ),
    );
  }
}
