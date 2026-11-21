import 'package:daylog/core/clock_provider.dart';
import 'package:daylog/database/app_database.dart';
import 'package:daylog/database/providers.dart';
import 'package:daylog/l10n/app_localizations.dart';
import 'package:daylog/settings/ui/rules_screen.dart';
import 'package:daylog/theme/app_theme.dart';
import 'package:daylog/theme/tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fixed_clock.dart';
import '../../helpers/test_database.dart';

void main() {
  testWidgets('the recurring Missions page has a back button, its title and the add row', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final AppDatabase db = createTestDatabase();
    final ProviderContainer container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        clockProvider.overrideWithValue(FixedClock(DateTime(2026, 11, 15, 12))),
      ],
    );
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox());
      container.dispose();
      await db.close();
    });
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: buildTheme(palette: AppPalette.guildBoard),
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (BuildContext context) => Scaffold(
              body: TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const RulesScreen()),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
    await tester.pumpAndSettle();

    expect(find.byType(RulesScreen), findsOneWidget);
    expect(find.text('Recurring missions'), findsWidgets);
    expect(find.text('Add a recurring mission'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Back'));
    await tester.pumpAndSettle();
    expect(find.byType(RulesScreen), findsNothing);
  });
}
