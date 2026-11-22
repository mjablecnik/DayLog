import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../theme/app_theme.dart';
import '../../../../theme/tokens.dart';
import '../../../../ui_kit/common/app_icon.dart';
import '../../../../ui_kit/sheet/confirm_destructive.dart';
import '../../../theme/time_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../providers/timer_provider.dart';
import '../../../services/timer_service.dart';

class TimerControls extends ConsumerWidget {
  final AppThemeData theme;
  final int adjustedMinutes;

  const TimerControls({
    super.key,
    required this.theme,
    required this.adjustedMinutes,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(timerProvider);
    final notifier = ref.read(timerProvider.notifier);
    final status = timerState.status;

    final isIdle = status == TimerStatus.idle;
    final isRunning = status == TimerStatus.running;
    final isPaused = status == TimerStatus.paused;

    final l10n = AppLocalizations.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _CircleButton(
          size: Metrics.fab,
          label: l10n.time_timerStopLabel,
          icon: IconAsset.stop,
          caption: l10n.time_timerLogCaption,
          enabled: isRunning || isPaused,
          onPressed: () => _stopWithConfirmation(context, notifier),
          isAccent: false,
        ),
        const SizedBox(width: Space.s20),
        _CircleButton(
          size: Metrics.timerPrimary,
          label: isRunning
              ? l10n.time_timerPauseLabel
              : isPaused
              ? l10n.time_timerResumeLabel
              : l10n.time_timerStartLabel,
          icon: isRunning ? IconAsset.pause : IconAsset.play,
          enabled: true,
          onPressed: () {
            if (isIdle) {
              notifier.setDuration(adjustedMinutes);
              notifier.start();
            } else if (isRunning) {
              notifier.pause();
            } else if (isPaused) {
              notifier.resume();
            }
          },
          isAccent: true,
        ),
        const SizedBox(width: Space.s20),
        _CircleButton(
          size: Metrics.fab,
          label: l10n.time_timerFinishLabel,
          icon: IconAsset.flag,
          caption: l10n.time_timerFinishCaption,
          enabled: isRunning || isPaused,
          onPressed: notifier.finishNow,
          isAccent: false,
        ),
      ],
    );
  }

  Future<void> _stopWithConfirmation(
    BuildContext context,
    TimerNotifier notifier,
  ) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await confirmDestructive(
      context,
      title: l10n.time_timerResetTitle,
      body: l10n.time_timerResetBody,
      confirmLabel: l10n.time_commonReset,
      cancelLabel: l10n.time_commonCancel,
    );

    if (confirmed == true) {
      notifier.stopAndLog();
    }
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({
    required this.size,
    required this.label,
    required this.icon,
    required this.enabled,
    required this.onPressed,
    required this.isAccent,
    this.caption,
  });

  final double size;
  final String label;
  final String icon;
  final bool enabled;
  final VoidCallback onPressed;
  final bool isAccent;
  final String? caption;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final foreground = isAccent ? palette.inkOnBrass : palette.text;
    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      excludeSemantics: true,
      onTap: enabled ? onPressed : null,
      child: Opacity(
        opacity: enabled ? 1 : 0.5,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: isAccent ? AppGlow.button(palette) : null,
              ),
              child: Material(
                color: isAccent ? palette.brass : palette.card,
                shape: CircleBorder(
                  side: isAccent
                      ? BorderSide.none
                      : BorderSide(color: palette.lineStrong),
                ),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: enabled ? onPressed : null,
                  child: SizedBox.square(
                    dimension: size,
                    child: Center(
                      child: AppIcon(
                        icon,
                        color: foreground,
                        size: isAccent ? Space.s32 : Metrics.iconSize,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (caption case final text?) ...[
              const SizedBox(height: Space.s4),
              Text(
                text,
                style: context.bodyText.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: context.palette.textDim,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
