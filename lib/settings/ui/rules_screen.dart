import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';
import '../../ui_kit/common/sub_page_header.dart';
import 'rules_section.dart';

/// The recurring Missions page, opened from Settings: every rule, its count and
/// the add row.
class RulesScreen extends StatelessWidget {
  const RulesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: context.palette.board,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SubPageHeader(title: l.settings_groupRules),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  Space.s20,
                  Space.s24,
                  Space.s20,
                  Space.s24,
                ),
                children: const <Widget>[RulesSection()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
