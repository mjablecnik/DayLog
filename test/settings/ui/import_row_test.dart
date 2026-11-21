import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zafling/database/app_database.dart';
import 'package:zafling/database/import/import_providers.dart';
import 'package:zafling/database/providers.dart';
import 'package:zafling/l10n/app_localizations.dart';
import 'package:zafling/settings/ui/import_row.dart';
import 'package:zafling/theme/quest_theme.dart';
import 'package:zafling/theme/tokens.dart';

import '../../helpers/test_database.dart';

void main() {
  late AppDatabase db;
  late ProviderContainer container;

  Future<void> pump(WidgetTester tester, String? Function() file) async {
    tester.view.physicalSize = const Size(780, 1688);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    db = createTestDatabase();
    container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        importFileReaderProvider.overrideWithValue(() async => file()),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: buildTheme(palette: QuestPalette.guildBoard),
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(body: SafeArea(child: ImportRow())),
        ),
      ),
    );
  }

  Future<void> settle(WidgetTester tester) async {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));
  }

  Future<void> close(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 10));
    await tester.runAsync(db.close);
  }

  final String timelog = File('test/database/import/fixtures/timelog-export.json').readAsStringSync();

  testWidgets('shows what the file replaces, and a cancel changes nothing', (tester) async {
    await pump(tester, () => timelog);
    await tester.tap(find.text('Import data'));
    await settle(tester);

    expect(find.text('Replace the data?'), findsOneWidget);
    expect(find.textContaining('timelog-export'), findsNothing);
    expect(find.textContaining('time_entries: 4 / 0'), findsOneWidget);
    expect(find.textContaining('1.2.0'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await settle(tester);
    expect(await tester.runAsync(() => db.select(db.timeEntries).get()), isEmpty);
    expect(container.read(importCounterProvider), 0);
    await close(tester);
  });

  testWidgets('a confirmed import loads the rows, reports them and counts as an import', (tester) async {
    await pump(tester, () => timelog);
    await tester.tap(find.text('Import data'));
    await settle(tester);
    await tester.tap(find.text('Replace'));
    await settle(tester);

    expect(find.text('Import finished'), findsOneWidget);
    expect(await tester.runAsync(() => db.select(db.timeEntries).get()), hasLength(4));
    expect(container.read(importCounterProvider), 1);
    await close(tester);
  });

  testWidgets('a file that is not an export says so and changes nothing', (tester) async {
    await pump(tester, () => 'this is not json');
    await tester.tap(find.text('Import data'));
    await settle(tester);

    expect(find.textContaining('not a data export'), findsOneWidget);
    expect(find.text('Replace the data?'), findsNothing);
    await close(tester);
  });

  testWidgets('cancelling the file picker does nothing', (tester) async {
    await pump(tester, () => null);
    await tester.tap(find.text('Import data'));
    await settle(tester);
    expect(find.text('Replace the data?'), findsNothing);
    expect(find.byType(SnackBar), findsNothing);
    await close(tester);
  });
}
