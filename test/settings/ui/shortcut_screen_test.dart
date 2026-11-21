import 'package:daylog/database/app_database.dart';
import 'package:daylog/database/providers.dart';
import 'package:daylog/l10n/app_localizations.dart';
import 'package:daylog/settings/ui/shortcut_guide.dart';
import 'package:daylog/settings/ui/shortcut_screen.dart';
import 'package:daylog/theme/app_theme.dart';
import 'package:daylog/theme/tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_database.dart';

void main() {
  testWidgets('the shortcut page shows the picker, the link and the steps, and goes back', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
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
          home: Builder(
            builder: (BuildContext context) => Scaffold(
              body: TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const ShortcutScreen(
                      targets: <ShortcutTarget>[
                        ShortcutTarget(linkName: 'calendar', label: 'Calendar'),
                        ShortcutTarget(linkName: 'notes', label: 'Notes'),
                      ],
                    ),
                  ),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.byType(ShortcutScreen), findsOneWidget);
    expect(find.text('daylog://calendar'), findsOneWidget);
    await tester.tap(find.text('Notes'));
    await tester.pump();
    expect(find.text('daylog://notes'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Back'));
    await tester.pumpAndSettle();
    expect(find.byType(ShortcutScreen), findsNothing);
  });
}
