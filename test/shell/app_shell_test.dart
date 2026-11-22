import 'dart:ui' show Tristate;
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:daylog/app.dart';
import 'package:daylog/quests/domain/cadence.dart';
import 'package:daylog/core/errors.dart';
import 'package:daylog/quests/domain/xp_rules.dart';
import 'package:daylog/database/app_database.dart';
import 'package:daylog/quests/data/models.dart';
import 'package:daylog/database/preferences.dart';
import 'package:daylog/quests/services/providers.dart';
import 'package:daylog/quests/services/recurrence_service.dart';
import 'package:daylog/settings/settings_service.dart';
import 'package:daylog/quests/ui/board/board_screen.dart';
import 'package:daylog/calendar/ui/screens/calendar_screen.dart';
import 'package:daylog/quests/ui/missions/missions_screen.dart';
import 'package:daylog/notes/ui/screens/notes/notes_screen.dart';
import 'package:daylog/settings/ui/settings_screen.dart';
import 'package:daylog/shell/deep_link.dart';
import 'package:daylog/shell/app_drawer.dart';
import 'package:daylog/shell/app_shell.dart';
import 'package:daylog/shell/module.dart';
import 'package:daylog/shell/module_bar.dart';
import 'package:daylog/shell/destination.dart';
import 'package:daylog/shell/reconcile_banner.dart';
import 'package:daylog/shell/splash_screen.dart';
import 'package:daylog/time_tracking/time_tracking.dart' show TimeSettingsGroups;
import 'package:daylog/settings/ui_providers.dart';
import 'package:daylog/ui_kit/common/add_fab.dart';
import 'package:daylog/ui_kit/common/menu_button.dart';
import 'package:daylog/quests/ui/hero/hero_bar.dart';

import '../helpers/fixed_clock.dart';
import '../helpers/seed.dart';
import '../helpers/shell_nav.dart';
import '../helpers/test_database.dart';
import 'package:daylog/database/providers.dart';
import 'package:daylog/core/clock_provider.dart';

/// Counts Reconciliation runs and lets a test hold, fail or fill each one.
class SpyRecurrence extends RecurrenceService {
  SpyRecurrence(super.db, super.clock);

  int calls = 0;
  Completer<List<Mission>>? gate;
  Object? failure;
  List<Mission> posted = const <Mission>[];

  @override
  Future<List<Mission>> reconcile() async {
    calls++;
    final Completer<List<Mission>>? held = gate;
    if (held != null) return held.future;
    final Object? error = failure;
    if (error != null) throw error;
    return posted;
  }
}

Mission _mission(int id, String name) => Mission(
  id: id,
  name: name,
  bonus: MissionBonus.small,
  status: MissionStatus.open,
  ruleId: null,
  createdAt: DateTime(2026, 11, 16, 12),
  completedAt: null,
  awardedBonus: null,
);

