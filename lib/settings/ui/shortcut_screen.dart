import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';
import '../../ui_kit/layout/app_header.dart';
import 'shortcut_guide.dart';

/// The Home Screen shortcut page, opened from Settings: pick a page, copy its
/// link and follow the steps in the Shortcuts app.
class ShortcutScreen extends StatelessWidget {
  const ShortcutScreen({super.key, required this.targets});

  final List<ShortcutTarget> targets;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: context.palette.board,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AppHeader(leading: HeaderLeading.back, title: l.settings_shortcutTitle),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  Space.s20,
                  Space.s24,
                  Space.s20,
                  Space.s24,
                ),
                children: <Widget>[ShortcutGuide(targets: targets)],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
