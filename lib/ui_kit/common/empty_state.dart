import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';
import '../controls/app_buttons.dart';
import 'app_icon.dart';

/// A shared empty state with an optional primary action.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.title,
    this.body,
    this.actionLabel,
    this.onAction,
    this.icon = IconAsset.note,
  }) : assert(
         (actionLabel == null) == (onAction == null),
         'actionLabel and onAction go together',
       );

  /// Already localized heading.
  final String title;

  /// Already localized guidance sentence.
  final String? body;

  /// Label of the optional brass button below the text.
  final String? actionLabel;
  final VoidCallback? onAction;
  final String icon;

  static const double _liftAboveMiddle = 90;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Center(
      child: SingleChildScrollView(
        // The artboard lifts the block above the middle (90px extra below) so it
        // clears the floating add button.
        padding: const EdgeInsets.fromLTRB(
          Space.s24,
          Space.s32,
          Space.s24,
          Space.s32 + _liftAboveMiddle,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: Metrics.emptyIcon,
              height: Metrics.emptyIcon,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: p.tone, shape: BoxShape.circle),
              child: AppIcon(icon, size: Metrics.emptyStateGlyph, color: p.textDim),
            ),
            const SizedBox(height: Space.s24),
            Semantics(
              header: true,
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: context.bodyText.titleLarge,
              ),
            ),
            if (body != null) ...<Widget>[
              const SizedBox(height: Space.s12),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 320),
                child: Text(
                  body!,
                  textAlign: TextAlign.center,
                  style: context.bodyText.bodyLarge!.copyWith(color: p.textDim),
                ),
              ),
            ],
            if (actionLabel != null) ...<Widget>[
              const SizedBox(height: Space.s24),
              AppButton.primary(
                label: actionLabel!,
                onPressed: onAction,
                expand: false,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
