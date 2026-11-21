import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:zafling/l10n/app_localizations.dart';
import 'package:zafling/time_tracking/ui/screens/reminder_settings_screen.dart';
import 'package:zafling/time_tracking/ui/screens/time_settings_groups.dart';
import '../../../helpers/time_theme.dart';
import 'package:zafling/database/providers.dart';
import '../../../helpers/test_database.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets(
    'tapping "Opakované připomínky" in Settings navigates to ReminderSettingsScreen',
    (tester) async {
      final db = createTestDatabase();
      addTearDown(db.close);

      final container = ProviderContainer(
        overrides: [databaseProvider.overrideWithValue(db)],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
 theme: testMaterialTheme(),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: Locale('cs'),
            home: Scaffold(body: ListView(children: const [TimeSettingsGroups()])),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(ReminderSettingsScreen), findsNothing);

      await tester.tap(find.text('Opakované připomínky'));
      await tester.pumpAndSettle();

      expect(find.byType(ReminderSettingsScreen), findsOneWidget);
    },
  );
}
