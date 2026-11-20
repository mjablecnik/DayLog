import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../quests/data/models.dart';
import '../l10n/app_localizations.dart';
import '../calendar/services/calendar_providers.dart';
import '../notes/services/notes_providers.dart';
import '../quests/services/providers.dart';
import '../quests/ui/state/board_day.dart';
import '../settings/ui_providers.dart';
import '../theme/quest_theme.dart';
import '../ui_kit/common/menu_button.dart';
import '../ui_kit/common/snackbar_host.dart';
import '../quests/ui/board/board_screen.dart';
import '../calendar/ui/screens/calendar_screen.dart';
import '../quests/ui/missions/missions_screen.dart';
import '../notes/ui/screens/notes/notes_screen.dart';
import '../settings/ui/settings_screen.dart';
import '../settings/ui/shortcut_guide.dart' show ShortcutTarget;
import '../time_tracking/time_tracking.dart';
import 'deep_link.dart';
import 'app_drawer.dart';
import 'bottom_bar.dart';
import 'destination.dart';
import 'reconcile_banner.dart';
import 'splash_screen.dart';

/// Root screen: the Bottom_Bar with the five tabs (Timer, Questy, Kalendář,
/// Poznámky, Nastavení), the Drawer with the other Destinations (History,
/// Statistics, Missions) and the pages themselves. The Quest, Calendar and Notes
/// pages show the splash until the first Reconciliation has finished; the
/// timer pages do not wait for it. The reward overlay is hosted by `ZaflingApp`,
/// above the Navigator, so it also covers pushed routes.
///
/// Reconciliation runs at start, once per return from the background, when the
/// Board_Day changes, and on retry. Requests made in the same turn are
/// coalesced into one run, and a request made while a run is in flight triggers
/// exactly one more run afterwards.
class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key, this.initial = Destination.timer});

  /// The page shown first; a deep link that launches the app replaces it.
  final Destination initial;

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell>
    with WidgetsBindingObserver {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late Destination _destination = widget.initial;
  bool _ready = false;
  bool _failed = false;

  bool _running = false;
  bool _requested = false;
  bool _wentToBackground = false;
  StreamSubscription<Uri>? _links;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _requestReconcile();
    _links = ref
        .read(deepLinksProvider)
        .listen(_openLink, onError: (Object _) {});
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _links?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.hidden || AppLifecycleState.paused:
        _wentToBackground = true;
      case AppLifecycleState.resumed:
        // `inactive -> resumed` also happens without leaving the app (control
        // centre, system dialogs); only a real return from the background counts.
        if (_wentToBackground) {
          _wentToBackground = false;
          _requestReconcile();
        }
      case AppLifecycleState.inactive || AppLifecycleState.detached:
        break;
    }
  }

  void _requestReconcile() {
    _requested = true;
    if (_running) return;
    _running = true;
    scheduleMicrotask(_drain);
  }

  Future<void> _drain() async {
    try {
      while (_requested && mounted) {
        _requested = false;
        await _reconcileOnce();
      }
    } finally {
      _running = false;
    }
  }

  Future<void> _reconcileOnce() async {
    List<Mission>? posted;
    try {
      posted = await ref.read(recurrenceServiceProvider).reconcile();
    } catch (_) {
      // Not only StorageError: whatever fails, the stored data stays usable
      // and the user gets the retry banner instead of a stuck splash.
      posted = null;
    }
    // Notes: whatever expired in the Trash goes now. A failure is ignored; the
    // next request tries again and nothing else depends on it.
    try {
      await ref.read(notesServiceProvider).purgeExpired();
    } catch (_) {}
    // Calendar: addresses not used for 30 days are forgotten; same tolerance.
    try {
      await ref.read(calendarServiceProvider).purgeExpiredAddresses();
    } catch (_) {}
    if (!mounted) return;
    setState(() {
      _ready = true;
      _failed = posted == null;
    });
    if (posted != null && posted.isNotEmpty) {
      // Reconciliation can finish before the first settings emission, when the
      // widget tree still runs in the device language, so the stored language
      // is resolved explicitly instead of read from the context.
      try {
        await ref.read(settingsProvider.future);
      } catch (_) {
        // Defaults apply: the message is shown in the device language.
      }
      if (!mounted) return;
      final l10n = lookupAppLocalizations(ref.read(effectiveLocaleProvider));
      ref
          .read(snackbarProvider.notifier)
          .show(
            SnackMessage(
              l10n.app_postedMissions(posted.map((m) => m.name).join(', ')),
            ),
          );
    }
  }

  void _showPendingSnack(SnackMessage? message) {
    if (message == null || !mounted) return;
    ref.read(snackbarProvider.notifier).clear();
    final action = message.action;
    showAppSnack(
      context,
      message.text,
      actionLabel: action?.label,
      onAction: action?.onPressed,
    );
  }

  /// A `zafling://calendar` style link: closes what is open above the shell and
  /// shows the Destination. Anything else is ignored.
  void _openLink(Uri uri) {
    final Destination? destination = destinationFromUri(uri);
    if (destination == null || !mounted) return;
    Navigator.of(context).popUntil((Route<dynamic> route) => route.isFirst);
    _select(destination);
  }

  void _select(Destination destination) {
    if (destination == _destination) return;
    // A message belongs to the screen that raised it (for example a Settings
    // rule saved), so it does not follow the user to another page.
    ScaffoldMessenger.of(context).clearSnackBars();
    // The figures of the Statistics page are recomputed on every visit.
    if (destination == Destination.statistics) refreshStatistics(ref);
    setState(() => _destination = destination);
  }

  void _selectFromDrawer(Destination destination) {
    _scaffoldKey.currentState?.closeDrawer();
    _select(destination);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<SnackMessage?>(
      snackbarProvider,
      (_, next) => _showPendingSnack(next),
    );
    ref.listen<DateTime>(boardDayProvider, (_, _) => _requestReconcile());

    return ShellMenuScope(
      open: () => _scaffoldKey.currentState?.openDrawer(),
      child: Scaffold(
        key: _scaffoldKey,
        resizeToAvoidBottomInset: false,
        backgroundColor: context.palette.board,
        // The edge swipe collides with the iOS back swipe and with the reorder
        // and slide gestures of the lists, so only the menu button opens it.
        drawerEnableOpenDragGesture: false,
        drawer: AppDrawer(selected: _destination, onSelect: _selectFromDrawer),
        body: _buildPages(context),
      ),
    );
  }

  Widget _buildPages(BuildContext context) {
    // The pages that read the Quest data wait for the first Reconciliation.
    Widget gated(Widget page) => _ready ? page : const SplashScreen();
    return Column(
      children: <Widget>[
        Expanded(
          // All pages stay mounted, so each keeps its scroll position.
          child: IndexedStack(
            index: _destination.index,
            children: <Widget>[
              for (final Destination d in Destination.values)
                switch (d) {
                  Destination.timer => const TimerScreen(),
                  Destination.history => const HistoryScreen(),
                  Destination.statistics => const StatisticsScreen(),
                  Destination.quests => gated(BoardScreen()),
                  Destination.missions => gated(MissionsScreen()),
                  Destination.calendar => gated(CalendarScreen()),
                  Destination.notes => gated(NotesScreen()),
                  Destination.settings => SettingsScreen(
                    shortcutTargets: _shortcutTargets(context),
                    moduleGroups: const <Widget>[TimeSettingsGroups()],
                  ),
                },
            ],
          ),
        ),
        if (_failed) ReconcileBanner(onRetry: _requestReconcile),
        BottomBar(selected: _destination.tab, onSelected: _select),
      ],
    );
  }

  List<ShortcutTarget> _shortcutTargets(BuildContext context) {
    final AppLocalizations l = AppLocalizations.of(context);
    return <ShortcutTarget>[
      for (final Destination d in Destination.values)
        if (d != Destination.settings)
          ShortcutTarget(linkName: d.linkName, label: d.label(l)),
    ];
  }
}
