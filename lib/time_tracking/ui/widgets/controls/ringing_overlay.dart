import 'package:flutter/material.dart';

import '../../../theme/time_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../theme/app_theme.dart';
import '../../../../theme/tokens.dart';
import '../../../../ui_kit/common/app_icon.dart';
import '../../../../ui_kit/controls/app_buttons.dart';

class RingingOverlay extends StatefulWidget {
  final AppThemeData theme;
  final VoidCallback onDismiss;

  const RingingOverlay({super.key, required this.theme, required this.onDismiss});

  @override
  State<RingingOverlay> createState() => _RingingOverlayState();
}

class _RingingOverlayState extends State<RingingOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  late Animation<double> _glow;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    )..repeat(reverse: true);
    _scale = Tween<double>(begin: 0.90, end: 1.10).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _glow = Tween<double>(begin: 16, end: 40).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final l10n = AppLocalizations.of(context);

    return Container(
      color: theme.background.withValues(alpha: 0.95),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.accent,
                    boxShadow: [
                      BoxShadow(
                        color: theme.glow,
                        blurRadius: _glow.value,
                        spreadRadius: _glow.value * 0.2,
                      ),
                    ],
                  ),
                  transform: Matrix4.diagonal3Values(
                    _scale.value,
                    _scale.value,
                    1,
                  )..translateByDouble(-60 * (_scale.value - 1), -60 * (_scale.value - 1), 0, 0),
                  child: Center(
                    child: AppIcon(IconAsset.bell, color: theme.ink, size: Metrics.ring),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            Text(
              l10n.time_timerTimeUpTitle,
              style: context.displayText.headlineLarge,
            ),
            const SizedBox(height: Space.s48),
            AppButton.primary(
              label: l10n.time_ringingDismiss,
              onPressed: widget.onDismiss,
              expand: false,
            ),
          ],
        ),
      ),
    );
  }
}
