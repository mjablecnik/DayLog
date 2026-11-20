import 'package:flutter/material.dart';

import '../../../theme/time_theme.dart';
import '../../../../l10n/app_localizations.dart';

class EmptyState extends StatelessWidget {
  final AppThemeData theme;

  const EmptyState({super.key, required this.theme});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_toggle_off_outlined, size: 52, color: theme.faint),
          const SizedBox(height: 16),
          Text(
            l10n.time_historyEmptyTitle,
            style: TextStyle(
              color: theme.dim,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.time_historyEmptySubtitle,
            style: TextStyle(
              color: theme.faint,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
