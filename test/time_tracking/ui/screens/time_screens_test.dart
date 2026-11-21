import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:daylog/database/app_database.dart';
import 'package:daylog/database/providers.dart';
import 'package:daylog/l10n/app_localizations.dart';
import 'package:daylog/time_tracking/data/time_tracking_queries.dart';
import 'package:daylog/time_tracking/domain/config.dart';
import 'package:daylog/time_tracking/ui/screens/history_screen.dart';
import 'package:daylog/time_tracking/ui/screens/reminder_action_screen.dart';
import 'package:daylog/time_tracking/ui/screens/reminder_settings_screen.dart';
import 'package:daylog/time_tracking/ui/screens/statistics_screen.dart';
import 'package:daylog/time_tracking/ui/screens/timer_screen.dart';

import '../../../helpers/test_database.dart';
import '../../../helpers/time_theme.dart';

/// Smoke tests of the time tracking pages on an in-memory database: each page
/// opens, shows its title and its data, and closes without a pending timer.
void main() {
  Future<AppDatabase> pump(
    WidgetTester tester,
    Widget page, {
    Future<void> Function(AppDatabase)? seed,
  }) async {
    tester.view.physicalSize = const Size(780, 1688);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    final AppDatabase db = createTestDatabase();
    if (seed != null) await tester.runAsync(() => seed(db));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          theme: testMaterialTheme(),
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: page,
        ),
      ),
    );
    for (int i = 0; i < 3; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 80)),
      );
      await tester.pump(const Duration(milliseconds: 300));
    }
    return db;
  }

  Future<void> close(WidgetTester tester, AppDatabase db) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 10));
    await tester.runAsync(db.close);
  }

  Future<void> seedEntry(AppDatabase db) async {
    // The pages show the logical day, which starts at 03:00: before that hour the
    // current day is still yesterday.
    final DateTime now = DateTime.now();
    final DateTime logicalToday = now.hour < dayStartHour ? now.subtract(const Duration(days: 1)) : now;
    final DateTime start = DateTime(logicalToday.year, logicalToday.month, logicalToday.day, 10);
    await db
        .into(db.timeEntries)
        .insert(
          TimeEntriesCompanion.insert(
            startTime: start.toIso8601String(),
            endTime: start.add(const Duration(minutes: 40)).toIso8601String(),
            description: 'Write the spec',
            activityType: const Value('Práce'),
            subtype: const Value('paid'),
            project: const Value('DayLog'),
          ),
        );
  }

  testWidgets(
    'TimerScreen shows the default 20 minutes and the phase "Ready"',
    (tester) async {
      final AppDatabase db = await pump(tester, const TimerScreen());
      expect(find.text('20:00'), findsOneWidget);
      expect(find.text('READY'), findsOneWidget);
      await close(tester, db);
    },
  );

  testWidgets('HistoryScreen lists the entry of today with its description', (
    tester,
  ) async {
    final AppDatabase db = await pump(
      tester,
      const HistoryScreen(),
      seed: seedEntry,
    );
    expect(find.text('History'), findsOneWidget);
    expect(find.text('Write the spec'), findsOneWidget);
    await close(tester, db);
  });

  testWidgets(
    'StatisticsScreen shows the title and the tracked time of today',
    (tester) async {
      final AppDatabase db = await pump(
        tester,
        const StatisticsScreen(),
        seed: seedEntry,
      );
      expect(find.text('Statistics'), findsOneWidget);
      expect(find.textContaining('40m'), findsWidgets);
      await close(tester, db);
    },
  );

  testWidgets('ReminderSettingsScreen opens with no reminders yet', (
    tester,
  ) async {
    final AppDatabase db = await pump(tester, const ReminderSettingsScreen());
    expect(find.byType(ReminderSettingsScreen), findsOneWidget);
    await close(tester, db);
  });

  testWidgets('ReminderActionScreen shows the reminder it was opened for', (
    tester,
  ) async {
    late int id;
    final AppDatabase db = await pump(
      tester,
      const ReminderActionScreen(reminderId: 1),
      seed: (AppDatabase d) async {
        id = await d.insertReminder(
          RecurringRemindersCompanion.insert(
            name: 'Stretch',
            startTime: 9 * 60,
            endTime: 17 * 60,
            repeatInterval: 60,
            activeDays: 127,
          ),
        );
      },
    );
    expect(id, 1);
    expect(find.text('Stretch'), findsWidgets);
    await close(tester, db);
  });
}
