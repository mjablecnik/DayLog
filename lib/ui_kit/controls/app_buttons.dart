import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';
import '../common/app_icon.dart';

enum AppButtonKind { primary, tonal, destructive }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.kind = AppButtonKind.primary,
    this.icon,
    this.expand = true,
  });

  const AppButton.primary({
    Key? key,
    required String label,
    required VoidCallback? onPressed,
    String? icon,
    bool expand = true,
  }) : this(
         key: key,
         label: label,
         onPressed: onPressed,
         icon: icon,
         expand: expand,
       );

  const AppButton.tonal({
    Key? key,
    required String label,
    required VoidCallback? onPressed,
    String? icon,
    bool expand = true,
  }) : this(
         key: key,
         label: label,
         onPressed: onPressed,
         kind: AppButtonKind.tonal,
         icon: icon,
         expand: expand,
       );

  const AppButton.destructive({
    Key? key,
    required String label,
    required VoidCallback? onPressed,
    String? icon,
    bool expand = true,
  }) : this(
         key: key,
         label: label,
         onPressed: onPressed,
         kind: AppButtonKind.destructive,
         icon: icon,
         expand: expand,
       );

  final String label;
  final VoidCallback? onPressed;
  final AppButtonKind kind;
  final String? icon;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final (background, foreground) = switch (kind) {
      AppButtonKind.primary => (palette.brass, palette.inkOnBrass),
      AppButtonKind.tonal => (palette.tone, palette.text),
      AppButtonKind.destructive => (
        palette.destructive,
        palette.inkOnDestructive,
      ),
    };
    final enabled = onPressed != null;
    final radius = BorderRadius.circular(Radii.button);

    return SizedBox(
      width: expand ? double.infinity : null,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow: kind == AppButtonKind.primary && enabled
              ? AppGlow.button(palette)
              : null,
        ),
        child: Opacity(
          opacity: enabled ? 1 : 0.45,
          child: FilledButton(
            onPressed: onPressed,
            style: FilledButton.styleFrom(
              backgroundColor: background,
              disabledBackgroundColor: background,
              foregroundColor: foreground,
              disabledForegroundColor: foreground,
              visualDensity: VisualDensity.standard,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              minimumSize: const Size(
                Metrics.touchTarget,
                Metrics.buttonHeight,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: Space.s16,
                vertical: Space.s8,
              ),
              shape: RoundedRectangleBorder(borderRadius: radius),
              textStyle: context.bodyText.labelLarge?.copyWith(
                fontSize: 16.5,
                fontWeight: FontWeight.w700,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon case final name?) ...[
                  AppIcon(name, color: foreground),
                  const SizedBox(width: Space.s8),
                ],
                Flexible(child: Text(label, textAlign: TextAlign.center)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PillButton extends StatelessWidget {
  const PillButton({super.key, required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => FilledButton(
    onPressed: onPressed,
    style: FilledButton.styleFrom(
      backgroundColor: context.palette.tone,
      foregroundColor: context.palette.text,
      minimumSize: const Size(Metrics.touchTarget, Metrics.pillButton),
      tapTargetSize: MaterialTapTargetSize.padded,
      visualDensity: VisualDensity.standard,
      padding: const EdgeInsets.symmetric(horizontal: Space.s12),
      shape: const StadiumBorder(),
      textStyle: context.bodyText.labelLarge?.copyWith(
        fontSize: 14,
        fontWeight: const FontWeight(650),
      ),
    ),
    child: Text(label),
  );
}
