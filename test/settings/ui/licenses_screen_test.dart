import 'package:daylog/core/font_licenses.dart';
import 'package:daylog/database/app_database.dart';
import 'package:daylog/database/providers.dart';
import 'package:daylog/l10n/app_localizations.dart';
import 'package:daylog/settings/ui/licenses_screen.dart';
import 'package:daylog/theme/app_theme.dart';
import 'package:daylog/theme/tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_database.dart';

void main() {
  testWidgets('the licences page lists packages as rows and opens one', (
    tester,
  ) async {
    registerFontLicenses();
    final AppDatabase db = createTestDatabase();
    final ProviderContainer container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(db)],
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
          home: const LicensesScreen(version: '1.0.0'),
        ),
      ),
    );
    for (var i = 0; i < 20; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 50)),
      );
      await tester.pump();
    }
    expect(find.text('Licenses'), findsOneWidget);
    expect(find.text('Figtree (font)'), findsOneWidget);

    await tester.tap(find.text('Figtree (font)'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.textContaining('SIL Open Font License'), findsWidgets);
  });
}
