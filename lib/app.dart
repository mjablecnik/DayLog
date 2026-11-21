import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'l10n/app_localizations.dart';
import 'shell/app_shell.dart';
import 'quests/ui/state/quest_actions.dart';
import 'settings/ui_providers.dart';
import 'theme/app_theme.dart';
import 'theme/theme_registry.dart';
import 'time_tracking/time_tracking.dart' show ReminderActionHost;
import 'quests/ui/reward/reward_overlay.dart';

/// The application root: theme, locale and localization follow the settings
/// live, so a change applies to every screen without rebuilding navigation.
class ZaflingApp extends ConsumerWidget {
  const ZaflingApp({
    super.key,
    this.home = const ReminderActionHost(child: AppShell()),
  });

  /// The root screen; tests swap in a probe.
  final Widget home;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(effectiveLocaleProvider);
    final theme = ref.watch(activeThemeProvider);
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).app_name,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      locale: locale,
      theme: buildTheme(palette: theme.light),
      darkTheme: buildTheme(palette: theme.dark),
      themeMode: ref.watch(themeModeProvider),
      // The application-level Localizations does not tag its subtree, so screen
      // readers would keep the device voice without this.
      // The reward overlay lives here, above the Navigator, so a reward earned
      // on a pushed route (Mission detail) is not hidden behind that route.
      builder: (context, child) => Semantics(
        localeForSubtree: locale,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            ?child,
            RewardOverlay(
              onCompleteMission: (id) => completeMission(context, ref, id),
            ),
          ],
        ),
      ),
      home: home,
    );
  }
}