void main() {
  late AppDatabase db;
  late FixedClock clock;
  late SpyRecurrence spy;
  late ProviderContainer container;

  /// Like [testWidgets], but disposes the tree (cancelling the Board_Day timer,
  /// which the test binding checks for before tear-downs run) and closes the
  /// database at the end of the body.
  void shellTest(
    String description,
    Future<void> Function(WidgetTester tester) body,
  ) {
    testWidgets(description, (tester) async {
      try {
        await body(tester);
      } finally {
        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(milliseconds: 10));
        await tester.runAsync(() => db.close());
      }
    });
  }

  /// Drift streams run on real async: give them time, then rebuild.
  Future<void> settle(WidgetTester tester) async {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await tester.pump();
    await tester.pump();
  }

  /// Pumps the real [DayLogApp] (default home: the shell). [setUp] may seed the
  /// database and prime the [SpyRecurrence] before the first Reconciliation.
  Future<void> pumpApp(
    WidgetTester tester, {
    bool realRecurrence = false,
    Future<void> Function()? seed,
    void Function(SpyRecurrence spy)? prime,
    Stream<Uri>? links,
    Destination initial = Destination.quests,
  }) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    db = createTestDatabase();
    clock = FixedClock(DateTime(2026, 11, 16, 12));
    spy = SpyRecurrence(db, clock);
    prime?.call(spy);
    if (seed != null) await tester.runAsync(seed);
    final overrides = [
      databaseProvider.overrideWithValue(db),
      clockProvider.overrideWithValue(clock),
      if (!realRecurrence) recurrenceServiceProvider.overrideWithValue(spy),
      deviceLocaleProvider.overrideWithValue(const Locale('en')),
      appVersionProvider.overrideWith((ref) async => '1.0.0'),
      if (links != null) deepLinksProvider.overrideWithValue(links),
    ];
    await tester.pumpWidget(
      ProviderScope(overrides: overrides, child: DayLogApp(home: AppShell(initial: initial))),
    );
    container = ProviderScope.containerOf(
      tester.element(find.byType(DayLogApp)),
    );
  }

  void goToBackground(WidgetTester tester) {
    for (final AppLifecycleState s in <AppLifecycleState>[
      AppLifecycleState.inactive,
      AppLifecycleState.hidden,
      AppLifecycleState.paused,
    ]) {
      tester.binding.handleAppLifecycleStateChanged(s);
    }
  }

  void returnToForeground(WidgetTester tester) {
    for (final AppLifecycleState s in <AppLifecycleState>[
      AppLifecycleState.hidden,
      AppLifecycleState.inactive,
      AppLifecycleState.resumed,
    ]) {
      tester.binding.handleAppLifecycleStateChanged(s);
    }
  }

  Destination shown(WidgetTester tester) => Destination.values[
      tester.widget<IndexedStack>(find.byType(IndexedStack)).index!];

  /// Shows [destination]: a tab by a tap on the Bottom_Bar, any other page
  /// through the menu button and the Drawer.
  Future<void> open(WidgetTester tester, Destination destination) async {
    await tapDestination(tester, destination);
    await settle(tester);
  }

  group('splash', () {
    shellTest('shows until the first Reconciliation finishes, then the Board', (
      tester,
    ) async {
      await pumpApp(tester, prime: (s) => s.gate = Completer<List<Mission>>());
      await tester.pump();
      expect(find.byType(SplashScreen), findsOneWidget);
      expect(find.text('Preparing your board…'), findsOneWidget);
      expect(find.byType(ModuleBar), findsOneWidget);
      expect(find.byType(BoardScreen), findsNothing);
      expect(spy.calls, 1);

      spy.gate!.complete(const <Mission>[]);
      await tester.pump();
      await tester.pump();
      expect(find.byType(SplashScreen), findsNothing);
      expect(find.byType(BoardScreen), findsOneWidget);
      expect(find.byType(ModuleBar), findsOneWidget);
      expect(spy.calls, 1);
    });

    shellTest('a failing first Reconciliation still leaves the splash', (
      tester,
    ) async {
      await pumpApp(
        tester,
        prime: (s) => s.failure = const StorageError('disk'),
      );
      await settle(tester);
      expect(find.byType(SplashScreen), findsNothing);
      expect(find.byType(BoardScreen), findsOneWidget);
    });
  });

  group('tabs', () {
    shellTest('shows the current module tabs and switches modules through the launcher', (
      tester,
    ) async {
      await pumpApp(tester);
      await settle(tester);

      expect(find.byKey(moduleButtonKey), findsOneWidget);
      expect(find.byKey(moduleBarTabKey(Destination.quests)), findsOneWidget);
      expect(find.byKey(moduleBarTabKey(Destination.missions)), findsOneWidget);
      expect(find.byKey(moduleBarTabKey(Destination.timer)), findsNothing);
      expect(shown(tester), Destination.quests);

      await open(tester, Destination.timer);
      expect(shown(tester), Destination.timer);

      await open(tester, Destination.calendar);
      expect(shown(tester), Destination.calendar);
      expect(find.byType(CalendarScreen), findsOneWidget);
      expect(find.byType(HeroBar), findsNothing);

      await open(tester, Destination.notes);
      expect(shown(tester), Destination.notes);
      expect(find.byType(NotesScreen), findsOneWidget);
      expect(find.byType(HeroBar), findsNothing);

      await open(tester, Destination.settings);
      expect(shown(tester), Destination.settings);
      expect(find.byType(SettingsScreen), findsOneWidget);

      await open(tester, Destination.quests);
      expect(shown(tester), Destination.quests);
      expect(find.byType(SettingsScreen), findsNothing);
    });

    shellTest('the Timer is the first page', (tester) async {
      await pumpApp(tester, initial: Destination.timer);
      await settle(tester);
      expect(shown(tester), Destination.timer);
      expect(
        tester.widget<ModuleBar>(find.byType(ModuleBar)).location.destination,
        Destination.timer,
      );
    });

    shellTest('the Drawer lists the complete navigation, the tabs included', (
      tester,
    ) async {
      await pumpApp(tester);
      await settle(tester);
      await tester.tap(find.byType(MenuButton).hitTestable().first);
      await tester.pumpAndSettle();
      for (final Destination d in Destination.values) {
        expect(find.byKey(drawerItemKey(d)), findsOneWidget, reason: d.name);
      }
    });

    shellTest('every Destination can be opened from the Drawer', (tester) async {
      await pumpApp(tester);
      await settle(tester);
      for (final Destination d in Destination.values) {
        await tapDestination(tester, d, viaDrawer: true);
        await settle(tester);
        expect(shown(tester), d, reason: d.name);
        expect(find.byType(Drawer), findsNothing, reason: d.name);
      }
    });

    shellTest('a page from the Drawer marks its tab in the bar and closes the Drawer', (
      tester,
    ) async {
      await pumpApp(tester, initial: Destination.timer);
      await settle(tester);
      await open(tester, Destination.missions);
      expect(shown(tester), Destination.missions);
      expect(find.byType(MissionsScreen), findsOneWidget);
      expect(tester.widget<ModuleBar>(find.byType(ModuleBar)).location.destination, Destination.missions);
      expect(find.byType(Drawer), findsNothing);

      await open(tester, Destination.statistics);
      expect(shown(tester), Destination.statistics);
      expect(tester.widget<ModuleBar>(find.byType(ModuleBar)).location.destination, Destination.statistics);

      await open(tester, Destination.history);
      expect(shown(tester), Destination.history);
    });

    shellTest('tabs have 44 px hit areas and a selected semantic state', (
      tester,
    ) async {
      await pumpApp(tester);
      await settle(tester);
      final questsTab = find.byKey(moduleBarTabKey(Destination.quests));
      final missionsTab = find.byKey(moduleBarTabKey(Destination.missions));
      for (final tab in [questsTab, missionsTab]) {
        final size = tester.getSize(tab);
        expect(size.height, greaterThanOrEqualTo(44));
        expect(size.width, greaterThanOrEqualTo(44));
      }
      final handle = tester.ensureSemantics();
      final quests = tester.getSemantics(questsTab);
      final missions = tester.getSemantics(missionsTab);
      expect(quests.label, 'Quests');
      expect(missions.label, 'Missions');
      expect(quests.flagsCollection.isSelected, Tristate.isTrue);
      expect(missions.flagsCollection.isSelected, Tristate.isFalse);
      handle.dispose();
    });

    shellTest('Settings is a tab: no back button, no hero bar, no add button', (
      tester,
    ) async {
      await pumpApp(tester);
      await settle(tester);
      await open(tester, Destination.settings);

      expect(find.byType(SettingsScreen), findsOneWidget);
      expect(find.text('Back'), findsNothing);
      expect(find.byType(HeroBar), findsNothing);
      expect(find.byType(AddFab), findsNothing);
      expect(find.byType(ModuleBar), findsOneWidget);
      expect(find.bySemanticsLabel('Settings'), findsWidgets);
    });

    shellTest('Settings places recurring reminders in the planning group', (
      tester,
    ) async {
      await pumpApp(tester);
      await settle(tester);
      await open(tester, Destination.settings);

      expect(find.byType(TimeSettingsGroups), findsOneWidget);
      expect(find.text('Recurring reminders'), findsOneWidget);
      final double shortcut = tester.getTopLeft(find.text('Home Screen shortcut')).dy;
      final double reminder = tester.getTopLeft(find.text('Recurring reminders')).dy;
      expect(reminder, lessThan(shortcut));
    });

    shellTest('a message raised on the Settings tab is cleared on leaving it', (
      tester,
    ) async {
      await pumpApp(tester);
      await settle(tester);
      await open(tester, Destination.settings);
      container
          .read(snackbarProvider.notifier)
          .show(const SnackMessage('Rule posted'));
      await tester.pump();
      await tester.pump();
      expect(find.text('Rule posted'), findsOneWidget);

      await open(tester, Destination.quests);
      await tester.pumpAndSettle();
      expect(find.byType(SnackBar), findsNothing);
    });
  });

  group('scroll position', () {
    double offset(WidgetTester tester, Type screen) {
      final Finder scrollable = find.descendant(
        of: find.byType(screen, skipOffstage: false),
        matching: find.byType(Scrollable, skipOffstage: false),
      );
      return tester.state<ScrollableState>(scrollable.first).position.pixels;
    }

    /// Scrolls [screen] on [tab], leaves the tab, comes back, and compares.
    Future<void> checkRetention(
      WidgetTester tester, {
      required Type screen,
      required Destination page,
      required Destination other,
      required Future<void> Function() seed,
    }) async {
      await pumpApp(tester, seed: seed);
      await settle(tester);
      await open(tester, page);

      final Finder lists = find.descendant(
        of: find.byType(screen),
        matching: find.byType(Scrollable),
      );
      expect(lists, findsWidgets);
      await tester.drag(lists.first, const Offset(0, -600));
      await settle(tester);
      await tester.pumpAndSettle();
      final double before = offset(tester, screen);
      expect(before, greaterThan(0));

      await open(tester, other);
      await open(tester, page);
      expect(offset(tester, screen), before);
    }

    shellTest('the Missions tab keeps its offset across tab switches', (
      tester,
    ) async {
      await checkRetention(
        tester,
        screen: MissionsScreen,
        page: Destination.missions,
        other: Destination.quests,
        seed: () async {
          for (int i = 0; i < 40; i++) {
            await seedMission(db, name: 'Mission $i');
          }
        },
      );
    });

    shellTest('the Settings tab keeps its offset across tab switches', (
      tester,
    ) async {
      await checkRetention(
        tester,
        screen: SettingsScreen,
        page: Destination.settings,
        other: Destination.quests,
        // Enough recurring rules to make the Settings list taller than the screen.
        seed: () async {
          for (int i = 0; i < 12; i++) {
            await db.into(db.recurringRules).insert(
              RecurringRulesCompanion.insert(
                name: 'Rule $i',
                cadence: Cadence.monthly,
                anchorDate: DateTime(2026, 12, 1),
                bonus: MissionBonus.small,
                createdAt: DateTime(2026, 11, 15),
              ),
            );
          }
        },
      );
    });

    shellTest('the Quests tab keeps its offset across tab switches', (
      tester,
    ) async {
      await checkRetention(
        tester,
        screen: BoardScreen,
        page: Destination.quests,
        other: Destination.missions,
        seed: () async {
          for (int i = 0; i < 40; i++) {
            await seedQuest(db, name: 'Quest $i', sortOrder: i + 1);
          }
        },
      );
    });
  });

  group('Reconciliation', () {
    shellTest('runs once at start and not again on rebuilds or tab changes', (
      tester,
    ) async {
      await pumpApp(tester);
      await settle(tester);
      expect(spy.calls, 1);

      await open(tester, Destination.missions);
      await open(tester, Destination.quests);
      // A resume without leaving the app (control centre) does not count.
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await settle(tester);
      expect(spy.calls, 1);
    });

    shellTest('runs exactly once per return from the background', (
      tester,
    ) async {
      await pumpApp(tester);
      await settle(tester);
      expect(spy.calls, 1);

      goToBackground(tester);
      await settle(tester);
      expect(spy.calls, 1);
      returnToForeground(tester);
      await settle(tester);
      expect(spy.calls, 2);

      // Nothing more until the next return.
      await settle(tester);
      await tester.pump(const Duration(seconds: 1));
      expect(spy.calls, 2);

      goToBackground(tester);
      returnToForeground(tester);
      await settle(tester);
      expect(spy.calls, 3);
    });

    shellTest('a new Board_Day on resume still costs one run, not two', (
      tester,
    ) async {
      await pumpApp(tester);
      await settle(tester);
      expect(spy.calls, 1);

      goToBackground(tester);
      clock.set(DateTime(2026, 11, 17, 12));
      returnToForeground(tester);
      await settle(tester);
      expect(spy.calls, 2);
    });

    shellTest('posted Missions produce a message naming them', (tester) async {
      await pumpApp(
        tester,
        prime: (s) => s.posted = <Mission>[
          _mission(1, 'Weekly review'),
          _mission(2, 'Pay rent'),
        ],
      );
      await settle(tester);
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Posted: Weekly review, Pay rent'), findsOneWidget);
    });

    shellTest('the message follows the stored language, not the device one', (
      tester,
    ) async {
      // The device says English; the stored setting says Czech. Reconciliation
      // finishes before the first settings emission, so the message must not
      // use the language the tree runs in at that moment.
      await pumpApp(
        tester,
        seed: () => SettingsService(db).setLanguage(AppLanguage.cs),
        prime: (s) => s.posted = <Mission>[_mission(1, 'Weekly review')],
      );
      await settle(tester);
      expect(find.text('Vyvěšeno: Weekly review'), findsOneWidget);
      expect(find.text('Posted: Weekly review'), findsNothing);
    });

    shellTest('no message when nothing was posted', (tester) async {
      await pumpApp(tester);
      await settle(tester);
      expect(find.byType(SnackBar), findsNothing);
    });

    shellTest('the real service posts a due rule and the shell says so', (
      tester,
    ) async {
      await pumpApp(
        tester,
        realRecurrence: true,
        seed: () async {
          await RecurrenceService(db, clock).create(
            RuleDraft(
              name: 'Weekly review',
              cadence: Cadence.daily,
              requestedAnchor: DateTime(2026, 11, 16),
              bonus: MissionBonus.small,
              quests: const <RuleQuestDraft>[
                RuleQuestDraft(name: 'Plan', difficulty: Difficulty.easy),
              ],
            ),
          );
        },
      );
      await settle(tester);
      await settle(tester);
      expect(find.text('Posted: Weekly review'), findsOneWidget);
    });

    shellTest('messages pushed to snackbarProvider are shown and cleared', (
      tester,
    ) async {
      await pumpApp(tester);
      await settle(tester);
      container
          .read(snackbarProvider.notifier)
          .show(const SnackMessage('Hello from a screen'));
      await tester.pump();
      await tester.pump();
      expect(find.text('Hello from a screen'), findsOneWidget);
      expect(container.read(snackbarProvider), isNull);
    });
  });

  group('storage error', () {
    shellTest('shows the data with a retry banner that reruns Reconciliation', (
      tester,
    ) async {
      await pumpApp(
        tester,
        prime: (s) => s.failure = const StorageError('disk full'),
      );
      await settle(tester);

      expect(spy.calls, 1);
      expect(find.byType(ReconcileBanner), findsOneWidget);
      expect(
        find.text('Recurring missions could not be checked.'),
        findsOneWidget,
      );
      // The rest of the app is still there and usable.
      expect(find.byType(BoardScreen), findsOneWidget);
      await open(tester, Destination.missions);
      expect(shown(tester), Destination.missions);
      expect(find.byType(ReconcileBanner), findsOneWidget);

      spy.failure = null;
      await tester.tap(find.text('Try again'));
      await settle(tester);
      expect(spy.calls, 2);
      expect(find.byType(ReconcileBanner), findsNothing);
    });

    shellTest('a failing retry keeps the banner', (tester) async {
      await pumpApp(
        tester,
        prime: (s) => s.failure = const StorageError('disk full'),
      );
      await settle(tester);
      await tester.tap(find.text('Try again'));
      await settle(tester);
      expect(spy.calls, 2);
      expect(find.byType(ReconcileBanner), findsOneWidget);
    });

    shellTest('the retry button is at least 44 px', (tester) async {
      await pumpApp(
        tester,
        prime: (s) => s.failure = const StorageError('disk full'),
      );
      await settle(tester);
      final Size size = tester.getSize(find.widgetWithText(FilledButton, 'Try again'));
      expect(size.height, greaterThanOrEqualTo(44));
      expect(size.width, greaterThanOrEqualTo(44));
    });
  });

  group('links', () {
    test('destinationFromUri reads daylog://<tab> and ignores the rest', () {
      expect(destinationFromUri(Uri.parse('daylog://calendar')), Destination.calendar);
      expect(destinationFromUri(Uri.parse('daylog://Notes')), Destination.notes);
      expect(destinationFromUri(Uri.parse('daylog:///missions')), Destination.missions);
      expect(destinationFromUri(Uri.parse('daylog://nowhere')), isNull);
      expect(destinationFromUri(Uri.parse('https://calendar')), isNull);
      expect(destinationFromUri(Uri.parse('daylog://')), isNull);
    });

    shellTest('a daylog://calendar link opens the Calendar tab, also when it arrives later', (tester) async {
      final StreamController<Uri> links = StreamController<Uri>();
      addTearDown(links.close);
      await pumpApp(tester, links: links.stream);
      await settle(tester);
      expect(find.byType(BoardScreen), findsOneWidget);
      links.add(Uri.parse('daylog://calendar'));
      await settle(tester);
      expect(shown(tester), Destination.calendar);
      links.add(Uri.parse('daylog://bogus'));
      await settle(tester);
      expect(shown(tester), Destination.calendar);
      links.add(Uri.parse('daylog://missions'));
      await settle(tester);
      expect(shown(tester), Destination.missions);
      links.add(Uri.parse('daylog://statistics'));
      await settle(tester);
      expect(shown(tester), Destination.statistics);
      final bar = tester.widget<ModuleBar>(find.byType(ModuleBar));
      expect(bar.location.module, Module.time);
      expect(bar.location.previous, Module.quests);
      links.add(Uri.parse('daylog://timer'));
      await settle(tester);
      expect(shown(tester), Destination.timer);
    });
  });
}
