import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../theme/tokens.dart';
import '../ui_kit/controls/app_buttons.dart';

/// Inline message shown when Reconciliation failed: the stored data stays
/// usable, and "Try again" runs Reconciliation once more.
class ReconcileBanner extends StatelessWidget {
  const ReconcileBanner({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final p = context.palette;
    return Semantics(
      liveRegion: true,
      container: true,
      child: Material(
        color: p.card,
        shape: Border(
          top: BorderSide(color: p.boardLine, width: Metrics.hairline),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Space.s16,
            vertical: Space.s4,
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  l10n.app_reconcileFailed,
                  style: context.bodyText.bodyMedium?.copyWith(
                    color: p.textDim,
                  ),
                ),
              ),
              const SizedBox(width: Space.s8),
              PillButton(label: l10n.common_retry, onPressed: onRetry),
            ],
          ),
        ),
      ),
    );
  }
}
