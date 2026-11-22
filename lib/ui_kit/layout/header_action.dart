import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';
import '../common/app_icon.dart';

class HeaderAction extends StatelessWidget {
  const HeaderAction({
    super.key,
    required this.icon,
    required this.semanticLabel,
    required this.onPressed,
    this.badgeCount,
    this.emphasized = false,
  });

  final String icon;
  final String semanticLabel;
  final VoidCallback? onPressed;
  final int? badgeCount;

  /// Draws the action as a brass button, for the one primary action of a screen.
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final count = badgeCount ?? 0;
    return Semantics(
      label: semanticLabel,
      child: IconButton(
        tooltip: semanticLabel,
        onPressed: onPressed,
        style: IconButton.styleFrom(
          fixedSize: const Size.square(Metrics.touchTarget),
          minimumSize: const Size.square(Metrics.touchTarget),
          padding: EdgeInsets.zero,
          backgroundColor: emphasized ? palette.brass : palette.tone,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Radii.headerAction),
          ),
        ),
        icon: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox.square(
              dimension: Metrics.touchTarget,
              child: Center(
                child: AppIcon(
                  icon,
                  color: emphasized ? palette.inkOnBrass : palette.textDim,
                ),
              ),
            ),
            if (count > 0)
              Positioned(
                top: Space.s2,
                right: Space.s2,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: palette.brass,
                    borderRadius: BorderRadius.circular(Radii.pill),
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      minWidth: Metrics.badge,
                      minHeight: Metrics.badge,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: Space.s3),
                      child: Center(
                        child: ExcludeSemantics(
                          child: Text(
                            '$count',
                            style: context.bodyText.labelSmall?.copyWith(
                              color: palette.inkOnBrass,
                              letterSpacing: 0,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// The back or close element at the left of an App_Header: a bare icon in a
/// 44 × 44 hit area, lighter than the tonal [HeaderAction]s on the right.
class HeaderBareAction extends StatelessWidget {
  const HeaderBareAction({
    super.key,
    required this.icon,
    required this.semanticLabel,
    required this.onPressed,
  });

  final String icon;
  final String semanticLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Semantics(
      label: semanticLabel,
      child: IconButton(
        tooltip: semanticLabel,
        onPressed: onPressed,
        style: IconButton.styleFrom(
          fixedSize: const Size.square(Metrics.touchTarget),
          minimumSize: const Size.square(Metrics.touchTarget),
          padding: EdgeInsets.zero,
        ),
        icon: AppIcon(icon, color: palette.textDim),
      ),
    );
  }
}
