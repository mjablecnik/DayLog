import 'package:flutter/material.dart';

import '../../../theme/time_theme.dart';
import '../../../../l10n/app_localizations.dart';

class DurationAdjuster extends StatelessWidget {
  final int minutes;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final int min;
  final int max;
  final AppThemeData theme;

  const DurationAdjuster({
    super.key,
    required this.minutes,
    required this.onIncrement,
    required this.onDecrement,
    required this.min,
    required this.max,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _StepButton(
          icon: Icons.remove,
          label: l10n.time_durationDecreaseLabel,
          theme: theme,
          enabled: minutes > min,
          onPressed: onDecrement,
        ),
        const SizedBox(width: 16),
        Text(
          l10n.time_durationMinutesLabel(minutes),
          style: TextStyle(
            color: theme.dim,
            fontSize: 15,
          ),
        ),
        const SizedBox(width: 16),
        _StepButton(
          icon: Icons.add,
          label: l10n.time_durationIncreaseLabel,
          theme: theme,
          enabled: minutes < max,
          onPressed: onIncrement,
        ),
      ],
    );
  }
}

class _StepButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final AppThemeData theme;
  final bool enabled;
  final VoidCallback onPressed;

  const _StepButton({
    required this.icon,
    required this.label,
    required this.theme,
    required this.enabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    // The drawn circle is 36 px; the tap area around it is 44 px.
    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      excludeSemantics: true,
      onTap: enabled ? onPressed : null,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: enabled ? onPressed : null,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Center(
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.panel,
                border: Border.all(color: theme.border),
              ),
              child: Icon(
                icon,
                size: 18,
                color: enabled ? theme.dim : theme.faint,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
