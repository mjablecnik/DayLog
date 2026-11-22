import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';
import '../common/app_icon.dart';
import '../common/haptics.dart';
import '../controls/app_buttons.dart';

/// Resolves to true only when the destructive action is confirmed.
Future<bool> confirmDestructive(
  BuildContext context, {
  required String title,
  required String body,
  required String confirmLabel,
  String? cancelLabel,
}) => _confirm(
  context,
  title: title,
  body: body,
  confirmLabel: confirmLabel,
  cancelLabel: cancelLabel,
  icon: IconAsset.alert,
  destructive: true,
);

/// Resolves to true only when the action is confirmed.
Future<bool> confirmAction(
  BuildContext context, {
  required String title,
  required String body,
  required String confirmLabel,
  String? cancelLabel,
  String icon = IconAsset.check,
}) => _confirm(
  context,
  title: title,
  body: body,
  confirmLabel: confirmLabel,
  cancelLabel: cancelLabel,
  icon: icon,
  destructive: false,
);

Future<bool> _confirm(
  BuildContext context, {
  required String title,
  required String body,
  required String confirmLabel,
  required String? cancelLabel,
  required String icon,
  required bool destructive,
}) async {
  final strings = AppLocalizations.of(context);
  final confirmed = await showDialog<bool>(
    context: context,
    barrierColor: context.palette.scrim,
    barrierLabel: strings.common_close,
    builder: (dialogContext) => _ConfirmDialog(
      title: title,
      body: body,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel ?? strings.common_cancel,
      icon: icon,
      destructive: destructive,
    ),
  );
  return confirmed ?? false;
}

class _ConfirmDialog extends StatelessWidget {
  const _ConfirmDialog({
    required this.title,
    required this.body,
    required this.confirmLabel,
    required this.cancelLabel,
    required this.icon,
    required this.destructive,
  });

  final String title;
  final String body;
  final String confirmLabel;
  final String cancelLabel;
  final String icon;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final cancel = AppButton.tonal(
      label: cancelLabel,
      onPressed: () => Navigator.of(context).pop(false),
    );
    final confirm = AppButton(
      label: confirmLabel,
      kind: destructive ? AppButtonKind.destructive : AppButtonKind.primary,
      onPressed: () {
        if (destructive) Haptics.medium();
        Navigator.of(context).pop(true);
      },
    );

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(
        horizontal: Space.s26,
        vertical: Space.s24,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: Metrics.confirmDialogWidth),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(Space.s20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: Metrics.dialogIcon,
                height: Metrics.dialogIcon,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: destructive
                      ? palette.destructive.withValues(alpha: 0.22)
                      : palette.brassSoft,
                ),
                child: AppIcon(
                  icon,
                  color: destructive ? palette.destructive : palette.brassText,
                ),
              ),
              const SizedBox(height: Space.s12),
              Semantics(
                namesRoute: true,
                header: true,
                child: Text(
                  title,
                  textAlign: TextAlign.start,
                  style: context.displayText.titleLarge?.copyWith(fontSize: 21),
                ),
              ),
              const SizedBox(height: Space.s4),
              Text(
                body,
                textAlign: TextAlign.start,
                style: context.bodyText.bodyLarge?.copyWith(
                  fontSize: 15.5,
                  color: palette.textDim,
                ),
              ),
              const SizedBox(height: Space.s20),
              LayoutBuilder(
                builder: (context, constraints) {
                  final labelWidth =
                      (constraints.maxWidth - Space.s10) / 2 - Space.s32;
                  final style = context.bodyText.labelLarge?.copyWith(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w700,
                  );
                  final painter = TextPainter(
                    textDirection: Directionality.of(context),
                    textScaler: MediaQuery.textScalerOf(context),
                    maxLines: 1,
                  );
                  bool fits(String label) {
                    painter.text = TextSpan(text: label, style: style);
                    painter.layout();
                    return painter.width <= labelWidth;
                  }

                  final sideBySide = fits(cancelLabel) && fits(confirmLabel);
                  painter.dispose();
                  if (sideBySide) {
                    return Row(
                      children: [
                        Expanded(child: cancel),
                        const SizedBox(width: Space.s10),
                        Expanded(child: confirm),
                      ],
                    );
                  }
                  return Column(
                    children: [
                      cancel,
                      const SizedBox(height: Space.s10),
                      confirm,
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
