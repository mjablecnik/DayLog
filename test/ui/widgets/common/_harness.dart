import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zafling/l10n/app_localizations.dart';
import 'package:zafling/theme/quest_theme.dart';
import 'package:zafling/theme/tokens.dart';

/// Pumps [child] inside a themed, localized app with a Scaffold.
Future<void> pumpCommon(
  WidgetTester tester,
  Widget child, {
  bool disableAnimations = false,
  QuestPalette palette = QuestPalette.guildBoard,
}) {
  return tester.pumpWidget(
    MaterialApp(
      theme: buildTheme(palette: palette),
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (BuildContext context, Widget? app) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(disableAnimations: disableAnimations),
        child: app!,
      ),
      home: Scaffold(body: child),
    ),
  );
}
