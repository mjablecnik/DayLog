import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zafling/theme/tokens.dart';

import '../ui/a11y/_a11y_harness.dart';

/// Requirement 19.4: a golden comparison of the Board, Missions and Settings
/// screens in both themes. They render with the bundled Figtree on a 390x844
/// screen and the seeded Czech data of the accessibility harness.
///
/// Regenerate after an intended visual change with
/// `flutter test --update-goldens test/goldens`.
void main() {
  const Map<String, AppPalette> themes = <String, AppPalette>{
    'dark': AppPalette.guildBoard,
    'light': AppPalette.daylight,
  };
  const Map<String, Subject> screens = <String, Subject>{
    'board': Subject.board,
    'missions': Subject.missions,
    'settings': Subject.settings,
  };

  for (final MapEntry<String, Subject> screen in screens.entries) {
    for (final MapEntry<String, AppPalette> theme in themes.entries) {
      a11yTest('${screen.key} in the ${theme.key} theme', (
        WidgetTester tester,
        void Function(A11yEnv) track,
      ) async {
        track(
          await A11yEnv.pump(
            tester,
            screen.value,
            palette: theme.value,
            locale: const Locale('cs'),
          ),
        );
        await expectLater(
          find.byKey(A11yEnv.boundaryKey),
          matchesGoldenFile('${screen.key}_${theme.key}.png'),
        );
      });
    }
  }
}
