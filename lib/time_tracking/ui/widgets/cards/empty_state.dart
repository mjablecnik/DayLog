import 'package:flutter/material.dart';

import '../../../theme/time_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../ui_kit/common/app_icon.dart';
import '../../../../ui_kit/common/empty_state.dart' as shared;

class EmptyState extends StatelessWidget {
  final AppThemeData theme;

  const EmptyState({super.key, required this.theme});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return shared.EmptyState(
      title: l10n.time_historyEmptyTitle,
      body: l10n.time_historyEmptySubtitle,
      icon: IconAsset.history,
    );
  }
}
