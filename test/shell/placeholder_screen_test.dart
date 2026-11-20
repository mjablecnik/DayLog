import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zafling/database/app_database.dart';
import 'package:zafling/quests/services/providers.dart';
import 'package:zafling/shell/destination.dart';
import 'package:zafling/shell/placeholder_screen.dart';
import 'package:zafling/ui_kit/common/menu_button.dart';

import '../helpers/test_database.dart';
import '../ui/widgets/common/_harness.dart';

void main() {
  testWidgets('PlaceholderScreen shows the title of its Destination and the menu button', (tester) async {
    final AppDatabase db = createTestDatabase();
    int opened = 0;
    await pumpCommon(
      tester,
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: ShellMenuScope(
          open: () => opened++,
          child: const PlaceholderScreen(destination: Destination.statistics),
        ),
      ),
    );
    expect(find.text('Statistics'), findsOneWidget);
    await tester.tap(find.byType(MenuButton));
    expect(opened, 1);
    await tester.pumpWidget(const SizedBox());
    await tester.runAsync(db.close);
  });
}
